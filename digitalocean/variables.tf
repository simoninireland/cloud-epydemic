# Terraform variables to provide Digital Ocean credentials
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

# ---------- Digital Ocean credentials (credentials.tfvars) ----------

variable "DO_TOKEN" {
  description = "Access token"
  type = string
  sensitive = true
}
variable "DO_REGION" {
  description = "Region"
  type = string
}
variable "DO_PRIVATE_KEY_FILE" {
  description = "Private key file"
  type = string
  sensitive = true
}

variable "DO_REPO" {
  description = "Container repo name"
  type = string
}


# ---------- Digital ocean Kubernetes configuration (credentials.tfvars) ----------

variable "K8S_VERSION" {
  description = "Kubernetes version"
  type = string
}

variable "K8S_APPLICATION_NAME" {
  description = "Kubernetes application name"
  type = string
}

# All K8S_* variables below this have defaults

variable "K8S_WORKER_NODE_POOL_NAME" {
  description = "The name of the worker node pool"
  type = string
  default = "worker-node-pool"
}
variable "K8S_WORKER_NODE_POOL_SIZE" {
  description = "The number of worker nodes in the node pool"
  type = number
  default = 3
}
variable "K8S_WORKER_NODE_SHAPE" {
  description = "Machine shape for Kubernetes worker node"
  type = string
  default = "s-2vcpu-2gb"
}
