# Makefile for testing (NOT building) web API gateway
#
# Copyright (C) 2023 Simon Dobson
#
# This file is part of cloud-epydemic, network simulation as a service
#
# cloud-epydemic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
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

SOURCES = api_engine/api.py
NAMESPACE = cloudepydemic


# ---------- Tools ----------

# Base tools
PYTHON = python
KUBECTL = kubectl
CHDIR = cd
RM = rm -fr

# Virtual environment
VENV = venv3
REQUIREMENTS = requirements.txt
DEV_REQUIREMENTS = dev-requirements.txt

# Test environment
INGRESS_IP = $(shell echo `$(KUBECTL) get ingress -n $(NAMESPACE) -o json | jq '.items[0].status.loadBalancer.ingress[0].ip'`)
ENGINE_POD = $(shell echo `$(KUBECTL) get pod -n $(NAMESPACE) --selector app=demo,component=engine -o json | jq '.items[0].metadata.name'`)
GATEWAY_POD = $(shell echo `$(KUBECTL) get pod -n $(NAMESPACE) --selector app=demo,component=gateway-server -o json | jq '.items[0].metadata.name'`)
ENV = \
	EPYDEMIC_API_GATEWAY_ENDPOINT=http://$(INGRESS_IP)/ \
	PYTHONPATH=../lib


# ---------- Constructed commands ----------

ACTIVATE = . $(VENV)/bin/activate
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
	$(ACTIVATE) && $(ENV) $(RUN_TESTS)

engine-logs:
	$(KUBECTL) logs $(ENGINE_POD) --all-containers -n $(NAMESPACE)

gateway-logs:
	$(KUBECTL) logs $(GATEWAY_POD) -n $(NAMESPACE)

engine-login:
	$(KUBECTL) exec -it $(ENGINE_POD) -n $(NAMESPACE) -- sh

gateway-login:
	$(KUBECTL) exec -it $(GATEWAY_POD) -n $(NAMESPACE) -- sh

.PHONY: clean
clean:
	$(CONTAINERS) stop

.PHONY: reallyclean
reallyclean: clean
	$(RM) $(VENV)
