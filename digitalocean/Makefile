# Makefile for compute cluster on Digital Ocean
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

# This Makefile assumes that the domain hosting the server is pointing at
# Digital Ocean's DNS, allowing the CLI tools to add and remove entries.

# "make start" will bring up a cluster and deploy to it. "make stop"
# will remove the app and tear-down the cluster. These are the only
# targets typically needed, but tghere are lots of others, one per
# phase of the (un)deployment for more flexible control (and
# debugging).

# A cloudepyc.ClusterLab pointed at https://$(SERVICE).$(DOMAIN)
# should connect to the compute cluste over TLS.

# Digital Ocean doesn't come with the ingress-nginx controller
# pre-installed, and this need to be installed before deploying the
# app.

# cert-manager is used to manage TLS certificates. This also needs to
# be installed before anytihng else, and /has/ to live in its own
# namespace -- otherwise cert issuance hangs silently.


# ---------- Sources ----------

# Terraform files
TERRAFORM_SRC = \
	main.tf \
	platform.tf \
	variables.tf
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


# ---------- Tools ----------

TERRAFORM = terraform
KUBECTL = kubectl
DOCTL = doctl
JQ = jq
HELM = helm
RM = rm -fr
CHDIR = cd


# ---------- Configuration ----------

# Terraform
TERRAFORM_DIR = .terraform
TERRAFORM_VARIABLES = $(patsubst %.tfvars,--var-file=%.tfvars,$(VARIABLES))

# nginx ingress controller
NGINX_REPO = https://kubernetes.github.io/ingress-nginx
NGINX_RELEASE=$(HELM_RELEASE)-nginx
NGINX_CHART = ingress-nginx/ingress-nginx
NGINX_CHART_VERSION = 4.6.0
NGINX_NAMESPACE = $(NAMESPACE)
NGINX_INGRESS_CONTROLLER = $(NGINX_RELEASE)-ingress-nginx-controller

# cert-manager
CERT_MANAGER_REPO = https://charts.jetstack.io
CERT_MANAGER_RELEASE=$(HELM_RELEASE)-cert-manager
CERT_MANAGER_CHART = cert-manager/cert-manager
CERT_MANAGER_CHART_VERSION = v1.11.1
CERT_MANAGER_NAMESPACE = cert-manager

# Digital Ocean
DO_IMAGE_TAG = registry.digitalocean.com/$(DO_REPO)
LOAD_BALANCER_IP = $(shell $(KUBECTL) get service $(NGINX_INGRESS_CONTROLLER) -n $(NGINX_NAMESPACE) -o json | $(JQ) '.status.loadBalancer.ingress[0].ip')

# Kuberbetes
K8S_LOCAL_CONFIG = $(HOME)/.kube/config

# Helm
HELM_VARS = \
	--set components.certManager.enabled=true \
	--set components.ingress.host=$(SERVICE).$(DOMAIN) \
	--set components.certManager.email=$(EMAIL)\
	--set components.engine.pods.containers.engine.image=$(DO_IMAGE_TAG)/micro-engine:latest \
	--set components.engine.pods.containers.engine.imagePullPolicy=Always \
	--set components.engine.pods.containers.shim.image=$(DO_IMAGE_TAG)/micro-engine-rabbitmq-shim:latest \
	--set components.engine.pods.containers.shim.imagePullPolicy=Always \
	--set components.gateway.pods.containers.gateway.image=$(DO_IMAGE_TAG)/api-gateway:latest \
	--set components.gateway.pods.containers.gateway.imagePullPolicy=Always


# ---------- Targets ----------

default:
	@make usage

# Part 0: Top-level targets

start:
	@make up
	@make authenticate
	@make deploy-nginx
	@make deploy-cert-manager
	@make deploy
	sleep 60
	@make register-dns

stop:
	@make unregister-dns
	@make undeploy
	@make undeploy-cert-manager
	@make undeploy-nginx
	@make down
	@make deauthenticate
	@make reallyclean

# Part 1: Manage the deployment of the app

deploy: env
	$(CHDIR) ../helm && $(HELM) install $(HELM_RELEASE) \
		$(HELM_VARS) ./$(HELM_CHART) \
		-n $(NAMESPACE) --create-namespace

upgrade: env
	$(CHDIR) ../helm && $(HELM) upgrade $(HELM_RELEASE) \
		$(HELM_VARS) ./$(HELM_CHART) -n $(NAMESPACE)

undeploy: env
	-$(HELM) uninstall $(HELM_RELEASE) -n $(NAMESPACE)
	-$(KUBECTL) delete namespace $(NAMESPACE)

# Part 1a: Manage the auxiliary services needed (or provided) by Digital Ocean

register-dns:
	$(DOCTL) compute domain create $(DOMAIN)
	$(DOCTL) compute domain records create $(DOMAIN) \
		--record-type "A" --record-name $(SERVICE) \
		--record-data $(LOAD_BALANCER_IP) --record-ttl "30"

unregister-dns:
	-$(DOCTL) compute domain delete -f $(DOMAIN)

deploy-nginx: env
	$(HELM) repo add ingress-nginx $(NGINX_REPO)
	$(HELM) repo update ingress-nginx
	$(HELM) install $(NGINX_RELEASE) \
		$(NGINX_CHART) --version $(NGINX_CHART_VERSION) \
		-n $(NGINX_NAMESPACE) --create-namespace

undeploy-nginx: env
	-$(HELM) uninstall $(NGINX_RELEASE) -n $(NGINX_NAMESPACE)
	-$(KUBECTL) delete namespace $(NGINX_NAMESPACE)


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

# Part 2: Manage terraforming the Kubernetes cluster

up: env
	$(TERRAFORM) apply $(TERRAFORM_VARIABLES) -auto-approve
	$(DOCTL) kubernetes cluster kubeconfig save $(K8S_APPLICATION_NAME)

down: env
	$(TERRAFORM) destroy $(TERRAFORM_VARIABLES) -auto-approve

# Part 3: Local authentication to access the cluster

authenticate: env
	$(DOCTL) auth init -t $(DO_TOKEN)
	$(DOCTL) registry kubernetes-manifest | $(KUBECTL) apply -f -

deauthenticate:
	$(DOCTL) auth remove --context default -t $(DO_TOKEN)

# Part 4: Environment management

env: $(TERRAFORM_DIR)

$(TERRAFORM_DIR):
	$(TERRAFORM) init

clean:
	-$(DOCTL) compute domain delete -f $(DOMAIN)
	-$(KUBECTL) delete namespace $(NAMESPACE)

reallyclean: undeploy-nginx undeploy-cert-manager down clean
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
   make deploy-nginx           deploy the ingress-nginx controller
   make undeploy-nginx
   make deploy-cert-manager    deploy cert-manager and its CRDs
   make undeploy-cert-manager
   make register-dns           define the DNS domain and entries
   make unregister-dns
   make authenticate           authenticate local kubectl client
   make deauthenticate
   make env                    create a local environment
   make clean                  clean-up deployment
   make reallyclean            clean-up local environment

endef
export HELP_MESSAGE

usage:
	@echo "$$HELP_MESSAGE"
