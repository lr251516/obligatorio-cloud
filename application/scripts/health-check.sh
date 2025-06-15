#!/bin/bash

# Script de health check para contenedor E-commerce PHP

set -e

# Configuración
HEALTH_URL="http://localhost"
TIMEOUT=10
MAX_RETRIES=3

# Función para logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] HEALTH: $1"
}

# Función para verificar HTTP
check_http() {
    local url=$1
    local timeout=${2:-$TIMEOUT}
    
    if curl -f -s --max-time "$timeout" "$url" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Función para verificar base de datos
check_database() {
    # Verificar si el archivo de configuración existe
    if [ ! -f "/var/www/html/views/db.php" ]; then
        log "Archivo de configuración de DB no encontrado"
        return 1
    fi
    
    # Intentar conectar usando PHP
    php -r "
    include '/var/www/html/views/db.php';
    try {
        \$stmt = \$pdo->query('SELECT 1');
        echo 'OK';
    } catch (Exception \$e) {
        echo 'ERROR: ' . \$e->getMessage();
        exit(1);
    }
    " > /dev/null 2>&1
    
    return $?
}

# Función para verificar servicios críticos
check_services() {
    local errors=0
    
    # Verificar Apache
    if ! pgrep apache2 > /dev/null; then
        log "Apache no está ejecutándose"
        ((errors++))
    fi
    
    # Verificar PHP-FPM (si aplica)
    if command -v php-fpm &> /dev/null; then
        if ! pgrep php-fpm > /dev/null; then
            log "⚠️  PHP-FPM no está ejecutándose"
        fi
    fi
    
    # Verificar directorio de uploads
    if [ ! -w "/var/www/html/uploads" ]; then
        log "Directorio de uploads no escribible"
        ((errors++))
    fi
    
    return $errors
}

# Función principal de health check
main() {
    local exit_code=0
    
    log "Iniciando health check..."
    
    # 1. Verificar HTTP básico
    log " Verificando respuesta HTTP..."
    if check_http "$HEALTH_URL"; then
        log "✅ HTTP OK"
    else
        log "❌ HTTP FAILED"
        exit_code=1
    fi
    
    # 2. Verificar servicios
    log "⚙️  Verificando servicios..."
    if check_services; then
        log "✅ Servicios OK"
    else
        log "❌ Servicios FAILED"
        exit_code=1
    fi
    
    # 3. Verificar base de datos
    log "Verificando base de datos..."
    if check_database; then
        log "✅ Base de datos OK"
    else
        log "⚠️  Base de datos no disponible o con errores"
     
    fi
    
    # 4. Verificar archivos críticos
    log "Verificando archivos críticos..."
    critical_files=(
        "/var/www/html/index.php"
        "/var/www/html/.htaccess"
        "/var/www/html/views"
    )
    
    for file in "${critical_files[@]}"; do
        if [ ! -e "$file" ]; then
            log "❌ Archivo crítico faltante: $file"
            exit_code=1
        fi
    done
    
    if [ $exit_code -eq 0 ]; then
        log "✅ Health check completado exitosamente"
    else
        log "❌ Health check falló"
    fi
    
    return $exit_code
}

# Ejecutar health check
main "$@"