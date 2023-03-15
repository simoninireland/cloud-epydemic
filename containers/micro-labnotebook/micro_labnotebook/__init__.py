# Flask server initialisation
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
import connexion
from epyc import JSONLabNotebook


# Application object
conn = connexion.App(__name__, specification_dir='./')
app = conn.app

# Add APIs
conn.add_api('api.yaml')

# Checking endpoint (not part of the defined API)
@conn.route('/')
def hello():
    '''Default endpoint just to check that the server is responding.'''
    return "cloud-epydemic lab notebook microservice is running."

# Create lab notebook in the appropriate data directory
dir = os.environ.get("EPYDEMIC_DATA", f"{home}/data")
name = os.environ.get("EPYDEMIC_LABNOTEBOOK_NAME", "micro-labnotebook.json")
fn = f"{dir}/{name}"
nb = JSONLabNotebook(name=fn)
