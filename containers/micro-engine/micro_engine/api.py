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

import base64
import pickle


def runExperiment(params):
    '''Run an experiment.

    The parameters contain the usual experimental parameters for a
    single experiment, plus a special "_experiment_" value containing
    a base64-encoded pickled epyc.Experiment object that defines
    the experiment to be run.

    @param params: experimental parameters
    @returns: the results dict'''

    # extract and reconstruct the experiment object
    encoded = params['_experiment_'].encode('ascii')
    e = pickle.loads(base64.b64decode(encoded, validate=True))
    del params['_experiment_']

    # run the experiment
    rc = e.set(params).run()

    # return the results dict
    return rc


# ---------- Unimplemented API methods----------

def runExperimentAsync(params):
    raise NotImplementedError("runExperimentAync() not available")

def getPendingResult(id):
    raise NotImplementedError("getPendingfResult() not available")

def getPendingResults():
    raise NotImplementedError("getPendingfResults() not available")
