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
import tempfile
from flask import Flask
from flask_login import LoginManager
from flask_httpauth import HTTPTokenAuth


# Instanciate all the extensions
login = LoginManager()
login.login_view='auth.login'
tokenauth = HTTPTokenAuth()


# Load configuration from environment
class Config:
    # Web forms and cookies
    SECRET_KEY = os.environ.get('SECRET_KEY') or os.urandom(32)


# Application object
app = Flask(__name__)
app.config.from_object(Config)
login.init_app(app)


# import all the API endpoints
import micro_labnotebook.api
