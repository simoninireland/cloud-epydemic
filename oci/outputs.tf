# Terrform outputs
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

# ---------- List of availability domains.----------

output "all-availability-domains-in-your-tenancy" {
  description = "List of availability domains"
  value = data.oci_identity_availability_domains.ads.availability_domains
}

output "name-of-first-availability-domain" {
  description = "Name of the first availability domain"
  value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

# ---------- Compartment ----------

output "compartment-name" {
  description = "Name of the tenancy ompartment holding the cluster"
  value = oci_identity_compartment.tf-compartment.name
}

output "compartment-ocid" {
  description = "OCID of the tenancy ompartment holding the cluster"
  value = oci_identity_compartment.tf-compartment.id
}


# ---------- Virtual cloud network (VCN) ----------

output "vcn_id" {
  description = "OCID of the VCN that is created"
  value = module.vcn.vcn_id
}

output "id-for-route-table-that-includes-the-internet-gateway" {
  description = "OCID of the internet-route table, used for public subnets"
  value = module.vcn.ig_route_id
}

output "nat-gateway-id" {
  description = "OCID for the NAT gateway"
  value = module.vcn.nat_gateway_id
}

output "id-for-for-route-table-that-includes-the-nat-gateway" {
  description = "OCID of the nat-route table, used for private subnets"
  value = module.vcn.nat_route_id
}


# ---------- Private subnet security list ----------

output "private-security-list-name" {
  description = "Name of security list for private subnet"
  value = oci_core_security_list.private-security-list.display_name
}

output "private-security-list-OCID" {
  description = "OCID for private subnet security list"
  value = oci_core_security_list.private-security-list.id
}


# ---------- Public subnet security list ----------

output "public-security-list-name" {
  description = "Name of security list for public subnet"
  value = oci_core_security_list.public-security-list.display_name
}

output "public-security-list-OCID" {
  description = "OCID for public subnet security list"
  value = oci_core_security_list.public-security-list.id
}


# ---------- Private subnet ----------

output "private-subnet-name" {
  description = "Name of private subnet"
  value = oci_core_subnet.vcn-private-subnet.display_name
}

output "private-subnet-OCID" {
  description = "OCID of private subnet"
  value = oci_core_subnet.vcn-private-subnet.id
}


# ---------- Private subnet ----------

output "public-subnet-name" {
  description = "Name of public subnet"
  value = oci_core_subnet.vcn-public-subnet.display_name
}

output "public-subnet-OCID" {
  description = "OCID of public subnet"
  value = oci_core_subnet.vcn-public-subnet.id
}


# ---------- Kubernetes cluster ----------

output "cluster-name" {
  value = oci_containerengine_cluster.oke-cluster.name
}

output "cluster-OCID" {
  value = oci_containerengine_cluster.oke-cluster.id
}

output "cluster-kubernetes-version" {
  value = oci_containerengine_cluster.oke-cluster.kubernetes_version
}

output "cluster-state" {
  value = oci_containerengine_cluster.oke-cluster.state
}

# ---------- Kubernetes node pool ----------

output "node-pool-name" {
  value = oci_containerengine_node_pool.oke-node-pool.name
}

output "node-pool-OCID" {
  value = oci_containerengine_node_pool.oke-node-pool.id
}

output "node-pool-kubernetes-version" {
  value = oci_containerengine_node_pool.oke-node-pool.kubernetes_version
}

output "node-size" {
  value = oci_containerengine_node_pool.oke-node-pool.node_config_details[0].size
}

output "node-shape" {
  value = oci_containerengine_node_pool.oke-node-pool.node_shape
}
