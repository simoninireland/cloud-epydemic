# Services exported from engine -- not the full API
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
import base64
import pickle
import logging
import logging.handlers
from epyc import Experiment


# Grab environment variables
logLevel = os.environ.get("EPYDEMIC_LOGLEVEL", logging.INFO)

EXPERIMENT_ID = "epyc.experiment.id"

# Set up logging
logger = logging.getLogger(__name__)
logger.setLevel(logLevel)
ch = logging.StreamHandler()
logger.addHandler(ch)


def runExperiment(submission):
    '''Run an experiment.

    The parameters contain the usual experimental parameters for a
    single experiment, plus a special "_experiment_" value containing
    a base64-encoded pickled epyc.Experiment object that defines
    the experiment to be run.

    :param params: experimental parameters
    :returns: the results dict'''
    logger.info("API runExperiment()")

    # extract the experiment ID
    id = submission['experiment-id']

    # extract and reconstruct the experiment object
    encoded = submission['experiment'].encode('ascii')
    e = pickle.loads(base64.b64decode(encoded, validate=True))

    # extract the parameters
    params = submission['params']

    # run the experiment
    rc = e.set(params).run()
    logger.info("rc")
    logger.info(str(rc))

    # add the experiment identifier to the result metadata
    if Experiment.METADATA in rc:
        rc[Experiment.METADATA][EXPERIMENT_ID] = id

    # return the results dict
    return rc
