# Este é um modelo para o backend remoto.
# Você deve inicializar o bucket primeiro usando o script em scripts/bootstrap-state.sh
# Depois, descomente e preencha os valores.

# terraform {
#   backend "s3" {
#     bucket   = "terraform-remote-state-xxxxxx"
#     key      = "prod/terraform.tfstate"
#     region   = "us-ashburn-1"
#     endpoint = "https://NAMESPACE.compat.objectstorage.REGION.oraclecloud.com"
#     
#     skip_region_validation      = true
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     force_path_style            = true
#   }
# }
