# Módulo RDS - Base de Datos MySQL

## Descripción
Base de datos Amazon RDS MySQL con configuración Multi-AZ para alta disponibilidad, backups automáticos y encriptación de datos.

## Características
- **MySQL 8.0** con configuración Multi-AZ
- **Alta disponibilidad** con failover automático
- **Backups automáticos** con 7 días de retención
- **Encriptación** de datos en reposo
- **Performance Insights** habilitado
- **Subnets privadas** para seguridad

## Configuración de Alta Disponibilidad
- **Primary Instance** en AZ us-east-1a
- **Standby Instance** en AZ us-east-1b  
- **Failover automático** en caso de falla
- **RTO:** ~1-2 minutos para failover
- **RPO:** ~5 minutos (último backup)

## Especificaciones
- **Engine:** MySQL 8.0
- **Instance Class:** db.t3.medium
- **Storage:** 100GB GP3 SSD
- **Backup Window:** 03:00-04:00 UTC
- **Maintenance Window:** Domingo 04:00-05:00 UTC

## Seguridad
- **DB Subnet Group** en subnets privadas
- **Security Group** restrictivo (solo desde EKS y Bastion)
- **Encriptación** AES-256 en reposo
- **SSL/TLS** para conexiones

## Uso
```hcl
module "rds" {
  source = "../../modules/rds"

  project_name         = var.project_name
  db_subnet_group_name = module.vpc.database_subnet_group_name
  security_group_id    = module.security.rds_security_group_id

  # Configuración de base de datos
  engine_version    = "8.0"
  instance_class    = "db.t3.medium"
  allocated_storage = 100
  db_name           = "ecommerce"
  db_username       = "admin"
}
```

## Credenciales
- **Usuario:** admin
- **Contraseña:** admin1234 (configurada en módulo)
- **Base de datos:** ecommerce
- **Puerto:** 3306

## Conexión desde Aplicación
```php
$host = 'obligatorio-cloud-mysql.endpoint.rds.amazonaws.com';
$port = 3306;
$dbname = 'ecommerce';
$username = 'admin';
$password = 'admin1234';

$pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname", $username, $password);
```

## Backup y Restore
```bash
# Crear snapshot manual
aws rds create-db-snapshot \
  --db-instance-identifier db-obligatorio \
  --db-snapshot-identifier manual-snapshot-$(date +%Y%m%d)

# Restaurar desde snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier restored-db \
  --db-snapshot-identifier snapshot-name
```

## Monitoring
- **CloudWatch Metrics** - CPU, conexiones, IOPS
- **Performance Insights** - Queries lentas y bloqueos
- **Enhanced Monitoring** - Métricas del OS

## Outputs
- `db_instance_endpoint` - Endpoint de conexión
- `db_instance_id` - ID de la instancia RDS
- `db_name` - Nombre de la base de datos
- `db_port` - Puerto de conexión (3306)