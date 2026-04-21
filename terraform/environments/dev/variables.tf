variable "tenancy_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

variable "compartment_id" {
  description = "The OCID of the parent compartment"
  type        = string
}

variable "ssh_public_key" {
  description = "Conteúdo da chave pública SSH"
  type        = string
}
