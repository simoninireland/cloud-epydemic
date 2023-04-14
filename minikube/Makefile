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

# Minikube
MINIKUBE_OPTIONS = \
	--memory=16384 \
	--cpus=4

# Helm
HELM_RELEASE = demo
HELM_CHART = cloudepyc
HELM_VARS = \
	--set ingress-nginx.enabled=false \
	--set cert-manager.enabled=false \
	--set components.certManager.enabled=false

# Cert-manager
CERT_MANAGER_RELEASE = cert-manager
CERT_MANAGER_HELM_CHART = jetstack/cert-manager
CERT_MANAGER_VERSION = v1.11.0
CERT_MANAGER_DEPLOY = https://github.com/cert-manager/cert-manager/releases/download/$(CERT_MANAGER_VERSION)/cert-manager.crds.yaml


# ---------- Targets ----------

start:
	$(MINIKUBE) start $(MINIKUBE_OPTIONS)
	$(MINIKUBE) addons enable metrics-server
	$(MINIKUBE) addons enable ingress
	-$(KUBECTL) create namespace $(NAMESPACE)
	$(CHDIR) ../helm && $(HELM) dependencies update ./$(HELM_CHART)
	$(HELM) install $(CERT_MANAGER_RELEASE) $(CERT_MANAGER_HELM_CHART) \
		-n $(NAMESPACE) --version $(CERT_MANAGER_VERSION) \
		--set installCRDs=true
	nohup $(MINIKUBE) dashboard &

stop:
	$(MINIKUBE) stop

deploy:
	$(CHDIR) ../helm && $(HELM) install $(HELM_RELEASE) $(HELM_VARS)  -n $(NAMESPACE) ./$(HELM_CHART)

upgrade:
	$(CHDIR) ../helm && $(HELM) upgrade $(HELM_RELEASE) $(HELM_VARS) -n $(NAMESPACE) ./$(HELM_CHART)

undeploy:
	$(HELM) delete $(HELM_RELEASE) -n $(NAMESPACE)

clean:
	-$(HELM) delete $(CERT_MANAGER_RELEASE) -n $(NAMESPACE)
	-$(KUBECTL) delete namespace $(NAMESPACE)
	-$(KUBECTL) delete -f $(CERT_MANAGER_DEPLOY)

reallyclean:
	$(MINIKUBE) delete
