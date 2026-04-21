variable "compartment_id" {
  type = string
}

variable "vcn_id" {
  type = string
}

resource "oci_logging_log_group" "this" {
  compartment_id = var.compartment_id
  display_name   = "grupo-log-fluxo-vcn"
  description    = "Grupo de log para logs de fluxo da VCN"
}

# Comentado devido a erro de categoria/recurso na região de São Paulo para contas Free Tier
# resource "oci_logging_log" "vcn_flow_log" {
#   display_name = "log-fluxo-vcn"
#   log_group_id = oci_logging_log_group.this.id
#   log_type     = "SERVICE"
# 
#   configuration {
#     source {
#       category    = "all"
#       resource    = var.vcn_id
#       service     = "flowlogs"
#       source_type = "OCISERVICE"
#     }
#     compartment_id = var.compartment_id
#   }
# 
#   is_enabled         = true
#   retention_duration = 30
# }

output "log_group_id" {
  value = oci_logging_log_group.this.id
}
