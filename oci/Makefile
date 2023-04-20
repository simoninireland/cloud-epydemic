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

# ---------- Notes ----------

# "make start" will bring up a cluster and deploy to it. "make stop"
# will remove the app and tear-down the cluster. These are the only
# targets typically needed, but tghere are lots of others, one per
# phase of the (un)deployment for more flexible control (and
# debugging).

# A cloudepyc.ClusterLab pointed at https://$(SERVICE).$(DOMAIN)
# should connect to the compute cluste over TLS.

# cert-manager is used to manage TLS certificates. This also needs to
# be installed before anytihng else, and /has/ to live in its own
# namespace -- otherwise cert issuance hangs silently.


# ---------- Sources ----------

# Terraform files
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

# Kubernetes
NAMESPACE = cloudepydemic
HELM_RELEASE = demo
HELM_CHART = cloudepyc

# DNS for the service and its TLS certificates
DOMAIN = epydemic.org
SERVICE = cloud
EMAIL = simoninireland@gmail.com


# ---------- Environment ----------

include ./credentials.tfvars
include ./kubernetes.tfvars

#ifneq ("$(wildcard $(TERRAFORM_OUTPUTS_FILE))", "")
include ./config.tfvars
#endif


# ---------- Tools ----------

TERRAFORM = terraform
KUBECTL = kubectl
OCICTL = oci
JQ = jq
HELM = helm
RM = rm -fr
CHDIR = cd


# ---------- Configuration ----------

# Terraform
TERRAFORM_DIR = .terraform
TERRAFORM_VARIABLES = $(patsubst %.tfvars,--var-file=%.tfvars,$(VARIABLES))
TERRAFORM_OUTPUTS_FILE = config.tfvars

# cert-manager
CERT_MANAGER_REPO = https://charts.jetstack.io
CERT_MANAGER_RELEASE=$(HELM_RELEASE)-cert-manager
CERT_MANAGER_CHART = cert-manager/cert-manager
CERT_MANAGER_CHART_VERSION = v1.11.1
CERT_MANAGER_NAMESPACE = cert-manager

# Dashboard
DASHBOARD_REPO = https://kubernetes.github.io/dashboard/
DASHBOARD_RELEASE = $(HELM_RELEASE)-dashboard
DASHBOARD_CHART = kubernetes-dashboard/kubernetes-dashboard
DASHBOARD_NAMESPACE = kubernetes-dashboard
DASHBOARD_POD = $(shell $(KUBECTL) get pods -n default -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o json | $(JQ) '.items[0].metadata.name')

# OCI
OCI_SECRET = "ocirsecret"
OCI_SECRET_FILE = "oci-secret.yaml"
OCI_IMAGE_TAG = oracleidentitycloudservice/$(OCI_REPO)
OCI_USERNAME=$(OCI_TENANCY_NAMESPACE)/oracleidentitycloudservice/$(OCI_USER_EMAIL)

# Kuberbetes
K8S_LOCAL_CONFIG = $(HOME)/.kube/config

# Helm
HELM_VARS = \
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
	@make authenticate
	@make deploy-cert-manager
	@make deploy

stop:
	@make undeploy
	@make undeploy-cert-manager
	@make down
	@make deauthenticate
	@make reallyclean

# Part 1: Manage the deployment of the app

deploy: env $(OCI_SECRET_FILE)
	$(CHDIR) ../helm && $(HELM) install $(HELM_RELEASE) \
		$(HELM_VARS) ./$(HELM_CHART) \
		-n $(NAMESPACE) --create-namespace

upgrade: env
	$(CHDIR) ../helm && $(HELM) upgrade $(HELM_RELEASE) \
		$(HELM_VARS) ./$(HELM_CHART) -n $(NAMESPACE)

undeploy: env
	$(HELM) uninstall $(HELM_RELEASE) -n $(NAMESPACE)
	-$(KUBECTL) delete namespace $(NAMESPACE)

# Part 1a: Manage the auxiliary services needed by OCI

deploy-cert-manager: env
	$(HELM) repo add cert-manager $(CERT_MANAGER_REPO)
	$(HELM) repo update cert-manager
	$(HELM) install $(CERT_MANAGER_RELEASE) \
		$(CERT_MANAGER_CHART) --version $(CERT_MANAGER_CHART_VERSION) \
		--set installCRDs=true \
		-n $(CERT_MANAGER_NAMESPACE) --create-namespace

undeploy-cert-manager: env
	-$(HELM) uninstall $(CERT_MANAGER_RELEASE) -n $(CERT_MANAGER_NAMESPACE)
	-$(KUBECTL) delete namespace $(CERT_MANAGER_NAMESPACE)

deploy-dashboard: env
	$(HELM) install $(DASHBOARD_RELEASE) $(DASHBOARD_CHART) \
		-n $(DASHBOARD_NAMESPACE) --create-namespace \
		--set resources.limits.cpu=200m
	$(KUBECTL) apply -f dashboard.yaml -n $(DASHBOARD_NAMESPACE)
	$(KUBECTL) create token admin-user -n $(DASHBOARD_NAMESPACE)

undeploy-dashboard: env
	-$(HELM) uninstall $(DASHBOARD_RELEASE) -n $(DASHBOARD_NAMESPACE)
	-$(KUBECTL) delete namespace $(DASHBOARD_NAMESPACE)
	-$(KUBECTL) delete -f dashboard.yaml

# Part 2: Manage terraforming the Kubernetes cluster

up: env
	$(TERRAFORM) apply $(TERRAFORM_VARIABLES) -auto-approve
	$(TERRAFORM) output >$(TERRAFORM_OUTPUTS_FILE)

down: env
	$(TERRAFORM) destroy $(TERRAFORM_VARIABLES) -auto-approve
	$(RM) $(TERRAFORM_OUTPUTS_FILE)

oci-secret: $(OCI_SECRET_FILE)

$(OCI_SECRET_FILE): env
	$(KUBECTL) create secret docker-registry $(OCI_SECRET) \
		--docker-server=$(OCI_REGION).ocir.io \
		--docker-username=$(OCI_USERNAME) --docker-password=$(OCI_PASSWORD) \
		--docker-email=$(OCI_USER_EMAIL)
	$(KUBECTL) get secret $(OCI_SECRET) --output=yaml >$(OCI_SECRET_FILE)

# Part 3: Local authentication to access the cluster

authenticate: env
	$(OCICTL) ce cluster create-kubeconfig --token-version 2.0.0 \
		--cluster-id $(OCI_K8S_CLUSTER_OCID) --region $(OCI_REGION)  \
		--file $(K8S_LOCAL_CONFIG)
	@make oci-secret

deauthenticate:
	-$(RM) $(OCI_SECRET_FILE)

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
Main targets (for users):
   make start                  start the cluster and compute server
   make stop                   stop the server snd cluster

More detailed targets (for development):
   make up                     spin-up the Kubernetes cluster
   make down
   make deploy                 deploy the epyc server
   make undeploy
   make upgrade                upgrade the server after changes
   make deploy-cert-manager    deploy cert-manager and its CRDs
   make undeploy-cert-manager
   make deploy-dashboard       deploy Kubernetes dashboard
   make undeploy-dashboard
   make authenticate           authenticate local kubectl client
   make deauthenticate
   make oci-secret             create the cluster secret
   make env                    create a local environment
   make clean                  clean-up deployment
   make reallyclean            clean-up local environment

endef
export HELP_MESSAGE

usage:
	@echo "$$HELP_MESSAGE"
