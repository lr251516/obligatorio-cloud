# Módulo Security - Security Groups

## Descripción
Security Groups configurados por capas siguiendo buenas prácticas de seguridad para todos los componentes de la arquitectura.

## Arquitectura de Seguridad
```
Internet → CLB → EKS Nodes SG → RDS SG
    ↓
Bastion SG → RDS SG
```

## Security Groups Creados

### **CLB Security Group** 
- **Ingress:** 80/443 desde 0.0.0.0/0 (HTTP/HTTPS público)
- **Egress:** 80/8080 hacia VPC CIDR (comunicación con pods)
- **Propósito:** Load balancer público creado por Service LoadBalancer

### **EKS Control Plane Security Group**
- **Ingress:** 443 desde EKS nodes
- **Egress:** 1025-65535 hacia EKS nodes
- **Propósito:** Comunicación segura con workers

### **EKS Nodes Security Group**
- **Ingress:** 
  - 80/8080 desde VPC CIDR (CLB access)
  - 1025-65535 desde VPC CIDR (control plane)
  - Todo el tráfico desde otros nodes EKS (self)
- **Egress:** Todo el tráfico saliente
- **Propósito:** Worker nodes en subnets privadas

### **RDS Security Group**
- **Ingress:** 
  - 3306 desde EKS Nodes SG (aplicación)
  - 3306 desde Bastion SG (administración)
- **Egress:** Sin reglas salientes
- **Propósito:** Base de datos privada

## Principios Aplicados
- **Least Privilege** - Solo puertos necesarios
- **Segmentación** - Separación por función
- **Defense in Depth** - Múltiples capas
- **Zero Trust** - Verificación explícita

## Uso
```hcl
module "security" {
  source = "../../modules/security"

  project_name         = var.project_name
  vpc_id               = module.vpc.vpc_id
  vpc_cidr             = module.vpc.vpc_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
}
```

## Reglas Detalladas
| Security Group | Puerto | Protocolo | Origen | Descripción |
|----------------|--------|-----------|--------|-------------|
| CLB | 80 | TCP | 0.0.0.0/0 | HTTP público |
| CLB | 443 | TCP | 0.0.0.0/0 | HTTPS público |
| EKS Nodes | 80 | TCP | VPC CIDR | HTTP desde CLB |
| EKS Nodes | 8080 | TCP | VPC CIDR | Alt HTTP desde CLB |
| EKS Nodes | 1025-65535 | TCP | VPC CIDR | Control plane comm |
| RDS | 3306 | TCP | EKS Nodes SG | MySQL desde app |
| RDS | 3306 | TCP | Bastion SG | MySQL admin |

## Outputs
- `clb_security_group_id` - SG para Classic Load Balancer
- `eks_control_plane_security_group_id` - SG para EKS control plane
- `eks_nodes_security_group_id` - SG para worker nodes
- `rds_security_group_id` - SG para base de datos