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
	base-notebook \
	controller \
	base-engine

# The container repository user
REPO_USER = simoninireland


# ---------- Environment ----------

include ./credentials.sh


# ---------- Tools ----------

DOCKER = docker
DOCKER_BUILD = $(DOCKER) buildx build
DOCKER_BUILD_CLEAN = $(DOCKER) buildx build --pull --no-cache
DOCKER_PUSH = $(DOCKER) push
DOCTL = doctl
CHDIR = cd


# ---------- Targets ----------

# The build context for the Dockerfiles is this directory, to
# allow access to files in lib/

build:
	for c in $(CONTAINERS); do \
	  ($(DOCKER_BUILD) -f $$c/Dockerfile --tag $(REPO_USER)/$$c . || exit 1) \
	done

build-clean:
	for c in $(CONTAINERS); do \
	  ($(DOCKER_BUILD_CLEAN) -f $$c/Dockerfile --tag $(REPO_USER)/$$c . || exit 1) \
	done

push-dockerhub:
	for c in $(CONTAINERS); do \
	  ($(DOCKER_PUSH) $(REPO_USER)/$$c || exit 1) \
	done

push-oci:
	echo $(OCI_PASSWORD) | $(DOCKER) login $(OCI_REGION).ocir.io -u $(OCI_USERNAME) --password-stdin
	for c in $(CONTAINERS); do \
	  ($(DOCKER) tag $(REPO_USER)/$$c $(OCI_REGION).ocir.io/$(OCI_OBJECT_STORAGE_NAMESPACE)/$$c || exit 1); \
	  ($(DOCKER_PUSH) $(OCI_REGION).ocir.io/$(OCI_OBJECT_STORAGE_NAMESPACE)/$$c || exit 1) \
	done

push-digitalocean:
	$(DOCTL) auth init -t $(DO_TOKEN)
	$(DOCTL) registry login
	for c in $(CONTAINERS); do \
	  ($(DOCKER) tag $(REPO_USER)/$$c registry.digitalocean.com/$(DO_REGISTRY)/$$c || exit 1); \
	  ($(DOCKER_PUSH) registry.digitalocean.com/$(DO_REGISTRY)/$$c || exit 1) \
	done
