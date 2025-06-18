FROM php:8.2-apache

LABEL maintainer="ORT Uruguay Student"
LABEL project="E-commerce EKS AWS"
LABEL version="1.0.0"
LABEL description="PHP E-commerce containerized for EKS deployment"

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

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        gd \
        zip \
        mbstring \
        exif

RUN pecl install imagick && docker-php-ext-enable imagick || echo "Imagick installation skipped"

RUN a2enmod rewrite

RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

RUN mkdir -p /var/www/html/uploads && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

COPY src/ /var/www/html/

COPY src/htaccess /var/www/html/.htaccess

COPY src/health.php /var/www/html/health.php


COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts/health-check.sh /usr/local/bin/health-check.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/health-check.sh

RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \; && \
    chmod 755 /var/www/html/uploads && \
    chmod 644 /var/www/html/.htaccess && \
    chmod 644 /var/www/html/health.php


ENV APP_ENV=production
ENV APP_DEBUG=false
ENV UPLOAD_PATH=/var/www/html/uploads
ENV APACHE_DOCUMENT_ROOT=/var/www/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/health-check.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["apache2-foreground"]