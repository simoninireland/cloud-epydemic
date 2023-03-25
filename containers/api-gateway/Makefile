# Makefile for testing (NOT building) web API gateway
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

# ---------- Sources ----------

SOURCES = \
	api_engine.api.py

TEST_APP_INSTANCE = micro_engine:app


# ---------- Tools ----------

# Base tools
PYTHON = python
FLASK = flask
CHDIR = cd
RM = rm -fr

# Environment
VENV = venv3
REQUIREMENTS = requirements.txt
DEV_REQUIREMENTS = dev-requirements.txt


# ---------- Constructed commands ----------

ACTIVATE = . $(VENV)/bin/activate
CONTAINERS = test/containers.sh
RUN_TESTS = $(PYTHON) -m unittest discover -s test


# ---------- Targets ----------

.PHONY: env
env: $(VENV)
$(VENV):
	$(PYTHON) -m venv venv3
	$(ACTIVATE) && pip install -U pip wheel
	$(ACTIVATE) && pip install -r $(REQUIREMENTS) && pip install -r $(DEV_REQUIREMENTS)

.PHONY: test
test: env
	$(ACTIVATE) && $(RUN_TESTS)

.PHONY: reallyclean
reallyclean:
	$(RM) $(VENV)
