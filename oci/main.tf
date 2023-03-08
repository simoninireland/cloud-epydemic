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

# ---------- Storage ----------

resource "oci_file_storage_file_system" "cluster_shared" {
  availability_domain      = data.oci_identity_availability_domains.cluster_availability.availability_domains.2.name
  compartment_id           = var.compartment_ocid
  display_name             = "Cluster shared working storage"
}

resource "oci_file_storage_mount_target" "cluster_shared_mount" {
  availability_domain      = data.oci_identity_availability_domains.cluster_availability.availability_domains.2.name
  compartment_id           = var.compartment_ocid
  subnet_id = oci_core_subnet.cluster_subnet.id
  display_name = "Cluster shared working storage mount point"
}

resource "oci_file_storage_export_set" "cluster_shared_export_set" {
  mount_target_id = oci_file_storage_mount_target.cluster_shared_mount.id
  display_name = "Cluster shared storage export set"
}

resource "oci_file_storage_export" "cluster_shared_export" {
  export_set_id =  oci_file_storage_export_set.cluster_shared_export_set.id
  file_system_id = oci_file_storage_file_system.cluster_shared.id
  path = "/"
}


# ---------- Containers ----------

resource "oci_container_instances_container_instance" "cluster_frontend_instance" {
  availability_domain      = data.oci_identity_availability_domains.cluster_availability.availability_domains.2.name
  compartment_id           = var.compartment_ocid
  display_name             = "Cluster frontend"

  shape                    = "CI.Standard.E3.Flex"
  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }
  vnics {
    subnet_id             = oci_core_subnet.cluster_subnet.id
    is_public_ip_assigned = true
  }
  volumes {
    name = "shared"
    volume_type = "EMPTYDIR"
  }

  container_restart_policy = "ALWAYS"
  containers {
    image_url    = "simonireland/base-notebook:latest"
    display_name = "Cluster notebook frontend"

    volume_mounts {
      volume_name = "shared"
      mount_path = "/home/epydemic/shared"
    }
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

#     volume_mounts {
#       volume_name = "cluster_shared"
#       mount_path = "/home/epydemic/shared"
#     }
#     environment_variables = {
#       EPYDEMIC_CONTROLLER_HOST = "cluster_controller"
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
