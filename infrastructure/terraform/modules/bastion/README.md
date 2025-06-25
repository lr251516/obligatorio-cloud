# Módulo Bastion 

## Descripción
Bastion host para acceso de administración seguro a la base de datos RDS MySQL ubicada en las subnets privadas de base de datos

## Características
- **Amazon Linux 2** con herramientas MySQL preinstaladas
- **Acceso SSH** desde internet 
- **Scripts auxiliares** para conexión rápida a MySQL
- **Configurado para AWS Academy** con key pair 'vockey'

## Componentes
- **EC2 Instance** (t3.micro) en subnet pública
- **Security Group** permitiendo SSH (puerto 22)
- **Regla adicional** en RDS Security Group para acceso desde bastion
- **User Data** con instalación automática de cliente MySQL

## Uso
```hcl
module "bastion" {
  source = "../../modules/bastion"

  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  public_subnet_id       = module.vpc.public_subnet_ids[0]
  rds_security_group_id  = module.security.rds_security_group_id
  key_pair_name          = "vockey"
  mysql_host             = module.rds.db_instance_endpoint
}
```

## Conexión a MySQL
```bash
# 1. SSH al bastion
ssh -i ~/.ssh/vockey.pem ec2-user@BASTION_IP

# 2. Usar script incluido
./connect-mysql.sh

# 3. O conectar directamente
mysql -h RDS_HOST -u admin -p ecommerce
```

## Tunnel SSH para DBeaver
```bash
# En tu máquina local
ssh -i ~/.ssh/vockey.pem -L 3306:RDS_HOST:3306 ec2-user@BASTION_IP

# Luego configurar DBeaver con localhost:3306
```

## Outputs
- `bastion_public_ip` - IP pública del bastion
- `ssh_connection_command` - Comando SSH listo para usar
- `mysql_tunnel_command` - Comando para tunnel SSH