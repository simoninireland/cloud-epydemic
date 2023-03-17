# Ompute lab to connect to a cloud-based compute engine
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

import time
import sys
import logging
from ipyparallel import Client, DirectView    # type: ignore
from contextlib import AbstractContextManager
from epyc import Logger, Lab, LabNotebook, Experiment


logger = logging.getLogger(Logger)


class CloudLab(Lab):
    """A :class:`Lab` running on a cloud-based microservices
    compue cluster.

    Experiments are submitted to engines in the cluster for execution
    in parallel, with the experiments being performed asynchronously.
    Combined with a persistent :class:`LabNotebook`, this allows for
    fully decoupled access to an on-going computational experiment
    with piecewise retrieval of results.

    This class requires a cluster to already be set up and running, configured
    for persistent access, with access to the necessary code and libraries,
    and with appropriate security information available to the client.

    """

    def __init__(self, url, notebook: LabNotebook = None)
        """Create an empty lab attached to the given cluster.#

        :param url: API endpoint
        :param notebook: the notebook used to results (defaults to an empty :class:`LabNotebook`)"""
        super().__init__(notebook)
        self._endpoint = url


    # ---------- Basic API ----------



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
        self.open()
        return self._client[:].sync_imports(quiet=quiet)


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
                # connect to the cluster
                self.open()

                # configure a load balanced view of the cluster
                view = self._client.load_balanced_view()
                view.set_flags(retries=self.Retries)

                # submit an experiment at each point in the parameter space to the cluster
                try:
                    for (ep, p) in eps:
                        rc = view.apply_async(lambda ep: ep[0].set(ep[1]).run(), (ep, p))
                        ids = rc.msg_ids
                        logger.info(f'Started jobs {ids}')
                        nb.addPendingResult(p, ids[0])

                        # there seems to be a race condition in submitting jobs,
                        # whereby jobs get dropped if they're submitted too quickly
                        time.sleep(0.01)
                except Exception as e:
                    logger.error(f'Exception when starting experiments: {e}')
            finally:
                # commit our pending results in the notebook
                nb.commit()
                self.close()

    def updateResults(self, purge : bool = False) -> int:
        """Update our results within any pending results that have completed since we
        last retrieved results from the cluster. Optionally purges any jobs that
        have crashed, which can be due to engine failure within the
        cluster. This prevents individual crashes blocking the retrieval of other jobs.

        :param purge: (optional) cancel any jobs that have crashed (defaults to False)
        :returns: the number of pending results completed at this call"""
        nb = self.notebook()

        # look for pending results if we're waiting for any
        n = 0
        if not nb.ready():
            # we have results to get
            try:
                crashed = []
                self.open()
                for j in set(nb.allPendingResults()):
                    try:
                        # query the status of a job
                        #print('Test status of {j}'.format(j=j))
                        status = self._client.result_status(j, status_only=False)

                        # add all completed jobs to the notebook
                        if j in status['completed']:
                            r = status[j]
                            logger.info(f'Job {j} completed')

                            # resolve the result in the appropriate result set
                            nb.resolvePendingResult(r, j)

                            # record that we retrieved the results for the given job
                            n = n + 1

                            # purge the completed job from the cluster
                            self._client.purge_hub_results(j)
                    except Exception as e:
                        # report the exception and carry on, recording the job as crashed
                        print(e, file=sys.stderr)
                        crashed.append(j)

                # purge any crashed jobs if requested
                if purge and len(crashed) > 0:
                    for j in crashed:
                        nb.cancelPendingResult(j)
                        self._client.purge_hub_results(j)
            finally:
                # commit changes to the notebook and close the connection
                nb.commit()
                self.close()

        return n


    # ---------- Accessing results ----------

    def wait(self, timeout: int =-1) -> bool:
        """Wait for all pending results in all result sets to be finished. If timeout is set,
        return after this many seconds regardless.

        :param timeout: timeout period in seconds (defaults to forever)
        :returns: True if all the results completed"""

        # we can't use pyparallel.Client.wait() for this, because that
        # method only works for cases where the Client object is the one that
        # submitted the jobs to the cluster hub -- and therefore has the
        # necessary data structures to perform synchronisation. This isn't the
        # case for us, as one of the main goals of epyc is to support disconnected
        # operation, which implies a different Client object retrieving results
        # than the one that submitted the jobs in the first place. This is
        # unfortunate, but understandable given the typical use cases for
        # Client objects in pyparallel.
        #
        # Instead. we have to code around a little busily. The ClusterLab.WaitingTime
        # global sets the latency for waiting, and we repeatedly wait for this amount
        # of time before updating the results. The latency value essentially controls
        # how busy this process is: given that most simulations are expected to
        # be long, a latency in the tens of seconds feels about right as a default
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
