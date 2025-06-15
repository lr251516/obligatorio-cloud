<?php
// Configuración generada automáticamente por Docker
// Generado: Sun Jun 15 23:06:17 UTC 2025

$host = 'mysql-db';
$name = 'ecommerce';
$user = 'ecommerce_user';
$password = 'ecommerce_pass';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$name", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch( PDOException $exception ) {
    echo "Connection error :" . $exception->getMessage();
}
