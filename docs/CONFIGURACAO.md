# Guia de Configuração e Variáveis

Este documento descreve as variáveis necessárias para provisionar a infraestrutura e fornece templates para configuração local e CI/CD.

## 1. Variáveis de Autenticação OCI

Estas variáveis são obrigatórias para que o Terraform se comunique com sua conta Oracle Cloud.

| Variável | Descrição | Exemplo |
| :--- | :--- | :--- |
| `tenancy_ocid` | OCID da sua Tenancy (Conta principal) | `ocid1.tenancy.oc1..aaaaaaa...` |
| `user_ocid` | OCID do usuário IAM que fará o deploy | `ocid1.user.oc1..aaaaaaa...` |
| `fingerprint` | Fingerprint da chave de API pública | `20:3b:97:13:55:...` |
| `private_key_path` | Caminho local para a chave privada `.pem` | `../../oci_api_key.pem` |
| `region` | Região principal da OCI | `us-ashburn-1` |
| `compartment_id` | OCID do compartimento pai (Raiz do projeto) | `ocid1.compartment.oc1..aaa...` |

## 2. Template `terraform.tfvars`

Crie um arquivo chamado `terraform.tfvars` dentro de `terraform/environments/dev/` (e prod) com o seguinte conteúdo:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..exemplo"
user_ocid        = "ocid1.user.oc1..exemplo"
fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "./oci_api_key.pem"
region           = "us-ashburn-1"
compartment_id   = "ocid1.compartment.oc1..exemplo"
```

## 3. Configuração do GitHub Secrets

Para o funcionamento do workflow automatizado, adicione os seguintes segredos ao seu repositório:

*   `OCI_TENANCY_OCID`
*   `OCI_USER_OCID`
*   `OCI_FINGERPRINT`
*   `OCI_REGION`
*   `OCI_COMPARTMENT_OCID`
*   `OCI_PRIVATE_KEY` (Conteúdo completo do arquivo `.pem`)

## 4. Variáveis de Ambiente (Shell)

Se preferir usar variáveis de ambiente em vez de `.tfvars`:

```bash
export TF_VAR_tenancy_ocid="ocid1.tenancy..."
export TF_VAR_user_ocid="ocid1.user..."
export TF_VAR_fingerprint="xx:xx:xx..."
export TF_VAR_private_key_path="/path/to/key.pem"
export TF_VAR_region="us-ashburn-1"
export TF_VAR_compartment_id="ocid1.compartment..."
```
