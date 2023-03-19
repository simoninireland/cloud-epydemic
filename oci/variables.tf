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

variable "home_address_cidr" {
  description = "Network mask from which connections are allowed"
  type = string
}

variable "worker_node_shape" {
  description = "Machine shape for Kubernetes worker node"
  type = string
}

variable "worker_node_image_ocid" {
  description = "OCID of machine image for Kubernetes worker node"
  type = string
}

variable "worker_node_pool_size" {
  description = "Size of Kubernetes worker node pool"
  type = int
}
