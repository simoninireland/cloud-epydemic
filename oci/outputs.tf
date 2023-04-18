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

# ---------- Kubernetes cluster OCIDs ----------

output "OCI_K8S_COMPARTMENT_OCID" {
  description = "OCID of the tenancy ompartment holding the cluster"
  value = oci_identity_compartment.tf-compartment.id
}

output "OCI_K8S_CLUSTER_OCID" {
  value = oci_containerengine_cluster.oke-cluster.id
}

output "OCI_K8S_NODE_POOL_OCID" {
  value = oci_containerengine_node_pool.oke-node-pool.id
}
