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
from flask_unittest import ClientTestCase
from epyc import Experiment
from epydemic import StochasticDynamics, SIR, ERNetwork

# Use the master API description
os.environ["EPYDEMIC_OPENAPI"] = "../../lib/api.yaml"
import api_gateway


class TestAPI(ClientTestCase):

    app = api_gateway.app

    def testUp(self, client):
        '''Test we can hit the default endpoint.'''
        res = client.get('/')
        self.assertStatus(res, 200)
