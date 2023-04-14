# Makefile for compute cluster on Digital Ocean
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


# ---------- Notes ----------

# To create the cluster we need to terraform it and add the nginx
# ingress, which Digitqal Ocean doesn't have by default. We
# authenticate against the provider and grabn the cluster connection
# information for later.
#
# Installing nginx is tricky within helm, so we do it manually.
#
# We disable the nginx-ingress and cert-manager sub-charts under
# cloudepyc because of the manual installation.


# ---------- Sources ----------

TERRAFORM_SRC = \
	main.tf \
	platform.tf \
	variables.tf

VARIABLES = \
	credentials.tfvars \
	kubernetes.tfvars

NAMESPACE = cloudepydemic
HELM_RELEASE = demo
HELM_CHART = cloudepyc


# ---------- Environment ----------

include ./credentials.tfvars
include ./kubernetes.tfvars


# ---------- Tools ----------

TERRAFORM = terraform
KUBECTL = kubectl
DOCTL = doctl
HELM = helm
RM = rm -fr
CHDIR = cd


# ---------- Constructed lists ----------

# Terraform
TERRAFORM_DIR = .terraform
TERRAFORM_VARIABLES = $(patsubst %.tfvars,--var-file=%.tfvars,$(VARIABLES))

# nginx ingress
NGINX_VERSION = v1.1.1
NGINX_DEPLOY = https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-$(NGINX_VERSION)/deploy/static/provider/do/deploy.yaml

# Helm
DO_IMAGE_TAG = registry.digitalocean.com/$(DO_REPO)
HELM_VARS = \
	--set ingress-nginx.enabled=false \
	--set cert-manager.enabled=false \
	--set components.certManager.enabled=false \
	--set components.engine.pods.containers.engine.image=$(DO_IMAGE_TAG)/micro-engine:latest \
	--set components.engine.pods.containers.engine.imagePullPolicy=Always \
	--set components.engine.pods.containers.shim.image=$(DO_IMAGE_TAG)/micro-engine-rabbitmq-shim:latest \
	--set components.engine.pods.containers.shim.imagePullPolicy=Always \
	--set components.gateway.pods.containers.gateway.image=$(DO_IMAGE_TAG)/api-gateway:latest \
	--set components.gateway.pods.containers.gateway.imagePullPolicy=Always


# ---------- Targets ----------

up: env
	$(TERRAFORM) apply $(TERRAFORM_VARIABLES) -auto-approve
	$(DOCTL) kubernetes cluster kubeconfig save $(K8S_APPLICATION_NAME)

down:
	$(TERRAFORM) destroy $(TERRAFORM_VARIABLES) -auto-approve

.PHONY: env
env: $(TERRAFORM_DIR)

$(TERRAFORM_DIR):
	$(TERRAFORM) init
	$(DOCTL) auth init -t $(DO_TOKEN)
	$(DOCTL) registry kubernetes-manifest | $(KUBECTL) apply -f -
	$(KUBECTL) apply -f $(NGINX_DEPLOY)
	-$(KUBECTL) create namespace $(NAMESPACE)

deploy: env
	$(CHDIR) ../helm && $(HELM) install $(HELM_RELEASE) $(HELM_VARS) -n $(NAMESPACE) ./$(HELM_CHART)

upgrade:
	$(CHDIR) ../helm && $(HELM) upgrade $(HELM_RELEASE) $(HELM_VARS) -n $(NAMESPACE) ./$(HELM_CHART)

undeploy:
	$(HELM) uninstall $(HELM_RELEASE) -n $(NAMESPACE)

clean:
	-$(KUBECTL) delete -f $(NGINX_DEPLOY)
	-$(KUBECTL) delete namespace $(NAMESPACE)

reallyclean:
	$(RM) $(TERRAFORM_DIR) *.tfstate*
