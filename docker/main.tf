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
  name = "base-notebook:latest"
}


# ---------- Network ----------

resource "docker_network" "private" {
  name = "private_cluster_network"
  internal = true
}


# ---------- Storage ----------

resource "docker_volume" "working" {
}


# ---------- Containers ----------

resource "docker_container" "notebook" {
  image = docker_image.notebook.image_id
  name  = "epydemic_notebook"
  mounts {
    type = "volume"
    target = "/mnt/working"
    source = docker_volume.working.id
  }
  ports {
    internal = 8888
    external = 8888
  }
}
