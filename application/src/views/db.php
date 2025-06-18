<?php
// Configuración generada automáticamente por Docker
// Generado: Wed Jun 18 01:46:00 UTC 2025

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
