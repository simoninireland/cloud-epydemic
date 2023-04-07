# Makefile for testing Kubernetes deployment
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

NAMESPACE = cloudepydemic


# ---------- Tools ----------

MINIKUBE = minikube
KUBECTL = kubectl
HELM = helm
CHDIR = cd


# ---------- Options ----------

MINIKUBE_OPTIONS = \
	--memory=16384 \
	--cpus=4
HELM_CHART = cloudepyc


# ---------- Targets ----------

.PHONY: start
start:
	$(MINIKUBE) start $(MINIKUBE_OPTIONS)
	$(MINIKUBE) addons enable metrics-server
	$(MINIKUBE) addons enable ingress
	$(KUBECTL) create namespace $(NAMESPACE)
	nohup $(MINIKUBE) dashboard &

.PHONY: stop
stop:
	$(MINIKUBE) stop

.PHONY: deploy
deploy:
	$(CHDIR) ../helm && $(HELM) install demo -n $(NMAMESPACE) ./$(HELM_CHART)

.PHONY: clean
clean: stop
	$(KUBECTL) delete ns $(NAMESPACE)

.PHONY: reallyclean
reallyclean:
	$(MINIKUBE) delete
