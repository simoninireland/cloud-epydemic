# Terraform script to spin-up a compute cluster on OCI
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

# ---------- OCI provider ----------

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.107.0"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint      = var.key_fingerprint
  region           = var.oci_region
}


# ---------- Base virtual network ----------

resource "oci_core_vcn" "cluster_vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "cluster_vcn"
}


# ---------- Access control ----------

resource "oci_core_security_list" "cluster_public_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cluster_vcn.id
  display_name   = "Security list for the public subnet"

  ingress_security_rules {
    protocol    = 6
    source_type = "CIDR_BLOCK"
    source      = var.home_address_cidr
    description = "Access to container instance port 80 from StA"
    tcp_options {
      min = 80
      max = 80
    }
  }

  egress_security_rules {
    protocol         = 6
    destination_type = "CIDR_BLOCK"
    destination      = "0.0.0.0/0"
    description      = "Access to container registries via HTTPS"
    tcp_options {
      min = 443
      max = 443
    }
  }
}


# ---------- Subnet ----------

resource "oci_core_subnet" "cluster_subnet" {
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cluster_vcn.id
  display_name   = "Container instances (public) subnet"

  security_list_ids = [
    oci_core_security_list.cluster_public_subnet.id
  ]
  route_table_id = oci_core_route_table.cluster_gateway_router.id
}

resource "oci_core_internet_gateway" "cluster_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cluster_vcn.id
  display_name   = "Internet gateway"
  enabled        = true
}

resource "oci_core_route_table" "cluster_gateway_router" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cluster_vcn.id
  display_name   = "Internet gateway routing table"

  route_rules {
    network_entity_id = oci_core_internet_gateway.cluster_gateway.id
    destination       = "0.0.0.0/0"
  }
}


# ---------- Container instances -------------------

data "oci_identity_availability_domains" "cluster_availability" {
  compartment_id = var.compartment_ocid
}

resource "oci_container_instances_container_instance" "cluster_frontend_instance" {
  availability_domain      = data.oci_identity_availability_domains.cluster_availability.availability_domains.0.name
  compartment_id           = var.compartment_ocid
  display_name             = "Cluster frontend instance"

  container_restart_policy = "ALWAYS"
  shape                    = "CI.Standard.E4.Flex"
  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }

  vnics {
    subnet_id             = oci_core_subnet.cluster_subnet.id
    is_public_ip_assigned = true
    nsg_ids               = []
  }

  containers {
    image_url    = "siminireland/base-notebook:latest"
    display_name = "Cluster notebook frontend"
  }
}
