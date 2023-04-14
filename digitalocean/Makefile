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

# Helm
DO_IMAGE_TAG = registry.digitalocean.com/$(DO_REPO)
HELM_VARS = \
	--set components.engine.pods.containers.engine.image=$(DO_IMAGE_TAG)/micro-engine:latest \
	--set components.engine.pods.containers.engine.imagePullPolicy=Always \
	--set components.engine.pods.containers.shim.image=$(DO_IMAGE_TAG)/micro-engine-rabbitmq-shim:latest \
	--set components.engine.pods.containers.shim.imagePullPolicy=Always \
	--set components.gateway.pods.containers.gateway.image=$(DO_IMAGE_TAG)/api-gateway:latest \
	--set components.gateway.pods.containers.gateway.imagePullPolicy=Always


# ---------- Targets ----------

up: env
	$(TERRAFORM) apply $(TERRAFORM_VARIABLES) -auto-approve

down: env
	$(TERRAFORM) destroy $(TERRAFORM_VARIABLES) -auto-approve

.PHONY: env
env: $(TERRAFORM_DIR)

$(TERRAFORM_DIR):
	$(TERRAFORM) init
	$(DOCTL) auth init -t $(DO_TOKEN)
	$(DOCTL) registry kubernetes-manifest | $(KUBECTL) apply -f -

deploy: env
	-$(KUBECTL) create namespace $(NAMESPACE)
	$(CHDIR) ../helm && $(HELM) install $(HELM_RELEASE) $(HELM_VARS) -n $(NAMESPACE) ./$(HELM_CHART)

upgrade:
	$(CHDIR) ../helm && $(HELM) upgrade $(HELM_RELEASE) $(HELM_VARS) -n $(NAMESPACE) ./$(HELM_CHART)

undeploy: env
	$(HELM) uninstall $(HELM_RELEASE) -n $(NAMESPACE)
	make clean

clean:
	-$(KUBECTL) delete namespace $(NAMESPACE)

reallyclean:
	$(RM) $(TERRAFORM_DIR) *.tfstate*
