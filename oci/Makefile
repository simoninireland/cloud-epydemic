# Makefile to create a Kubernetes compute cluster on OCI
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

SOURCES = \
	provider.tf \
	variables.tf \
	compartment.tf \
	datasources.tf \
	vcn-module.tf \
	private-subnet.tf \
	privare-security-list.tf \
	public-subnet.tf \
	public-security-list.tf \
	node-pool.tf \
	cluster.tf \
	outputs.tf
VARIABLES = \
	credentials.tfvars \
	kubernetes.tfvars

NAMESPACE = cloudepydemic
HELM_RELEASE = demo
HELM_CHART = cloudepyc


# ---------- Environment ----------

include ./credentials.tfvars

OCI_USERNAME=$(OCI_TENANCY_NAMESPACE)/$(OCI_USER_EMAIL)


# ---------- Tools ----------

TERRAFORM = terraform
KUBECTL = kubectl
HELM = helm
RM = rm -fr
CHDIR = cd


# ---------- Constructed lists ----------

# Terraform
TERRAFORM_DIR = .terraform
TERRAFORM_VARIABLES = $(patsubst %.tfvars,--var-file=%.tfvars,$(VARIABLES))

# Helm
OCI_SECRET = "ocirsecret"
OCI_SECRET_FILE = "oci-secret.yaml"
#OCI_IMAGE_TAG = $(OCI_REGION).ocir.io/$(OCI_TENANCY_NAMESPACE)/$(OCI_REPO)
OCI_IMAGE_TAG = oracleidentitycloudservice/$(OCI_REPO)
HELM_VARS = \
	--set components.engine.pods.containers.engine.image=$(OCI_IMAGE_TAG)/micro-engine:latest \
	--set components.engine.pods.containers.engine.imagePullSecrets=$(OCI_SECRET) \
	--set components.engine.pods.containers.shim.image=$(OCI_IMAGE_TAG)/micro-engine-rabbitmq-shim:latest \
	--set components.engine.pods.containers.shim.imagePullSecrets=$(OCI_SECRET) \
	--set components.gateway.pods.containers.gateway.image=$(OCI_IMAGE_TAG)/api-gateway:latest \
	--set components.gateway.pods.containers.gateway.imagePullSecrets=$(OCI_SECRET)


# ---------- Targets ----------

up: env
	$(TERRAFORM) apply $(TERRAFORM_VARIABLES) -auto-approve

down: env
	$(TERRAFORM) destroy $(TERRAFORM_VARIABLES) -auto-approve

.PHONY: env
env: $(TERRAFORM_DIR)

$(TERRAFORM_DIR):
	$(TERRAFORM) init

$(OCI_SECRET): $(OCI_SECRET_FILE)

$(OCI_SECRET_FILE): env
	$(KUBECTL) create secret docker-registry $(OCI_SECRET) --docker-server=$(OCI_REGION).ocir.io  --docker-username=$(OCI_USERNAME) --docker-password=$(OCI_PASSWORD)  --docker-email=$(OCI_EMAIL)
	$(KUBECTL) get secret $(OCI_SECRET) --output=yaml >$(OCI_SECRET_FILE)

deploy: env $(OCI_SECRET)
	$(KUBECTL) create namespace $(NAMESPACE)
	$(CHDIR) ../helm && $(HELM) install $(HELM_RELEASE) $(HELM_VARS) -n $(NAMESPACE) ./$(HELM_CHART)

undeploy: env
	$(HELM) uninstall $(HELM_RELEASE) -n $(NAMESPACE)
	make clean

clean:
	-$(KUBECTL) delete secret $(OCI_SECRET)
	-$(RM) $(OCI_SECRET_FILE)
	-$(KUBECTL) delete namespace $(NAMESPACE)

reallyclean: clean
	$(RM) $(TERRAFORM_DIR) *.tfstate*
