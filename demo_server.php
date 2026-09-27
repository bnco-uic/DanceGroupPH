<?php
// Demo server router: serves the Flutter web build AND the PHP API on one port.
// Used by deploy_demo.bat:  php -S 127.0.0.1:8090 -t build/web demo_server.php
// Only the app and the API are reachable (not phpMyAdmin or the rest of XAMPP).

$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// /api/dance_groups.php and /api/health.php -> backend/api/
if (preg_match('#^/api/([a-z_]+\.php)$#', $path, $match)) {
    $file = __DIR__ . '/backend/api/' . $match[1];
    if (is_file($file)) {
        require $file;
        return true;
    }
    http_response_code(404);
    return true;
}

// Existing web build files (JS, fonts, images) are served as-is.
if ($path !== '/' && is_file(__DIR__ . '/build/web' . $path)) {
    return false;
}

// Everything else gets the app's index.html.
require __DIR__ . '/build/web/index.html';
return true;
