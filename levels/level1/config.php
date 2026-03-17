<?php
// Database configuration
// TODO: move to environment variables before prod deployment

define('DB_HOST', 'db.internal');
define('DB_PORT', 3306);
define('DB_NAME', 'appdb');
define('DB_USER', 'level2');
define('DB_PASS', 'LEVEL2_PASSWORD_PLACEHOLDER');

function getDbConnection() {
    $dsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME;
    return new PDO($dsn, DB_USER, DB_PASS);
}
