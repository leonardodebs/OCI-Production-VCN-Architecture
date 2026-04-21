variable "parent_compartment_id" {
  description = "OCID of the parent compartment"
  type        = string
}

variable "name_prefix" {
  default = "OCI-VCN-Arch"
  type    = string
}

resource "oci_identity_compartment" "network" {
  compartment_id = var.parent_compartment_id
  description    = "Compartimento de Rede para VCN e recursos relacionados"
  name           = "${var.name_prefix}-Rede"
  enable_delete  = true
}

resource "oci_identity_compartment" "compute" {
  compartment_id = var.parent_compartment_id
  description    = "Compartimento de Processamento para instâncias de aplicação"
  name           = "${var.name_prefix}-Compute"
  enable_delete  = true
}

resource "oci_identity_compartment" "database" {
  compartment_id = var.parent_compartment_id
  description    = "Compartimento de Banco de Dados"
  name           = "${var.name_prefix}-BancoDados"
  enable_delete  = true
}

output "network_compartment_id" {
  value = oci_identity_compartment.network.id
}

output "compute_compartment_id" {
  value = oci_identity_compartment.compute.id
}

output "database_compartment_id" {
  value = oci_identity_compartment.database.id
}
