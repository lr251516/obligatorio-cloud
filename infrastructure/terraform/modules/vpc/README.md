# Módulo VPC - Red Multi-AZ

## Descripción
Crea una VPC completa con subnets públicas, privadas y de base de datos distribuidas en múltiples AZ's para alta disponibilidad.

## Arquitectura de Red
```
VPC: 10.0.0.0/16
├── AZ us-east-1a
│   ├── Subnet Pública: 10.0.1.0/24
│   ├── Subnet Privada: 10.0.11.0/24
│   └── Subnet Database: 10.0.21.0/24
└── AZ us-east-1b  
    ├── Subnet Pública: 10.0.2.0/24
    ├── Subnet Privada: 10.0.12.0/24
    └── Subnet Database: 10.0.22.0/24
```

## Componentes Creados
- **VPC** con DNS habilitado
- **Internet Gateway** para acceso a internet
- **NAT Gateways** (2) para conectividad saliente desde subnets privadas
- **Route Tables** configuradas automáticamente
- **DB Subnet Group** para RDS Multi-AZ

## Uso
```hcl
module "vpc" {
  source = "../../modules/vpc"

  project_name          = var.project_name
  vpc_cidr              = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24"]
}
```

## Outputs
- `vpc_id` - ID de la VPC creada
- `public_subnet_ids` - IDs de las subnets públicas
- `private_subnet_ids` - IDs de las subnets privadas
- `database_subnet_ids` - IDs de las subnets de base de datos
- `nat_gateway_ids` - IDs de los NAT Gateways