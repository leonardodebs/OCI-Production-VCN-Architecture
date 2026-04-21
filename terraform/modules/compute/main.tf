variable "compartment_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "nsg_id" {
  type = string
}

variable "ssh_public_key" {
  description = "Conteúdo da sua chave pública SSH (id_rsa.pub)"
  type        = string
}

# Pegando a imagem mais recente do Oracle Linux 8
data "oci_core_images" "linux" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E2.1.Micro"
}

resource "oci_core_instance" "test_web_server" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  display_name        = "servidor-web-teste"
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "vnic-principal"
    assign_public_ip = true
    nsg_ids          = [var.nsg_id]
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.linux.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(<<-EOF
      #!/bin/bash
      # Instalação do Nginx
      yum install -y nginx
      systemctl enable --now nginx
      
      # Abrindo porta no firewall interno do Linux
      firewall-offline-cmd --add-service=http
      systemctl restart firewalld

      # Criando página de teste premium
      cat <<HTML > /usr/share/nginx/html/index.html
      <!DOCTYPE html>
      <html>
      <head>
          <title>OCI VCN Architecture - Sucesso!</title>
          <style>
              body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #1a1a1a; color: white; text-align: center; padding-top: 50px; }
              .card { background: #2d2d2d; border-radius: 15px; padding: 40px; display: inline-block; box-shadow: 0 10px 30px rgba(0,0,0,0.5); border: 1px solid #444; }
              h1 { color: #00a4ef; }
              .status { color: #4caf50; font-weight: bold; }
          </style>
      </head>
      <body>
          <div class="card">
              <h1>🚀 Servidor Web Ativo!</h1>
              <p>A infraestrutura Terraform na <strong>Oracle Cloud</strong> foi provisionada com sucesso.</p>
              <p class="status">● Sistema Operacional: Oracle Linux 8</p>
              <p>Sub-rede: Pública | Segurança: NSG Ativo</p>
          </div>
      </body>
      </html>
      HTML
    EOF
    )
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

output "public_ip" {
  value = oci_core_instance.test_web_server.public_ip
}
