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

import json
import base64
import pickle
import cloudpickle
from flask_unittest import ClientTestCase
import micro_engine
from epyc import Experiment
from epydemic import StochasticDynamics, SIR, ERNetwork

class TestAPI(ClientTestCase):

    app = micro_engine.app

    def testUp(self, client):
        '''Test we can hit the default endpoint.'''
        res = client.get('/')
        self.assertStatus(res, 200)

    def testExperiment(self, client):
        '''Test we can submit an experiment and have it run successfully.'''

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

        # pickle the experiment and add to the parameters
        encoded = base64.b64encode(cloudpickle.dumps(e)).decode('ascii')
        params['_experiment_'] = encoded

        # make the request
        args = json.dumps(params)
        res = client.post('/api/v1/run', json=args)
        self.assertStatus(res, 200)

        # check we got a valid results dict back
        rc = res.json
        self.assertIn(Experiment.PARAMETERS, rc)
        self.assertIn(Experiment.RESULTS, rc)
        self.assertIn(Experiment.METADATA, rc)

        # check for plausible experimental results
        # (we can't assume that an outbreak occurred)
        self.assertTrue(rc[Experiment.RESULTS][SIR.INFECTED] == 0)
        self.assertTrue(rc[Experiment.RESULTS][SIR.REMOVED] >= 0)
