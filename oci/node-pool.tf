# Terraform set-up for Kubernetes node pool on OCI
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

resource "oci_containerengine_node_pool" "oke-node-pool" {
  cluster_id = oci_containerengine_cluster.oke-cluster.id
  compartment_id = oci_identity_compartment.tf-compartment.id
  kubernetes_version = var.K8S_VERSION
  name = var.K8S_WORKER_NODE_POOL_NAME

  node_shape = var.K8S_WORKER_NODE_SHAPE
  node_source_details {
    image_id = var.K8S_WORKER_NODE_IMAGE_OCID
    source_type = "image"
  }
  node_shape_config {
    memory_in_gbs = var.K8S_WORKER_NODE_MEMORY
    ocpus = var.K8S_WORKER_NODE_CPUS
  }
  node_config_details{
    placement_configs{
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
      subnet_id = oci_core_subnet.vcn-private-subnet.id
    }
    placement_configs{
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[1].name
      subnet_id = oci_core_subnet.vcn-private-subnet.id
    }
    placement_configs{
      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[2].name
      subnet_id = oci_core_subnet.vcn-private-subnet.id
    }
    size = var.K8S_WORKER_NODE_POOL_SIZE
  }
}
