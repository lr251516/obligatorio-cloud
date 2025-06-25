FROM php:8.2-apache

LABEL maintainer="ORT Uruguay"
LABEL project="E-commerce EKS AWS"
LABEL version="1.0.0"
LABEL description="PHP E-commerce containerized for EKS deployment"

# Dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libmagickwand-dev \
    unzip \
    curl \
    vim \
    default-mysql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Extensiones PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        gd \
        zip \
        mbstring \
        exif \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-source delete

# Configuracion Apache
RUN a2enmod rewrite \
    && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Directorios y permisos base
RUN mkdir -p /var/www/html/uploads \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Scripts
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/health-check.sh /usr/local/bin/health-check.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/health-check.sh

# Configuracion de la base de datos
COPY src/db-settings.sql /docker-entrypoint-initdb.d/db-settings.sql

# Codigo fuente
COPY src/ /var/www/html/

# Permisos finales
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \; \
    && chmod 755 /var/www/html/uploads \
    && chmod 644 /var/www/html/.htaccess \
    && chmod 644 /var/www/html/health.php

# Variables de entorno
ENV APP_ENV=production \
    APP_DEBUG=true \
    UPLOAD_PATH=/var/www/html/uploads \
    APACHE_DOCUMENT_ROOT=/var/www/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/health-check.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]