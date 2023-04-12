# Makefile for demo notebooks
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

NOTEBOOKS = \
	epidemic-threshold.ipynb

NAMESPACE = cloudepydemic


# ---------- Tools ----------

# Base tools
PYTHON = python
JUPYTER = jupyter
KUBECTL = kubectl
CHDIR = cd
RM = rm -fr

# Virtual environment
VENV = venv3
REQUIREMENTS = requirements.txt

# Demo environment
INGRESS_IP = $(shell echo `$(KUBECTL) get ingress -n $(NAMESPACE) -o json | jq '.items[0].status.loadBalancer.ingress[0].ip'`)
ENV = \
	EPYDEMIC_API_GATEWAY_ENDPOINT=http://$(INGRESS_IP)/ \
	PYTHONPATH=../containers/lib


# ---------- Constructed commands ----------

ACTIVATE = . $(VENV)/bin/activate


# ---------- Targets ----------

.PHONY: env
env: $(VENV)
$(VENV):
	$(PYTHON) -m venv venv3
	$(ACTIVATE) && pip install -U pip wheel
	$(ACTIVATE) && pip install -r $(REQUIREMENTS)

.PHONY: live
live: env
	$(ACTIVATE) && $(ENV) $(JUPYTER) notebook

.PHONY: reallyclean
reallyclean:
	$(RM)  $(VENV)
