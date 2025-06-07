# 🛒 Online E-commerce

Este es un proyecto de aplicación web de comercio electrónico desarrollado en PHP. Utiliza enrutamiento personalizado, donde todas las rutas son gestionadas desde `index.php`, en lugar de depender del servidor web para mapear rutas a archivos físicos.

## 🚀 Objetivo

Construir una tienda online funcional que permita a los usuarios explorar productos, ver detalles, autenticarse y realizar compras.


## 🐳 Construcción de la Imagen

El proyecto se ejecuta sobre la imagen base oficial: `php:8.2-apache`

Esta imagen proporciona Apache y PHP preinstalados y configurados para integrarse correctamente, incluyendo soporte para `.htaccess`.

## 🔧 Configuración necesaria

### Habilitar el módulo `mod_rewrite`

La imagen `php:8.2-apache` ya incluye `mod_rewrite`, pero debe habilitarse manualmente en el `Dockerfile`:

```bash
a2enmod rewrite
```

Además, asegurate de permitir .htaccess modificando la directiva correspondiente en el archivo de configuración de Apache (/etc/apache2/apache2.conf): `AllowOverride All`

### Copiar el archivo .htaccess

Asegurate de incluir un archivo .htaccess en el directorio /var/www/html del contenedor. Podés usar la instrucción `COPY` o `ADD` en el `Dockerfile`

### Estructura del archivo .htaccess

```sh
# .htaccess file for a PHP application
RewriteEngine On

RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d

RewriteRule ^(.+)$ index.php?uri=$1 [QSA,L]
```

### Estructura del Proyecto

.
├── views/                # Vistas del sitio
├── index.php             # Punto de entrada principal
├── router.php            # Lógica de ruteo
├── csrf.php              # Protección CSRF
├── htaccess              # Reglas de reescritura para Apache
├── README.md             # Documentación del proyecto
├── db-settings.sql       # Archivo para crear las tablas en la BD
└── ...

```sh

```

## Admin Credentials

```sh
uri: /admin/login
username: admin
password: 123456
```
