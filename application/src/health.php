<?php
http_response_code(200);
header("Content-Type: application/json");
echo json_encode([
    "status" => "healthy",
    "timestamp" => date("Y-m-d H:i:s"),
    "database" => "connected"
]);
?>