<?php
// Configuración generada automáticamente por Docker
// Generado: Sat Jun 21 21:58:15 UTC 2025

$host = getenv('DB_HOST') ?: 'localhost';
$port = getenv('DB_PORT') ?: '3306';
$name = getenv('DB_NAME') ?: 'ecommerce';
$user = getenv('DB_USER') ?: 'admin';
$password = getenv('DB_PASSWORD') ?: 'admin1234';

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$name", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch( PDOException $exception ) {
    echo "Connection error :" . $exception->getMessage();
}
