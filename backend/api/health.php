<?php
// Quick check that PHP runs and the database connection works.
// Open in a browser: http://localhost/api/health.php

require_once __DIR__ . '/../config/db.php';

$db = getDb();

try {
    $count = (int) $db->query('SELECT COUNT(*) FROM dance_groups')->fetchColumn();
} catch (PDOException $e) {
    error_log('Health check failed: ' . $e->getMessage());
    sendJson(500, false, 'Connected, but the dance_groups table is missing. Import the SQL file.');
}

sendJson(200, true, 'API and database are working.', [
    'php_version' => PHP_VERSION,
    'dance_groups' => $count,
]);
