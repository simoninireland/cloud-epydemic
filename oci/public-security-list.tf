# OCI security set-up for public subnet
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

# For protocol numbers https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
# For ICMP types and codes see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml


resource "oci_core_security_list" "public-security-list" {
  compartment_id = oci_identity_compartment.tf-compartment.id
  vcn_id = module.vcn.vcn_id
  display_name = "security-list-for-public-subnet"

  egress_security_rules {
    stateless = false
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol = "all"
  }

  ingress_security_rules {
    stateless = false
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol = "6"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    stateless = false
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol = "1"
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    stateless = false
    source = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    protocol = "1"
    icmp_options {
      type = 3
    }
  }
}
