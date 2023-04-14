# Terraform variables to provide OCI credentials and other details
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

# ---------- OCI credentials (credentials.tfvars) ----------

variable "OCI_TENANCY" {
  description = "Tenancy name"
  type = string
}
variable "OCI_REGION" {
  description = "Tenancy region"
  type = string
}
variable "OCI_TENANCY_OCID" {
  description = "Tenancy ID"
  type = string
  sensitive = true
}
variable "OCI_TENANCY_NAMESPACE" {
  description = "Tenancy namespace"
  type = string
}
variable "OCI_OBJECT_STORAGE_NAMESPACE" {
  description = "Tenancy object store"
  type = string
}

variable "OCI_USER_EMAIL" {
  description = "User email address"
  type = string
  sensitive = true
}
variable "OCI_USER_OCID" {
  description = "User ID"
  type = string
  sensitive = true
}
variable "OCI_PASSWORD" {
  description = "User password"
  type = string
  sensitive = true
}
variable "OCI_PRIVATE_KEY_FINGERPRINT" {
  description = "Public key fingerprint"
  type = string
}
variable "OCI_PRIVATE_KEY_PATH" {
  description = "Path to private key"
  type = string
  sensitive = true
}

variable "OCI_REPO" {
  description = "Container repository name"
  type = string
}


# ---------- Kubernetes configuration (kubernetes.tfvars) ----------

variable "K8S_VERSION" {
  description = "Kubernetes version (must match worker node images)"
  type = string
}

variable "K8S_WORKER_NODE_SHAPE" {
  description = "Machine shape for Kubernetes worker node"
  type = string
}

variable "K8S_WORKER_NODE_IMAGE_OCID" {
  description = "OCID of machine image for Kubernetes worker node"
  type = string
}

# All K8S_* variables below this line have defaults

variable "K8S_WORKER_NODE_IMAGE_NAME" {
  description = "Name of machine image for Kubernetes worker node (for documentation)"
  type = string
  default = "<unknown>"
}

variable "K8S_WORKER_NODE_POOL_NAME" {
  description = "Name of Kubernetes worker node pool"
  type = string
  default = "pool1"
}

variable "K8S_WORKER_NODE_POOL_SIZE" {
  description = "Size of Kubernetes worker node pool"
  type = number
  default = 3
}

variable "K8S_WORKER_NODE_MEMORY" {
  description = "Memory for a woreker node in GBs"
  type = number
  default = 2
}

variable "K8S_WORKER_NODE_CPUS" {
  description = "Number of virtual CPUs for a worker node"
  type = number
  default = 2
}
