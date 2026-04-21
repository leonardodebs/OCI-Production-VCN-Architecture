# Runbook Operacional e Troubleshooting

Este documento fornece procedimentos padrão para a operação, manutenção e resolução de problemas da infraestrutura VCN.

## 1. Procedimentos Operacionais

### 1.1 Atualização da Infraestrutura
Sempre que houver alteração nos módulos Terraform:
1.  Navegue até o ambiente (`terraform/environments/dev` ou `prod`).
2.  Execute `terraform plan -out=plan.tfplan`.
3.  Revise as alterações cuidadosamente.
4.  Execute `terraform apply "plan.tfplan"`.

### 1.2 Rotação de Chaves de API
1.  Gere um novo par de chaves RSA.
2.  Adicione a chave pública ao Console OCI do usuário de deploy.
3.  Atualize o segredo no GitHub Actions ou as variáveis locais.
4.  Remova a chave antiga do Console OCI após validar que a nova funciona.

## 2. Troubleshooting (Resolução de Problemas)

### 2.1 Instância Privada sem Acesso à Internet
**Sintoma**: Comandos como `curl google.com` ou `apt update` falham.
1.  **Verifique o NAT Gateway**: Certifique-se de que ele existe e está `Available`.
2.  **Verifique a Tabela de Roteamento**: A sub-rede privada deve ter uma regra apontando `0.0.0.0/0` para o NAT Gateway.
3.  **Verifique a Lista de Segurança/NSG**: Deve haver uma regra de SAÍDA (egress) permitindo tráfego para `0.0.0.0/0` em todos os protocolos.

### 2.2 Falha na Conectividade com o Banco de Dados
**Sintoma**: A aplicação não consegue conectar ao banco.
1.  **Verifique o NSG**: O NSG do Banco de Dados deve permitir a porta específica (ex: 3306 para MySQL) vindo do NSG da aplicação.
2.  **Verifique a Sub-rede**: Certifique-se de que a instância de aplicação e o banco estão na mesma VCN ou se há peering (neste projeto, estão na mesma VCN).

### 2.3 Logs de Erro no Terraform
*   **Erro 404 (Not Found)**: Geralmente OCIDs incorretos em `terraform.tfvars`.
*   **Erro 401 (Not Authenticated)**: Chave privada, fingerprint ou OCID do usuário incorretos.
*   **Erro 409 (Conflict)**: Tentativa de criar um recurso com nome de DNS duplicado dentro da mesma VCN.

## 3. Gestão de Estado (Backend)

O estado é armazenado no OCI Object Storage. Se o estado ficar bloqueado por uma operação interrompida:
1.  Certifique-se de que não há ninguém aplicando o Terraform.
2.  Localize o arquivo de bloqueio no bucket.
3.  Use `terraform force-unlock <LOCK_ID>` se necessário (use com extrema cautela).

## 4. Contatos de Emergência
*   **Administrador de Cloud**: [SEU NOME / TIME]
*   **Suporte OCI (MOS)**: [Link para o My Oracle Support]
