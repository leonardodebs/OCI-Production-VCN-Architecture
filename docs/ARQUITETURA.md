# Documentação de Arquitetura: Fundação VCN OCI

Este documento detalha as decisões técnicas e a estrutura da rede implementada para a arquitetura de produção na Oracle Cloud Infrastructure (OCI).

## 1. Topologia de Rede (VCN)

A VCN foi configurada com o bloco CIDR `10.0.0.0/16`, fornecendo um espaço de endereçamento amplo para crescimento futuro. O rótulo DNS foi definido como `producao`.

### 1.1 Segmentação de Sub-redes

A rede é dividida em três camadas distintas para garantir o isolamento de recursos:

1.  **Sub-rede Pública (Camada DMZ)**:
    *   **CIDR**: `10.0.1.0/24`
    *   **Propósito**: Hospedar Load Balancers, instâncias de Bastion (salto) e gateways que requerem acessibilidade externa direta.
    *   **Internet Ingress**: Permitido via Internet Gateway (IGW).

2.  **Sub-rede Privada (Camada de Aplicação)**:
    *   **CIDR**: `10.0.10.0/24`
    *   **Propósito**: Hospedar servidores de backend, APIs e processamento.
    *   **Egress**: Via NAT Gateway para atualizações de software.
    *   **Internet Ingress**: Proibido.

3.  **Sub-rede de Banco de Dados (Camada de Dados)**:
    *   **CIDR**: `10.0.20.0/24`
    *   **Propósito**: Hospedar instâncias de banco de dados (MySQL, Oracle DB, PostgreSQL).
    *   **Isolamento**: Máximo. Acesso apenas via camadas de aplicação específicas.
    *   **Egress**: Apenas via Service Gateway para serviços nativos OCI (Backups, etc).

## 2. Gateways e Roteamento

*   **Internet Gateway (IGW)**: Fornece conectividade bidirecional para a Internet para a sub-rede pública.
*   **NAT Gateway**: Permite que instâncias em sub-redes privadas iniciem conexões com a Internet (ex: `apt update`), mas impede conexões de entrada.
*   **Service Gateway (SGW)**: Permite que recursos privados acessem serviços públicos da OCI (Object Storage, Logging, etc.) através do backbone interno da Oracle, sem passar pela Internet pública.

## 3. Segurança de Rede

A segurança é implementada em duas camadas:

### 3.1 Listas de Segurança (Subnet Level)
Atuam como firewalls a nível de sub-rede.
*   **Pública**: Permite portas 22, 80 e 443 de qualquer lugar.
*   **Interna**: Permite todo o tráfego dentro da VCN (`10.0.0.0/16`).

### 3.2 Network Security Groups (Instance Level)
Permitem controle granular entre microserviços.
*   **nsg-lb-web**: Controla quem pode acessar o Load Balancer.
*   **nsg-aplicacao**: Permite tráfego apenas vindo do NSG do Load Balancer.

## 4. Observabilidade

A arquitetura inclui **VCN Flow Logs**, que capturam informações sobre o tráfego IP de entrada e saída na VCN. Esses logs são essenciais para:
*   Auditoria de segurança.
*   Troubleshooting de conectividade.
*   Monitoramento de custos de tráfego.

## 5. Estrutura de Compartimentos

A organização segue o princípio do menor privilégio:
*   `PROD-OCI-Arch-Rede`: Isolamento da infraestrutura de rede.
*   `PROD-OCI-Arch-Compute`: Instâncias e instâncias de aplicação.
*   `PROD-OCI-Arch-BancoDados`: Dados persistentes.
