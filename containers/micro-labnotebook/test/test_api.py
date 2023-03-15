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

from flask_unittest import ClientTestCase
import micro_labnotebook
from epyc import Experiment, LabNotebook
from epydemic import StochasticDynamics, SIR, ERNetwork

class TestAPI(ClientTestCase):

    app = micro_labnotebook.app

    def testUp(self, client):
        '''Test we can hit the default endpoint.'''
        res = client.get('/')
        self.assertStatus(res, 200)

    def testAddResults(self, client):
        '''Test we can add results.'''

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

        # run the experiment
        rc = e.set(params).run()

        # submit the results
        args = dict(
            resultset=LabNotebook.DEFAULT_RESULTSET,
            results=rc
        )
        res = client.post('/api/v1/addResult', json=args)
        self.assertStatus(res, 200)
