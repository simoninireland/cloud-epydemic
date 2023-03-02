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
  availability_domain      = data.oci_identity_availability_domains.cluster_availability
  compartment_id           = var.compartment_ocid
  display_name             = "Cluster shared working storage"
}

resource "oci_file_storage_file_system" "cluster_data" {
  availability_domain      = data.oci_identity_availability_domains.cluster_availability
  compartment_id           = var.compartment_ocid
  display_name             = "Cluster notebook and data storage"
}


# ---------- Containers ----------

resource "oci_container_instances_container_instance" "cluster_frontend_instance" {
  availability_domain      = data.oci_identity_availability_domains.cluster_availability
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
    nsg_ids               = []
  }

  container_restart_policy = "ALWAYS"
  containers {
    image_url    = "simonireland/base-notebook:latest"
    display_name = "Cluster notebook frontend"

    mounts {
      volume_name = oci_file_storage_file_system.cluster_shared.id
      mount_path = "/home/epydemic/shared"
    }
  }
}

resource "oci_container_instances_container_instance" "cluster_controller_instance" {
  availability_domain      = data.oci_identity_availability_domains.cluster_availability
  compartment_id           = var.compartment_ocid
  display_name             = "Cluster controller"

  shape                    = "CI.Standard.E3.Flex"
  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }
  vnics {
    subnet_id             = oci_core_subnet.cluster_subnet.id
    nsg_ids               = []
    hostname_label        = "cluster_controller"
  }

  container_restart_policy = "ALWAYS"
  containers {
    image_url    = "simonireland/controller:latest"
    display_name = "Cluster controller"

    mounts {
      volume_name = oci_file_storage_file_system.cluster_shared.id
      mount_path = "/home/epydemic/shared"
    }
    environment_variables {
      EPYDEMIC_CONTROLLER_HOST = "cluster_controller"
    }
  }
}

resource "oci_container_instances_container_instance" "cluster_engine_instance" {
  availability_domain      = data.oci_identity_availability_domains.cluster_availability
  compartment_id           = var.compartment_ocid
  display_name             = "Cluster engines"

  shape                    = "CI.Standard.E3.Flex"
  shape_config {
    memory_in_gbs = 4
    ocpus         = 1
  }
  vnics {
    subnet_id             = oci_core_subnet.cluster_subnet.id
    nsg_ids               = []
  }

  container_restart_policy = "ALWAYS"
  containers {
    image_url    = "simonireland/base-engine:latest"
    display_name = "Cluster engine"

    mounts {
      volume_name = oci_file_storage_file_system.cluster_shared.id
      mount_path = "/home/epydemic/shared"
    }
    environment_variables {
      EPYDEMIC_ENGINES = 4
    }
  }
}
