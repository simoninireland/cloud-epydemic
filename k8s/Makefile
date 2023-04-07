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
APP = $(NAMESPACE).yaml
COMPONENTS= \
	config.yaml \
	ca.yaml \
	broker.yaml \
	micro-engine.yaml \
	api-gateway.yaml \
	ingress.yaml
SOURCES = $(APP) $(COMPONENTS)


# ---------- Resources----------

# RabbitMQ operator
RABBITMQ_OPERATOR = https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml

# cert-manager operator
CERTMANAGER_OPERATOR = https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

# Minikube options
MINIKUBE_OPTIONS = \
	--memory=16384 \
	--cpus=4


# ---------- Tools ----------

XARGS = xargs -n 1
MINIKUBE = minikube
KUBECTL = kubectl
HELM = helm


# ---------- Targets ----------

.PHONY: start
start:
	$(MINIKUBE) start $(MINIKUBE_OPTIONS)
	$(MINIKUBE) addons enable metrics-server
	$(MINIKUBE) addons enable ingress
	$(KUBECTL) apply -f $(RABBITMQ_OPERATOR)
	$(KUBECTL) apply -f $(CERTMANAGER_OPERATOR)
	nohup $(MINIKUBE) dashboard &

.PHONY: stop
stop:
	$(MINIKUBE) stop

deploy:
	echo $(SOURCES) | $(XARGS) $(KUBECTL) apply -f

clean: stop
	$(KUBECTL) delete ns $(NAMESPACE)

reallyclean:
	$(MINIKUBE) delete
