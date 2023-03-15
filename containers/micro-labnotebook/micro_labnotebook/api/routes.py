# API top-level routes
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
from flask import request, jsonify
from micro_labnotebook import app


@app.route('/')
def hello():
    '''Default endpoint just to check that the server is responding.'''
    return "cloud-epydemic lab notebook microservice is running."

@app.route('/api/v1/run', methods=['POST'])
def runExperiment():
    '''The experiment submission endpoint.

    The call expects a JSON object containing a set of parameters for
    an experiment and a single key '_experiment_' containing a Base64-
    and ASCII-encoded pickled Python object represented the experiment
    to be run. It returns a JSON object containing the results dict
    resulting from running the experiment, which will include metadata
    and other information.

    '''
    params = json.loads(request.json)

    # extract the experiment object
    encoded = params['_experiment_'].encode('ascii')
    e = pickle.loads(base64.b64decode(encoded, validate=True))
    del params['_experiment_']

    # run the experiment
    rc = e.set(params).run()
    return rc
