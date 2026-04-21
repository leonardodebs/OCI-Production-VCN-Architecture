variable "compartment_id" {
  description = "OCID of the compartment where the VCN will be created"
  type        = string
}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
  type    = string
}

variable "vcn_dns_label" {
  default = "production"
  type    = string
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
  type    = string
}

variable "private_subnet_cidr" {
  default = "10.0.10.0/24"
  type    = string
}

variable "database_subnet_cidr" {
  default = "10.0.20.0/24"
  type    = string
}

resource "oci_core_vcn" "this" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = "vcn-producao"
  dns_label      = var.vcn_dns_label
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "gateway-internet"
  enabled        = true
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "gateway-nat"
}

data "oci_core_services" "all_services" {
}

resource "oci_core_service_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "gateway-servico"
  services {
    service_id = data.oci_core_services.all_services.services[0].id
  }
}

# Tabelas de Roteamento
resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "tabela-rota-publica"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "tabela-rota-privada"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
  }

  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
  }
}

resource "oci_core_route_table" "database" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = "tabela-rota-banco-dados"

  route_rules {
    destination       = data.oci_core_services.all_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
  }
}

# Sub-redes
resource "oci_core_subnet" "public" {
  cidr_block        = var.public_subnet_cidr
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.this.id
  display_name      = "subrede-publica"
  dns_label         = "publica"
  route_table_id    = oci_core_route_table.public.id
  prohibit_internet_ingress = false
}

resource "oci_core_subnet" "private" {
  cidr_block        = var.private_subnet_cidr
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.this.id
  display_name      = "subrede-privada"
  dns_label         = "privada"
  route_table_id    = oci_core_route_table.private.id
  prohibit_internet_ingress = true
}

resource "oci_core_subnet" "database" {
  cidr_block        = var.database_subnet_cidr
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.this.id
  display_name      = "subrede-banco-dados"
  dns_label         = "db"
  route_table_id    = oci_core_route_table.database.id
  prohibit_internet_ingress = true
}

output "vcn_id" {
  value = oci_core_vcn.this.id
}

output "public_subnet_id" {
  value = oci_core_subnet.public.id
}

output "private_subnet_id" {
  value = oci_core_subnet.private.id
}

output "database_subnet_id" {
  value = oci_core_subnet.database.id
}
