# API tests using the CloudLab client interface
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

import unittest
from epyc import Experiment, LabNotebook
from cloudepyc import CloudLab
from epydemic import StochasticDynamics, SIR, ERNetwork


class TestCloudLab(unittest.TestCase):
    endpoint = "http://localhost:5000"

    def setUp(self):
        self._nb = LabNotebook()
        self._lab = CloudLab(self.endpoint, notebook=self._nb)

    def testSubmitExperiment(self):
        '''Test we can submit an experiment to the engine.'''

        # a simple parameter set, above the epidemic threshold
        self._lab[SIR.P_INFECT] = 0.3
        self._lab[SIR.P_INFECTED] = 0.01
        self._lab[SIR.P_REMOVE] = 0.05
        self._lab[ERNetwork.N] = 1000
        self._lab[ERNetwork.KMEAN] = 5

        # create the experiment
        model = SIR()
        e = StochasticDynamics(model, ERNetwork())

        # run the experiment
        self._lab.runExperiment(e)

        # check we have a single pending result
        self.assertEqual(self._nb.numberOfAllPendingResults(), 1)

    def testSubmitAndRetrieveExperiments(self):
        '''Test we can submit an set of experiments and get the result.'''

        # a parameter set
        self._lab[SIR.P_INFECT] = 0.3
        self._lab[SIR.P_INFECTED] = [0.001, 0.01, 1.0]
        self._lab[SIR.P_REMOVE] = 0.05
        self._lab[ERNetwork.N] = 1000
        self._lab[ERNetwork.KMEAN] = 5

        # create the experiment
        model = SIR()
        e = StochasticDynamics(model, ERNetwork())

        # run the experiment
        self._lab.runExperiment(e)

        # check we have three pending result
        self.assertEqual(self._nb.numberOfAllPendingResults(), 3)

        # retrieve all the results
        CloudLab.WaitingTime = 5
        self._lab.wait()
        self.assertEqual(self._nb.numberOfAllPendingResults(), 0)
