variable "tenancy_ocid" {
  description = "Tenancy ID"
  type = string
  sensitive = true
}
variable "oci_region" {
  description = "Region"
  type = string
}

variable "compartment_ocid" {
  description = "Compartment ID"
  type = string
}

variable "user_ocid" {
  description = "User ID"
  type = string
  sensitive = true
}
variable "key_fingerprint" {
  description = "Public key fingerprint"
  type = string
}
variable "private_key_path" {
  description = "Path to private key"
  type = string
  sensitive = true
}

variable "home_address_cidr" {
  description = "Network mask from which connections are allowed"
  type = string
}
