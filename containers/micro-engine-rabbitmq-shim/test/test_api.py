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
import time
import unittest
import pika
import requests
from epyc import Experiment
from epydemic import StochasticDynamics, SIR, ERNetwork


class TestAPI(unittest.TestCase):
    endpoint = "amqp://localhost:5672"
    retries = 5
    backoff = 5

    def setUp(self):
        # connect to the broker
        self._connection = None
        self._channel = None
        for i in range(self.retries):
            try:
                self._connection = pika.BlockingConnection(pika.URLParameters(self.endpoint))
                self._channel = self._connection.channel()
                break
            except Exception as e:
                print(f"Failed to connect ({e}); re-trying...")
                time.sleep(self.backoff)
        if self._connection is None:
            print(f"Failed to connect to {self._endpoint}")
            sys.exit(1)
        print(f"Connected to {self.endpoint}")

        # ensure the queues exist
        for ch in ["request", "result"]:
            self._channel.queue_declare(queue=ch)

    def testExperiment(self):
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
        self._channel.basic_publish(exchange='',
                                    routing_key="request",
                                    body=args)

        # read the result back
        # We need this loop because we need to be able to read the
        # expected one result message. It'd be better to refactor this
        # to use a proper event loop -- but that's then hard for termination
        # detection, perhaps.
        rc = None
        for i in range(self.retries):
            message, properties, body = self._channel.basic_get("result")
            if message is not None:
                rc = json.loads(body)
                break
            else:
                print("backoff")
                time.sleep(self.backoff)
        self.assertIsNotNone(rc)

        # check we got a valid results dict back
        self.assertIn(Experiment.PARAMETERS, rc)
        self.assertIn(Experiment.RESULTS, rc)
        self.assertIn(Experiment.METADATA, rc)

        # check for plausible experimental results
        # (we can't assume that an outbreak occurred)
        self.assertTrue(rc[Experiment.RESULTS][SIR.INFECTED] == 0)
        self.assertTrue(rc[Experiment.RESULTS][SIR.REMOVED] >= 0)


if __name__ == '__main__':
    unittest.main()
