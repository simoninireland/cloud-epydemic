# OCI virtual cloud network module
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

module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = "3.5.3"

  region = var.OCI_REGION
  compartment_id = oci_identity_compartment.tf-compartment.id
  label_prefix = ""

  internet_gateway_route_rules = null
  local_peering_gateways = null
  nat_gateway_route_rules = null

  vcn_name = "kube-vcn"
  vcn_dns_label = "kube"
  vcn_cidrs = ["10.0.0.0/16"]

  create_internet_gateway = true
  create_nat_gateway = true
  create_service_gateway = true
}
