# Terraform provider for OCI
#
# Copyright (C) 2023 Simon Dobson
#
# This file is part of cloud-epydemic, network simulation as a service
#
# cloud-epydemic is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
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

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.108.1"
    }
  }
}

provider "oci" {
  tenancy_ocid     = var.OCI_TENANCY_OCID
  user_ocid        = var.OCI_USER_OCID
  private_key_path = var.OCI_PRIVATE_KEY_PATH
  fingerprint      = var.OCI_PRIVATE_KEY_FINGERPRINT
  region           = var.OCI_REGION
}
