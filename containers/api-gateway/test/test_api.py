# API tests
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
import json
import base64
import pickle
import cloudpickle
import time
import unittest
import requests
from epyc import Experiment
from epydemic import StochasticDynamics, SIR, ERNetwork


EXPERIMENT_ID = "epyc.experiment.id"

class TestAPI(unittest.TestCase):
    endpoint = "http://localhost:5000"

    def testUp(self):
        '''Test we can hit the default endpoint.'''
        res = requests.get(self.endpoint)
        self.assertEqual(res.status_code, 200)

    def testSubmitExperiment(self):
        '''Test we can submit an experiment to the engine.'''

        # a simple parameter set, above the epidemic threshold
        params = dict()
        params[SIR.P_INFECT] = 0.3
        params[SIR.P_INFECTED] = 0.01
        params[SIR.P_REMOVE] = 0.05
        params[ERNetwork.N] = 1000
        params[ERNetwork.KMEAN] = 5

        # create the experiment
        model = SIR()
        e = StochasticDynamics(model, ERNetwork())

        # construct a submission
        submission = dict()

        # pickle the experiment and add to the parameters
        encoded = base64.b64encode(cloudpickle.dumps(e)).decode('ascii')
        submission['experiment'] = encoded

        # add the identifier
        submission['experiment-id'] = "My experiment"

        # add the parameters
        submission['params'] = params

        # make the request
        res = requests.post(f"{self.endpoint}/api/v1/runExperimentAsync", json=submission)
        self.assertEqual(res.status_code, 200)

    def testSubmitAndRetrieveExperiment(self):
        '''Test we can submit an experiment and get the result.'''

        # a simple parameter set, above the epidemic threshold
        params = dict()
        params[SIR.P_INFECT] = 0.3
        params[SIR.P_INFECTED] = 0.01
        params[SIR.P_REMOVE] = 0.05
        params[ERNetwork.N] = 1000
        params[ERNetwork.KMEAN] = 5

        # create the experiment
        model = SIR()
        e = StochasticDynamics(model, ERNetwork())

        # construct a submission
        submission = dict()

        # pickle the experiment and add to the parameters
        encoded = base64.b64encode(cloudpickle.dumps(e)).decode('ascii')
        submission['experiment'] = encoded

        # add the identifier
        submission['experiment-id'] = "My experiment"

        # add the parameters
        submission['params'] = params

        # make the request
        res = requests.post(f"{self.endpoint}/api/v1/runExperimentAsync", json=submission)
        self.assertEqual(res.status_code, 200)

        # wait a bit
        time.sleep(5)

        # retrieve the results
        res = requests.get(f"{self.endpoint}/api/v1/getPendingResults")
        self.assertEqual(res.status_code, 200)
