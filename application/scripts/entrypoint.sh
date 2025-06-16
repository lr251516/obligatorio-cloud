#!/bin/bash

#Script de entrada para contenedor E-commerce PHP

set -e

echo "🚀 Iniciando contenedor E-commerce PHP..."
echo "📅 $(date)"
echo "🏷️  Versión: 1.0.0"

# Función para logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Variables de base de datos
DB_HOST=${DB_HOST:-"localhost"}
DB_NAME=${DB_NAME:-"ecommerce"}
DB_USER=${DB_USER:-"root"}
DB_PASSWORD=${DB_PASSWORD:-""}

# Variables de aplicación
APP_ENV=${APP_ENV:-"production"}
APP_DEBUG=${APP_DEBUG:-"false"}
UPLOAD_PATH=${UPLOAD_PATH:-"/var/www/html/uploads"}

log "📊 Configuración detectada:"
log "   - DB Host: $DB_HOST"
log "   - DB Name: $DB_NAME"
log "   - DB User: $DB_USER"
log "   - App Env: $APP_ENV"
log "   - Debug: $APP_DEBUG"

# Generar configuración de base de datos
log "📝 Generando configuración de base de datos..."
cat > /var/www/html/views/db.php << EOF
<?php
// Configuración generada automáticamente por Docker
// Generado: $(date)

\$host = '${DB_HOST}';
\$name = '${DB_NAME}';
\$user = '${DB_USER}';
\$password = '${DB_PASSWORD}';

try {
    \$pdo = new PDO("mysql:host=\$host;dbname=\$name", \$user, \$password);
    \$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch( PDOException \$exception ) {
    echo "Connection error :" . \$exception->getMessage();
}
EOF

# Verificar y crear directorio de uploads
log "📁 Configurando directorio de uploads..."
if [ ! -d "$UPLOAD_PATH" ]; then
    mkdir -p "$UPLOAD_PATH"
    log "   ✅ Directorio creado: $UPLOAD_PATH"
fi

# Configurar permisos básicos
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html


# Verificar que .htaccess existe y tiene contenido
log "🔧 Verificando .htaccess..."
if [ ! -f "/var/www/html/.htaccess" ] || [ ! -s "/var/www/html/.htaccess" ]; then
    log "   ⚠️  .htaccess no encontrado o vacío, creando..."
    if [ -f "/var/www/html/htaccess" ]; then
        cp /var/www/html/htaccess /var/www/html/.htaccess
        log "   ✅ .htaccess creado desde archivo htaccess"
    else
        log "   ⚠️  Archivo htaccess no encontrado, creando .htaccess básico"
        cat > /var/www/html/.htaccess << 'EOF'
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.+)$ index.php?uri=$1 [QSA,L]
EOF
        log "   ✅ .htaccess básico creado"
    fi
else
    log "   ✅ .htaccess existe y tiene contenido"
fi

# Configurar permisos finales
chmod 644 /var/www/html/.htaccess
log "   ✅ Permisos configurados"

# Configurar PHP según el entorno
log "⚙️  Configurando PHP para entorno: $APP_ENV"

if [ "$APP_ENV" = "development" ]; then
    # Configuración para desarrollo
    echo "display_errors = On" >> /usr/local/etc/php/php.ini
    echo "error_reporting = E_ALL" >> /usr/local/etc/php/php.ini
    log "   ✅ Modo desarrollo activado"
else
    # Configuración para producción
    echo "display_errors = Off" >> /usr/local/etc/php/php.ini
    echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT" >> /usr/local/etc/php/php.ini
    log "   ✅ Modo producción activado"
fi

# Verificar conectividad a base de datos
if command -v mysql &> /dev/null; then
    log "🔍 Verificando conexión a base de datos..."
    
    for i in {1..30}; do
        if mysql -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" &>/dev/null; then
            log "   ✅ Conexión a base de datos exitosa"
            break
        fi
        if [ $i -eq 30 ]; then
            log "   ⚠️  No se pudo conectar a la base de datos"
        else
            log "   ⏳ Esperando base de datos... (intento $i/30)"
            sleep 2
        fi
    done
fi

# Verificar que Apache está configurado correctamente
log "🌐 Verificando configuración de Apache..."
if apache2ctl configtest 2>/dev/null; then
    log "   ✅ Configuración de Apache válida"
else
    log "   ⚠️  Advertencia en configuración de Apache"
fi

# Mostrar información del sistema
log "💻 Información del sistema:"
log "   - PHP: $(php -r 'echo PHP_VERSION;')"
log "   - Apache: $(apache2 -v | head -1 | cut -d' ' -f3)"
log "   - Usuario: $(whoami)"
log "   - Directorio: $(pwd)"

# Configurar logs
log "📋 Configurando logs..."
touch /var/log/apache2/error.log
touch /var/log/apache2/access.log
chown www-data:www-data /var/log/apache2/*.log

log "🎉 Inicialización completa. Iniciando Apache..."
log "🌍 Aplicación disponible en puerto 80"

# Ejecutar comando original (apache2-foreground)
exec "$@"