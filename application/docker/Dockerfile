FROM php:8.2-apache

#Metadatos del proyecto
LABEL maintainer="ORT Uruguay"
LABEL project="Obligatorio Soluciones Cloud"
LABEL version="1.0.0"
LABEL description="PHP E-commerce containerized for EKS AWS"

#Instalar dependencias y extensiones de PHP
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libmagickwand-dev \
    unzip \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

#Configurar e instalar extensiones de PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        gd \
        zip \
        mbstring \
        exif

#Instalar y habilitar la extensión Imagick
RUN pecl install imagick && docker-php-ext-enable imagick || echo "Imagick installation skipped"

# Habilitar mod_rewrite para .htaccess
RUN a2enmod rewrite

#Configurar Apache para permitir el uso de .htaccess
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

#Crear directorio de uploads y establecer permisos
RUN mkdir -p /var/www/html/uploads && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

#Copiar archivos de la aplicación al contenedor    
COPY src/ /var/www/html/

# Copiar archivo .htaccess al directorio raíz de la aplicación
COPY src/htaccess /var/www/html/.htaccess

#Copiar scripts de entrada y health check
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/health-check.sh /usr/local/bin/health-check.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/health-check.sh

#Configuracion de permisos
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 644 /var/www/html && \
    chmod -R 755 /var/www/html/uploads && \
    chmod 644 /var/www/html/.htaccess

#Variables de entorno
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV UPLOAD_PATH=/var/www/html/uploads
ENV APACHE_DOCUMENT_ROOT=/var/www/html

#Exponer puerto 80 para el servidor web
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

#Usar script de entrada personalizado    
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]