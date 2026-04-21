module "compartments" {
  source                 = "../../modules/compartments"
  parent_compartment_id  = var.compartment_id
  name_prefix            = "PROD-OCI-Arch"
}

module "vcn" {
  source               = "../../modules/vcn"
  compartment_id       = module.compartments.network_compartment_id
  vcn_cidr             = "10.0.0.0/16"
  vcn_dns_label        = "production"
  public_subnet_cidr   = "10.0.1.0/24"
  private_subnet_cidr  = "10.0.10.0/24"
  database_subnet_cidr = "10.0.20.0/24"
}

module "security" {
  source         = "../../modules/security"
  compartment_id = module.compartments.network_compartment_id
  vcn_id         = module.vcn.vcn_id
  vcn_cidr       = "10.0.0.0/16"
}

module "flow_logs" {
  source         = "../../modules/flow-logs"
  compartment_id = module.compartments.network_compartment_id
  vcn_id         = module.vcn.vcn_id
}
