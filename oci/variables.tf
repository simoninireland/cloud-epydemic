# Terraform variables to provide OCI credentials and other details
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

# ---------- OCI credentials (credentials.tfvars) ----------

variable "tenancy_ocid" {
  description = "Tenancy ID"
  type = string
  sensitive = true
}
variable "oci_region" {
  description = "Region"
  type = string
}

variable "user_ocid" {
  description = "User ID"
  type = string
  sensitive = true
}
variable "key_fingerprint" {
  description = "Public key fingerprint"
  type = string
}
variable "private_key_path" {
  description = "Path to private key"
  type = string
  sensitive = true
}


# ---------- Kubernetes configuration (kubernetes.tfvars) ----------

variable "k8s_version" {
  description = "Kubernetes version (must match worker node images)"
  type = string
}

variable "k8s_worker_node_shape" {
  description = "Machine shape for Kubernetes worker node"
  type = string
}

variable "k8s_worker_node_image_ocid" {
  description = "OCID of machine image for Kubernetes worker node"
  type = string
}

# All k8s_* variables below this have defaults

variable "k8s_worker_node_image_name" {
  description = "Name of machine image for Kubernetes worker node (for documentation)"
  type = string
  default = "<unknown>"
}

variable "k8s_worker_node_pool_name" {
  description = "Name of Kubernetes worker node pool"
  type = string
  default = "pool1"
}

variable "k8s_worker_node_pool_size" {
  description = "Size of Kubernetes worker node pool"
  type = number
  default = 3
}

variable "k8s_worker_node_memory" {
  description = "Memory for a woreker node in GBs"
  type = number
  default = 2
}

variable "k8s_worker_node_cpus" {
  description = "Number of virtual CPUs for a woreker node"
  type = number
  default = 2
}
