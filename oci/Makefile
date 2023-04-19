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
include ./kubernetes.tfvars
OCI_USERNAME=$(OCI_TENANCY_NAMESPACE)/oracleidentitycloudservice/$(OCI_USER_EMAIL)

#ifneq ("$(wildcard $(TERRAFORM_OUTPUTS_FILE))", "")
include ./config.tfvars
#endif


# ---------- Tools ----------

TERRAFORM = terraform
KUBECTL = kubectl
OCICTL = oci
HELM = helm
RM = rm -fr
CHDIR = cd


# ---------- Constructed lists ----------

# Terraform
TERRAFORM_DIR = .terraform
TERRAFORM_VARIABLES = $(patsubst %.tfvars,--var-file=%.tfvars,$(VARIABLES))
TERRAFORM_OUTPUTS_FILE = config.tfvars

# OCI
OCI_SECRET = "ocirsecret"
OCI_SECRET_FILE = "oci-secret.yaml"
OCI_IMAGE_TAG = oracleidentitycloudservice/$(OCI_REPO)

# Kuberbetes
K8S_LOCAL_CONFIG = $(HOME)/.kube/config

# Helm
HELM_VARS = \
	--set ingress-nginx.enabled=false \
	--set cert-manager.enabled=false \
	--set components.certManager.enabled=false \
	--set components.engine.pods.containers.engine.image=$(OCI_IMAGE_TAG)/micro-engine:latest \
	--set components.engine.pods.containers.engine.imagePullSecrets=$(OCI_SECRET) \
	--set components.engine.pods.containers.engine.imagePullPolicy=Always \
	--set components.engine.pods.containers.shim.image=$(OCI_IMAGE_TAG)/micro-engine-rabbitmq-shim:latest \
	--set components.engine.pods.containers.shim.imagePullSecrets=$(OCI_SECRET) \
	--set components.engine.pods.containers.shim.imagePullPolicy=Always \
	--set components.gateway.pods.containers.gateway.image=$(OCI_IMAGE_TAG)/api-gateway:latest \
	--set components.gateway.pods.containers.gateway.imagePullSecrets=$(OCI_SECRET) \
	--set components.gateway.pods.containers.gateway.imagePullPolicy=Always


# ---------- Targets ----------

default:
	@make usage


# Part 0: Top-level targets

start:
	@make up
	@make authorise
	@make deploy

stop:
	@make undeploy
	@make down
	@make deauthorise
	@make reallyclean

# Part 1: Manage the deployment of the app

deploy: env $(OCI_SECRET_FILE)
	$(KUBECTL) create namespace $(NAMESPACE)
	$(CHDIR) ../helm && $(HELM) install $(HELM_RELEASE) \
		$(HELM_VARS) -n $(NAMESPACE) ./$(HELM_CHART)

undeploy: env
	$(HELM) uninstall $(HELM_RELEASE) -n $(NAMESPACE)
	-$(KUBECTL) delete namespace $(NAMESPACE)

dashboard: env
	(cd dashboard && make deploy)

# Part 2: Manage terraforming the Kubernetes cluster

up: env
	$(TERRAFORM) apply $(TERRAFORM_VARIABLES) -auto-approve
	$(TERRAFORM) output >$(TERRAFORM_OUTPUTS_FILE)

down: env
	$(TERRAFORM) destroy $(TERRAFORM_VARIABLES) -auto-approve
	$(RM) $(TERRAFORM_OUTPUTS_FILE)

$(OCI_SECRET_FILE): env
	$(KUBECTL) create secret docker-registry $(OCI_SECRET) \
		--docker-server=$(OCI_REGION).ocir.io \
		--docker-username=$(OCI_USERNAME) --docker-password=$(OCI_PASSWORD) \
		--docker-email=$(OCI_USER_EMAIL)
	$(KUBECTL) get secret $(OCI_SECRET) --output=yaml >$(OCI_SECRET_FILE)

# Part 3: Local authorisation to access the cluster

authorise: env
	$(OCICTL) ce cluster create-kubeconfig --token-version 2.0.0 \
		--cluster-id $(OCI_K8S_CLUSTER_OCID) --region $(OCI_REGION)  \
		--file $(K8S_LOCAL_CONFIG)

deauthorise:
	-$(RM) $(OCI_SECRET_FILE)
	-$(KUBECTL) delete namespace $(NAMESPACE)

# Part 4: Environment management

env: $(TERRAFORM_DIR)

$(TERRAFORM_DIR):
	$(TERRAFORM) init

clean:
	-$(RM) $(OCI_SECRET_FILE)
	-$(KUBECTL) delete namespace $(NAMESPACE)

reallyclean: clean
	$(RM) $(TERRAFORM_DIR) *.tfstate*


# ----- Usage -----

define HELP_MESSAGE
Main targets:
   make start        start the epyc compute server in a cluster
   make stop         stop the server

More detailed targets:
   make up           spin-up the Kubernetes cluster
   make down         spin-down the cluster
   make deploy       deploy the epyc server
   make undeploy     dismantle the server
   make dashboard    deploy and open a Kubernetes dashboard
   make authorise    authorise local kubectl client against the cluster
   make deauthorise  de-authorise the client
   make clean        clean-up deployment
   make reallyclean  clean-up local environment

endef
export HELP_MESSAGE

usage:
	@echo "$$HELP_MESSAGE"
