# Terraform script to create a compute cluster locally using Docker
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

# ---------- Docker provider ----------

terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}


# ---------- Container images ----------

resource "docker_image" "notebook" {
  name = "simoninireland/base-notebook:latest"
  keep_locally = true
}

resource "docker_image" "controller" {
  name = "simoninireland/controller:latest"
  keep_locally = true
}

resource "docker_image" "engine" {
  name = "simoninireland/base-engine:latest"
  keep_locally = true
}

resource "docker_image" "redis" {
  name = "redis:latest"
  keep_locally = true
}


# ---------- Network ----------

resource "docker_network" "cluster_bridge" {
  name = "cluster_bridge"
  driver = "bridge"
}


# ---------- Storage ----------

resource "docker_volume" "data" {
}


# ---------- Containers ----------

resource "docker_container" "cluster_authentication" {
  image = docker_image.redis.image_id
  name = "cluster_authentication"
  hostname = "cluster_authentication"
  networks_advanced {
    name = docker_network.cluster_bridge.id
  }
}

resource "docker_container" "cluster_controller" {
  image = docker_image.controller.image_id
  name = "cluster_controller"
  hostname = "cluster_controller"

  env = [
    "EPYDEMIC_CONTROLLER_HOST=cluster_controller",
    "EPYDEMIC_AUTHENTICATION_HOST=cluster_authentication",
  ]

  networks_advanced {
    name = docker_network.cluster_bridge.id
  }
}

resource "docker_container" "cluster_engine" {
  count = 3
  image = docker_image.engine.image_id
  name = "cluster_engine_${count.index}"
  hostname = "cluster_engine"

  env = [
    "EPYDEMIC_AUTHENTICATION_HOST=cluster_authentication",
    "EPYDEMIC_ENGINES=4",
  ]

  networks_advanced {
    name = docker_network.cluster_bridge.id
  }
}

resource "docker_container" "cluster_frontend" {
  image = docker_image.notebook.image_id
  name  = "cluster_frontend"

  env = [
    "EPYDEMIC_AUTHENTICATION_HOST=cluster_authentication",
    # "EPYDEMIC_PASSWORD=secret"
  ]

  networks_advanced {
    name = docker_network.cluster_bridge.id
  }
  mounts {
    type = "volume"
    target = "/home/epydemic/data"
    source = docker_volume.data.id
  }
  ports {
    internal = 8888
    external = 8888
  }
}


# ---------- Debugging ----------

resource "docker_image" "bastion" {
  name = "alpine:latest"
  keep_locally = true
}

resource "docker_container" "cluster_bastion" {
  image = docker_image.bastion.image_id
  name= "cluster_bastion"
  depends_on = [ docker_container.cluster_controller ]
  hostname = "cluster_bastion"
  stdin_open = true
  tty = true
  networks_advanced {
    name = docker_network.cluster_bridge.id
  }
}
