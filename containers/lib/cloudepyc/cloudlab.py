# Lab to connect to a cloud-based compute engine
#
# Copyright (C) 2023 Simon Dobson
#
# This file is part of cloud-epydemic, network simulation as a service
#
# cloud-epydemic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published byf
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cloud-epydemic is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cloud-epydemic. If not, see <http://www.gnu.org/licenses/gpl.html>.

import os
import logging
import base64
import pickle
import cloudpickle
import uuid
import time
import requests
from contextlib import AbstractContextManager
from epyc import Logger, Lab, LabNotebook, Experiment, ExperimentalParameters, ResultsDict
from typing import List, Any

logger = logging.getLogger(Logger)

# Metadata tag for experiment ids
# sd: This needs to move to epyc.Experiment
EXPERIMENT_ID = "epyc.experiment.id"


class CloudLab(Lab):
    """A :class:`Lab` running on a cloud-based microservices
    compute cluster.

    Experiments are submitted to engines in the cluster for execution
    in parallel, with the experiments being performed asynchronously.
    Combined with a persistent :class:`LabNotebook`, this allows for
    fully decoupled access to an on-going computational experiment
    with piecewise retrieval of results.
    """

    # Tuning parameters
    WaitingTime: int = 30           #: Waiting time in seconds for checking job completion.


    def __init__(self, url, notebook: LabNotebook = None):
        """Create an empty lab attached to the given cluster. The
        cluster is specified with a web API endpoint.

        The endpoint should be the "base" API endpoint, probably
        of the form "https;//host:5000/api", onto which the
        client will build the API calls.

        :param url: API endpoint
        :param notebook: the notebook used to results (defaults to an empty :class:`LabNotebook`)"""
        super().__init__(notebook)
        self._endpoint = url


    # ---------- API functions ----------

    # See containers/lib/gateway-api.yaml for the API definition

    def experimentIdentifier(self):
        '''Create a new experiment identifier. The identifier
        is guaranteed to be unique for this use of the API.

        At present we use random UUIDs.

        @returns: a unique string'''
        u = uuid.uuid4()
        return str(u)

    def runExperimentAsync(self, e: Experiment, params: ExperimentalParameters) -> Any:
        '''Run an experiment asynchronously.

        The experiment is submitted to the message broker's request channel,
        and an experiment id returned to later acquisition.

        @param submission: experiment and its parameters
        @returns: the experiment identifier'''

        # construct a submission
        submission = dict()

        # pickle the experiment and add to the parameters
        encoded = base64.b64encode(cloudpickle.dumps(e)).decode('ascii')
        submission['experiment'] = encoded

        # add the identifier
        j = self.experimentIdentifier()
        submission['experiment-id'] = j

        # add the parameters
        submission['params'] = params

        # make the request
        res = requests.post(f"{self._endpoint}/api/v1/runExperimentAsync", json=submission)
        if res.status_code != 200:
            raise Exception(f"Failed to submit experiment: {res.status_code}")

        # return the experiment identifier
        return j

    def getPendingResults(self) -> List[ResultsDict]:
        '''Retrieve all pending results.

        This reads messages from the message broker's result channel
        and returns them as an array.

        @returns: an array of results'''

        # get the array
        res = requests.get(f"{self._endpoint}/api/v1/getPendingResults")
        if res.status_code != 200:
            raise Exception(f"Failed to retrieve results: {res.status_code}")

        # strip the expewriment ids (they're in the metadata)
        rcs = map(lambda idrc: idrc['resultsDict'], res.json())
        return rcs


    # ---------- Remote control of the compute engines ----------

    def sync_imports(self, quiet: bool = False) -> AbstractContextManager:
        """Return a context manager to control imports onto all the engines
        in the underlying cluster. This method is used within a ``with`` statement.

        Any imports should be done with no experiments running, otherwise the
        method will block until the cluster is quiet. Generally imports will be one
        of the first things done when connecting to a cluster. (But be careful
        not to accidentally try to re-import if re-connecting to a running
        cluster.)

        :param quiet: if True, suppresses messages (defaults to False)
        :returns: a context manager"""
        raise NotImplementedError("sync_imports")

    def sync_code(self, code: str, quiet : bool =- False):
        """Import the given Python code onto all engines.

        :param code: the code
        :param quiet: it true, suppress messages (defaults to False)"""
        raise NotImplementedError("sync_code")


    # ---------- Running experiments ----------

    def runExperiment(self, e: Experiment):
        """Run the experiment across the parameter space in parallel using
        all the engines in the cluster. This method returns immediately.

        The experiments are run asynchronously, with the points in the parameter
        space being explored randomly so that intermediate retrievals of results
        are more representative of the overall result. Put another way, for a lot
        of experiments the results available will converge towards a final
        answer, so we can plot them and see the answer emerge.

        :param e: the experiment"""

        # create the experimental parameter space
        eps = self.experiments(e)

        # only proceed if there's work to do
        if len(eps) > 0:
            nb = self.notebook()

            try:
                self.open()

                # submit an experiment at each point in the parameter space
                try:
                    for (ep, p) in eps:
                        j = self.runExperimentAsync(ep, p)
                        logger.info(f"Submitted job {j}")
                        nb.addPendingResult(p, j)
                except Exception as e:
                    logger.error(f'Exception when starting experiments: {e}')
            finally:
                # commit our pending results in the notebook
                nb.commit()
                self.close()

    def updateResults(self) -> int:
        """Update our results with any pending results that have completed since we
        last retrieved results from the cluster.

        :returns: the number of pending results completed by this call"""
        nb = self.notebook()

        # look for pending results if we're waiting for any
        n = 0
        if not nb.ready():
            # we have results to get
            try:
                self.open()

                # get all the results the cluster has available
                rcs = self.getPendingResults()

                # resolve pending results
                for rc in rcs:
                    # extract the experiment id
                    j = rc[Experiment.METADATA][EXPERIMENT_ID]
                    logger.info(f'Job {j} completed')

                    # resolve the result in the appropriate result set
                    try:
                        nb.resolvePendingResult(rc, j)
                    except KeyError as e:
                        # we were sent a result we don't recognise -- i.e., one
                        # that is not in any of our result sets
                        logger.error(f'Job {j} not recognised -- discarded')

                    # record that we retrieved the results for the given job
                    n = n + 1
            finally:
                # commit changes to the notebook
                nb.commit()
                self.close()

        return n


    # ---------- Accessing results ----------

    def wait(self, timeout: int =-1) -> bool:
        """Wait for all pending results in all result sets to be finished. If timeout is set,
        return after this many seconds regardless.

        :param timeout: timeout period in seconds (defaults to forever)
        :returns: True if all the results completed"""
        nb = self.notebook()
        if nb.numberOfAllPendingResults() > 0:
            # we've got pending results, wait for them
            timeWaited = 0
            while (timeout < 0) or (timeWaited < timeout):
                self.updateResults()
                if nb.numberOfAllPendingResults() == 0:
                    # no pending results left, we're complete
                    return True
                else:
                    # not done yet, calculate the waiting period
                    if timeout == -1:
                        # wait for the default waiting period
                        dt = self.WaitingTime
                    else:
                        # wait for the default waiting period or until the end of the timeout.
                        # whichever comes first
                        if (timeout - timeWaited) < self.WaitingTime:
                            dt = timeout - timeWaited
                        else:
                            dt = self.WaitingTime

                    # sleep for a while
                    time.sleep(dt)
                    timeWaited = timeWaited + dt

            # if we get here, the timeout expired, so do a final check
            # and then exit
            return (nb.numberOfAllPendingResults() == 0)

        else:
            # no results, so we got them all
            return True
