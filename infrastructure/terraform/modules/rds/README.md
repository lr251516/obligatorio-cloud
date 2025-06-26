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

## 🛒 Cargar Productos de Ejemplo

### 1. Conectar vía Bastion Host
```bash
# SSH al bastion host
ssh -i ~/.ssh/vockey.pem ec2-user@BASTION_IP

# Conectar a MySQL
./connect-mysql.sh
```

### 2. Insertar Categorías
```sql
-- Insertar categorías de productos
INSERT INTO categories (title) VALUES 
('Electronics'),
('Clothing');
```

### 3. Insertar Productos de Ejemplo
```sql
-- Productos de electrónicos
INSERT INTO products (title, price, description, category, images) VALUES 
('iPhone 15 Pro', 999.99, 'El último iPhone con chip A17 Pro, cámara de 48MP y pantalla ProMotion. Diseño en titanio premium con conectividad 5G avanzada.', 'Electronics', 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400'),
('MacBook Air M3', 1299.99, 'MacBook Air con chip M3, 13 pulgadas, 8GB RAM y 256GB SSD. Rendimiento excepcional con hasta 18 horas de batería.', 'Electronics', 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400'),
('AirPods Pro 2', 249.99, 'Auriculares inalámbricos con cancelación activa de ruido, audio espacial personalizado y hasta 6 horas de reproducción.', 'Electronics', 'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=400');

-- Productos de ropa
INSERT INTO products (title, price, description, category, images) VALUES 
('Nike Air Force 1', 89.99, 'Zapatillas clásicas Nike Air Force 1 en color blanco. Comodidad y estilo atemporal para uso diario.', 'Clothing', 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400'),
('Adidas Hoodie', 59.99, 'Sudadera con capucha Adidas Originals, 100% algodón, corte regular. Disponible en varios colores.', 'Clothing', 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400'),
('Levi''s 501 Jeans', 79.99, 'Jeans clásicos Levi''s 501, corte straight, 100% algodón. El jean original desde 1873.', 'Clothing', 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=400');
```

### 4. Verificar Datos Insertados
```sql
-- Ver todas las categorías
SELECT * FROM categories;

-- Ver todos los productos
SELECT id, title, price, category FROM products;

-- Ver productos por categoría
SELECT p.title, p.price, c.title as category_name 
FROM products p 
JOIN categories c ON p.category = c.title 
ORDER BY c.title, p.price;
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