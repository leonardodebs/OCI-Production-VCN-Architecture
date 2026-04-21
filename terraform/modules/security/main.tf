variable "compartment_id" {
  type = string
}

variable "vcn_id" {
  type = string
}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
  type    = string
}

# Listas de Segurança
resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "lista-seguranca-publica"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_security_list" "internal" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "lista-seguranca-interna"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "all"
    source   = var.vcn_cidr
  }
}

# Grupos de Segurança de Rede (NSGs)
resource "oci_core_network_security_group" "web_lb" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "nsg-lb-web"
}

resource "oci_core_network_security_group_security_rule" "web_lb_80" {
  network_security_group_id = oci_core_network_security_group.web_lb.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "web_lb_443" {
  network_security_group_id = oci_core_network_security_group.web_lb.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group" "app" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "nsg-aplicacao"
}

resource "oci_core_network_security_group_security_rule" "app_from_lb" {
  network_security_group_id = oci_core_network_security_group.app.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = oci_core_network_security_group.web_lb.id
  source_type               = "NETWORK_SECURITY_GROUP"
}

output "public_security_list_id" {
  value = oci_core_security_list.public.id
}

output "internal_security_list_id" {
  value = oci_core_security_list.internal.id
}

output "web_lb_nsg_id" {
  value = oci_core_network_security_group.web_lb.id
}

output "app_nsg_id" {
  value = oci_core_network_security_group.app.id
}
