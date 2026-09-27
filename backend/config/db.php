<?php
// Shared helpers: JSON headers, JSON responses, and the PDO connection.

// Every response is JSON, and any origin may call the API (CORS).
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Browsers send an OPTIONS "preflight" request before PUT/DELETE. Answer it and stop.
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Sends the standard envelope { success, message, data } and stops the script.
function sendJson(int $status, bool $success, string $message, $data = null): void
{
    http_response_code($status);
    echo json_encode(
        ['success' => $success, 'message' => $message, 'data' => $data],
        JSON_UNESCAPED_UNICODE
    );
    exit;
}

// Opens the database connection. On failure we log the real error
// and return a generic message (never show SQL or credentials).
function getDb(): PDO
{
    $configFile = __DIR__ . '/config.php';
    if (!file_exists($configFile)) {
        sendJson(500, false, 'Server is not configured. Copy config.example.php to config.php.');
    }
    $config = require $configFile;

    try {
        $dsn = "mysql:host={$config['db_host']};dbname={$config['db_name']};charset=utf8mb4";
        return new PDO($dsn, $config['db_user'], $config['db_pass'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    } catch (PDOException $e) {
        error_log('DB connection failed: ' . $e->getMessage());
        sendJson(500, false, 'Could not connect to the database.');
    }
}
