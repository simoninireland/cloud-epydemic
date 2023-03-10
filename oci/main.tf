# Containerised compute cluster on OCI
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

# ---------- Containers ----------

resource "oci_container_instances_container_instance" "cluster_authentication_instance" {
  availability_domain      = data.oci_identity_availability_domains.cluster_availability.availability_domains.2.name
  compartment_id           = var.compartment_ocid
  display_name             = "Cluster authentication server"

  shape                    = "CI.Standard.E3.Flex"
  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }
  vnics {
    subnet_id             = oci_core_subnet.cluster_subnet.id
  }

  container_restart_policy = "ALWAYS"
  containers {
    image_url    = "redis:latest"
    display_name = "Cluster authentication"
  }
}

# resource "oci_container_instances_container_instance" "cluster_controller_instance" {
#   availability_domain      = data.oci_identity_availability_domains.cluster_availability.availability_domains.2.name
#   compartment_id           = var.compartment_ocid
#   display_name             = "Cluster controller"

#   shape                    = "CI.Standard.E3.Flex"
#   shape_config {
#     memory_in_gbs = 4
#     ocpus         = 1
#   }
#   vnics {
#     subnet_id             = oci_core_subnet.cluster_subnet.id
#     nsg_ids               = []
#     hostname_label        = "cluster_controller"
#   }

#   container_restart_policy = "ALWAYS"
#   containers {
#     image_url    = "simonireland/controller:latest"
#     display_name = "Cluster controller"

#     environment_variables = {
#       EPYDEMIC_CONTROLLER_HOST = "cluster_controller"
#       EPYDEMIC_AUTHENTICATION_HOST = "cluster_authentication"
#     }
#   }
# }

# resource "oci_container_instances_container_instance" "cluster_engine_instance" {
#   availability_domain      = data.oci_identity_availability_domains.cluster_availability.availability_domains.2.name
#   compartment_id           = var.compartment_ocid
#   display_name             = "Cluster engines"

#   shape                    = "CI.Standard.E3.Flex"
#   shape_config {
#     memory_in_gbs = 4
#     ocpus         = 1
#   }
#   vnics {
#     subnet_id             = oci_core_subnet.cluster_subnet.id
#     nsg_ids               = []
#   }

#   container_restart_policy = "ALWAYS"
#   containers {
#     image_url    = "simonireland/base-engine:latest"
#     display_name = "Cluster engine"

#     volume_mounts {
#       volume_name = "cluster_shared"
#       mount_path = "/home/epydemic/shared"
#     }
#     environment_variables = {
#       EPYDEMIC_ENGINES = 4
#     }
#   }
# }

# resource "oci_container_instances_container_instance" "cluster_frontend_instance" {
#   availability_domain      = data.oci_identity_availability_domains.cluster_availability.availability_domains.2.name
#   compartment_id           = var.compartment_ocid
#   display_name             = "Cluster frontend"

#   shape                    = "CI.Standard.E3.Flex"
#   shape_config {
#     memory_in_gbs = 4
#     ocpus         = 1
#   }
#   vnics {
#     subnet_id             = oci_core_subnet.cluster_subnet.id
#     is_public_ip_assigned = true
#   }
#   volumes {
#     name = "data"
#     volume_type = "EMPTYDIR"
#   }

#   container_restart_policy = "ALWAYS"
#   containers {
#     image_url    = "simonireland/base-notebook:latest"
#     display_name = "Cluster notebook frontend"

#     volume_mounts {
#       volume_name = "data"
#       mount_path = "/home/epydemic/data"
#     }
#   }
# }
