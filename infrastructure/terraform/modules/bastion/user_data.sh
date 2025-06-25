#!/bin/bash

yum update -y

yum install -y mysql telnet htop wget curl

timedatectl set-timezone America/Montevideo

# Script para conectar a MySQL
cat > /home/ec2-user/connect-mysql.sh << 'EOF'
#!/bin/bash
echo "Conectando a RDS MySQL..."
# Extraer solo el hostname sin el puerto
DB_HOST_CLEAN=$(echo "${mysql_host}" | cut -d: -f1)
echo "Host: $DB_HOST_CLEAN"
echo "User: admin"
echo "Database: ecommerce"
echo ""
mysql -h "$DB_HOST_CLEAN" -P 3306 -u admin -p ecommerce
EOF

chmod +x /home/ec2-user/connect-mysql.sh
chown ec2-user:ec2-user /home/ec2-user/connect-mysql.sh

# Script para verificar conectividad
cat > /home/ec2-user/test-mysql.sh << 'EOF'
#!/bin/bash
echo "Verificando conectividad a MySQL..."
# Extraer solo el hostname sin el puerto
DB_HOST_CLEAN=$(echo "${mysql_host}" | cut -d: -f1)
echo "Probando conexión a: $DB_HOST_CLEAN:3306"
telnet "$DB_HOST_CLEAN" 3306
EOF

chmod +x /home/ec2-user/test-mysql.sh
chown ec2-user:ec2-user /home/ec2-user/test-mysql.sh

# Mensaje de bienvenida
cat > /etc/motd << 'EOF'
===============================================
BASTION HOST - E-COMMERCE OBLIGATORIO
===============================================
Scripts disponibles:
  ./connect-mysql.sh    - Conectar a MySQL
  ./test-mysql.sh       - Probar conectividad

Para crear tunnel SSH desde tu máquina:
  ssh -L 3306:RDS_HOST:3306 ec2-user@BASTION_IP

Luego usar DBeaver con localhost:3306
===============================================
EOF

echo "Bastion host configurado exitosamente" > /var/log/user-data.log
date >> /var/log/user-data.log