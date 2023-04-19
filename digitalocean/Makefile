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

# DNS for the service
DOMAIN = epydemic.org
SERVICE = cloud


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


# ---------- Constructed lists ----------

# Terraform
TERRAFORM_DIR = .terraform
TERRAFORM_VARIABLES = $(patsubst %.tfvars,--var-file=%.tfvars,$(VARIABLES))

# nginx ingress
NGINX_REPO = https://kubernetes.github.io/ingress-nginx
NGINX_CHART = ingress-nginx/ingress-nginx
NGINX_CHART_VERSION = 4.6.0

# cert-manager
CERT_MANAGER_REPO = https://charts.jetstack.io
CERT_MANAGER_CHART = cert-manager/cert-manager
CERT_MANAGER_CHART_VERSION = v1.11.1
CERT_MANAGER_NAMESPACE = cert-manager

# Digital Ocean
DO_IMAGE_TAG = registry.digitalocean.com/$(DO_REPO)
LOAD_BALANCER_IP = $(shell $(KUBECTL) get service $(HELM_RELEASE)-nginx-ingress-nginx-controller -n $(NAMESPACE) -o json | $(JQ) '.status.loadBalancer.ingress[0].ip')

# Kuberbetes
K8S_LOCAL_CONFIG = $(HOME)/.kube/config

# Helm
HELM_VARS = \
	--set components.certManager.enabled=true \
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
	@make authorise
	@make deploy-namespace
	@make deploy-nginx
	@make deploy-cert-manager
	@make register-dns
	@make deploy

stop:
	@make unregister-dns
	@make undeploy
	@make undeploy-cert-manager
	@make undeploy-nginx
	@make undeploy-namespace
	@make down
	@make deauthorise
	@make reallyclean

# Part 1: Manage the deployment of the app

deploy: env
	$(CHDIR) ../helm && $(HELM) install $(HELM_RELEASE) \
		$(HELM_VARS) -n $(NAMESPACE) ./$(HELM_CHART)

upgrade: env
	$(CHDIR) ../helm && $(HELM) upgrade $(HELM_RELEASE) \
		$(HELM_VARS) -n $(NAMESPACE) ./$(HELM_CHART)

undeploy: env
	-$(HELM) uninstall $(HELM_RELEASE) -n $(NAMESPACE)

deploy-namespace: env
	-$(KUBECTL) create namespace $(NAMESPACE)

undeploy-namespace: env
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
	$(HELM) install $(HELM_RELEASE)-nginx \
		$(NGINX_CHART) --version $(NGINX_CHART_VERSION)

undeploy-nginx: env
	-$(HELM) uninstall $(HELM_RELEASE)-nginx

deploy-cert-manager: env
	$(HELM) repo add cert-manager $(CERT_MANAGER_REPO)
	$(HELM) repo update cert-manager
	$(HELM) install $(HELM_RELEASE)-cert-manager \
		$(CERT_MANAGER_CHART) --version $(CERT_MANAGER_CHART_VERSION) \
		--set installCRDs=true \
		-n $(CERT_MANAGER_NAMESPACE) --create-namespace

undeploy-cert-manager: env
	-$(HELM) uninstall $(HELM_RELEASE)-cert-manager
	-$(KUBECTL) delete namespace $(CERT_MANAGER_NAMESPACE)

# Part 2: Manage terraforming the Kubernetes cluster

up: env
	$(TERRAFORM) apply $(TERRAFORM_VARIABLES) -auto-approve
	$(DOCTL) kubernetes cluster kubeconfig save $(K8S_APPLICATION_NAME)

down: env
	$(TERRAFORM) destroy $(TERRAFORM_VARIABLES) -auto-approve

# Part 3: Local authorisation to access the cluster

authorise: env
	$(DOCTL) auth init -t $(DO_TOKEN)
	$(DOCTL) registry kubernetes-manifest | $(KUBECTL) apply -f -

deauthorise:

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
