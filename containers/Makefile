# Makefile for all containers
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

# The containers
CONTAINERS = \
	micro-engine \
	micro-engine-rabbitmq-shim

# The container repository user
REPO_USER = simoninireland


# ---------- Environment ----------

include ./credentials.sh


# ---------- Tools ----------

DOCKER = docker
DOCTL = doctl
MINIKUBE = minikube
CHDIR = cd


# ---------- Constructed commands ----------

DOCKER_BUILD = $(DOCKER) buildx build
DOCKER_BUILD_CLEAN = $(DOCKER) buildx build --pull --no-cache
DOCKER_RM = docker image rm
DOCKER_PUSH = $(DOCKER) push
DOCKER_CLEAN = $(DOCKER) buildx prune -f
MINIKUBE_PUSH = $(MINIKUBE) image load


# ---------- Targets ----------

# The build context for the Dockerfiles is this directory, to
# allow access to files in lib/

.PHONY: $(CONTAINERS)
build: $(CONTAINERS)

controller:
	$(DOCKER_BUILD) -f $@/Dockerfile --tag $(REPO_USER)/$@ .

base-engine:
	$(DOCKER_BUILD) -f $@/Dockerfile --tag $(REPO_USER)/$@ .

base-notebook:
	$(DOCKER_BUILD) -f $@/Dockerfile --tag $(REPO_USER)/$@ .

micro-engine:
	$(DOCKER_BUILD) -f $@/Dockerfile --tag $(REPO_USER)/$@ .

micro-labnotebook:
	$(DOCKER_BUILD) -f $@/Dockerfile --tag $(REPO_USER)/$@ .

push-dockerhub:
	for c in $(CONTAINERS); do \
	  $(DOCKER_PUSH) $(REPO_USER)/$$c; \
	done

push-minikube:
	for c in $(CONTAINERS); do \
	  $(MINIKUBE_PUSH) $(REPO_USER)/$$c; \
	done

push-oci:
	echo $(OCI_PASSWORD) | $(DOCKER) login $(OCI_REGION).ocir.io -u $(OCI_USERNAME) --password-stdin
	for c in $(CONTAINERS); do \
	  $(DOCKER) tag $(REPO_USER)/$$c $(OCI_REGION).ocir.io/$(OCI_OBJECT_STORAGE_NAMESPACE)/$$c; \
	  $(DOCKER_PUSH) $(OCI_REGION).ocir.io/$(OCI_OBJECT_STORAGE_NAMESPACE)/$$c; \
	done

push-digitalocean:
	$(DOCTL) auth init -t $(DO_TOKEN)
	$(DOCTL) registry login
	for c in $(CONTAINERS); do \
	  $(DOCKER) tag $(REPO_USER)/$$c registry.digitalocean.com/$(DO_REGISTRY)/$$c; \
	  $(DOCKER_PUSH) registry.digitalocean.com/$(DO_REGISTRY)/$$c; \
	done

reallyclean:
	for c in $(CONTAINERS); do \
	  $(DOCKER_RM) $(REPO_USER)/$$c; \
	done
	$(DOCKER_CLEAN)
