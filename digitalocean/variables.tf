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
  description = "Digital Ocean access token"
  type = string
  sensitive = true
}

variable "DO_REGION" {
  type = string
}

variable "DO_PRIVATE_KEY_FILE" {
  description = "Digital Ocean private key file"
  type = string
  sensitive = true
}


# ---------- Digital ocean Kubernetes configuration (credentials.tfvars) ----------

# All k8s_* variables below this have defaults

variable "K8S_VERSION" {
  description = "Kubernetes version"
  type = string
  default = "1.25.4-do.0"
}
variable "K8S_APPLICATION_NAME" {
  description = "Kubernetes application name"
  type = string
  default = "geekiam"
}

variable "K8S_WORKER_NODE_POOL_SIZE" {
  type = number
  default = 3
}

variable "K8S_WORKER_NODE_SHAPE" {
  description = "Machine shape for Kubernetes worker node"
  type = string
  default = "s-2vcpu-2gb"
}
