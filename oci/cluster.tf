# Terraform set-up for managed Kubernetes cluster on OCI
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

resource "oci_containerengine_cluster" "oke-cluster" {
  compartment_id = oci_identity_compartment.tf-compartment.id
  #kubernetes_version = data.oci_containerengine_cluster_option.OKE_cluster_option.kubernetes_versions.0
  kubernetes_version = var.K8S_VERSION

  name = "cloudepydemic"
  vcn_id = module.vcn.vcn_id

  options {
    # add_ons{
    #   is_kubernetes_dashboard_enabled = false
    #   is_tiller_enabled = false
    # }
    # kubernetes_network_config {
    #   #pods_cidr = "10.244.0.0/16"
    #   #services_cidr = "10.96.0.0/16"
    #   pods_cidr = oci_core_subnet.vcn-private-subnet.cidr_block
    #   services_cidr = oci_core_subnet.vcn-public-subnet.cidr_block
    # }
    service_lb_subnet_ids = [oci_core_subnet.vcn-public-subnet.id]
  }
}
