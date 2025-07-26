<?php

namespace Tqdev\PhpCrudApi;

use Tqdev\PhpCrudApi\Api;
use Tqdev\PhpCrudApi\Config\Config;
use Tqdev\PhpCrudApi\RequestFactory;
use Tqdev\PhpCrudApi\ResponseUtils;


$autoload = realpath(__DIR__ . '/../vendor/autoload.php');
if ($autoload) {
    require_once $autoload;
} else {
    http_response_code(500);
    echo "Autoload file not found.";
    exit;
}
// Load environment variables from .env file
function loadEnv($path)
{
    if (!file_exists($path)) {
        return;
    }

    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) {
            continue;
        }

        list($name, $value) = explode('=', $line, 2);
        $name = trim($name);
        $value = trim($value);

        if (!array_key_exists($name, $_ENV)) {
            $_ENV[$name] = $value;
        }
    }
}

// Load .env file
loadEnv(__DIR__ . '/../.env');

// Base configuration
$configArray = [
    // Database Configuration
    'driver' => $_ENV['DB_DRIVER'] ?? 'mysql',
    'address' => $_ENV['DB_ADDRESS'] ?? 'localhost',
    'port' => $_ENV['DB_PORT'] ?? '3306',
    'username' => $_ENV['DB_USERNAME'] ?? '',
    'password' => $_ENV['DB_PASSWORD'] ?? '',
    'database' => $_ENV['DB_DATABASE'] ?? '',
    'command' => $_ENV['DB_COMMAND'] ?? '',
    'debug' => filter_var($_ENV['DB_DEBUG'] ?? 'false', FILTER_VALIDATE_BOOLEAN),
    'mapping' => $_ENV['DB_MAPPING'] ?? '',
    'tables' => getTablesFromJwt() ?? $_ENV['DB_TABLES'] ?? 'all',

    // API Configuration
    'middlewares' => $_ENV['API_MIDDLEWARES'] ?? 'cors',
    'controllers' => $_ENV['API_CONTROLLERS'] ?? 'records,geojson,openapi,status',
    'customControllers' => $_ENV['API_CUSTOM_CONTROLLERS'] ?? '',
    'customOpenApiBuilders' => $_ENV['API_CUSTOM_OPENAPI_BUILDERS'] ?? '',

    // Cache Configuration
    'cacheType' => $_ENV['CACHE_TYPE'] ?? 'TempFile',
    'cachePath' => $_ENV['CACHE_PATH'] ?? '',
    'cacheTime' => (int)($_ENV['CACHE_TIME'] ?? 10),

    // JSON Configuration
    'jsonOptions' => (int)($_ENV['JSON_OPTIONS'] ?? JSON_UNESCAPED_UNICODE),

    // Other Configuration
    'basePath' => $_ENV['BASE_PATH'] ?? '',
    'openApiBase' => $_ENV['OPENAPI_BASE'] ?? '{"info":{"title":"PHP-CRUD-API","version":"1.0.0"}}',
    'geometrySrid' => (int)($_ENV['GEOMETRY_SRID'] ?? 4326),

    //Auth Configuration
];

// Add middleware-specific configurations only if they are enabled
$middlewares = $_ENV['API_MIDDLEWARES'] ?? 'cors';

// Add JWT configuration only if jwtAuth middleware is enabled
if (strpos($middlewares, 'jwtAuth') !== false) {
    $configArray['jwtAuth.secrets'] = $_ENV['JWT_AUTH_SECRET'] ?? '';
    $configArray['jwtAuth.header'] = $_ENV['JWT_AUTH_HEADER'] ?? 'X-Authorization';
    $configArray['jwtAuth.mode'] = $_ENV['JWT_AUTH_MODE'] ?? 'required';
}

// Add API Key configuration only if apiKeyAuth middleware is enabled
if (strpos($middlewares, 'apiKeyAuth') !== false) {
    $configArray['apiKeyAuth.keys'] = $_ENV['PHP_CRUD_API_APIKEYAUTH_KEYS'] ?? '';
    $configArray['apiKeyAuth.header'] = $_ENV['PHP_CRUD_API_APIKEYAUTH_HEADER'] ?? 'X-API-Key';
    $configArray['apiKeyAuth.mode'] = $_ENV['PHP_CRUD_API_APIKEYAUTH_MODE'] ?? 'required';
}

$config = new Config($configArray);

function getTablesFromJwt()
{
    $jwt = null;
    $header = $_ENV['JWT_AUTH_HEADER'] ?? 'X-Authorization';

    // Önce HTTP header'da token var mı kontrol et
    if (isset($_SERVER['HTTP_' . str_replace('-', '_', strtoupper($header))])) {
        $authHeader = $_SERVER['HTTP_' . str_replace('-', '_', strtoupper($header))];
        if (preg_match('/Bearer\s((.*)\.(.*)\.(.*))/', $authHeader, $matches)) {
            $jwt = $matches[1];
        }
    }

    // Eğer HTTP header'da token varsa, onu çöz
    if ($jwt) {
        // Use simple JWT parsing like JwtAuthMiddleware does
        $token = explode('.', $jwt);
        if (count($token) >= 3) {
            try {
                $claims = json_decode(base64_decode(strtr($token[1], '-_', '+/')), true);
                if ($claims && isset($claims['tables'])) {
                    return $claims['tables'];
                }
            } catch (\Exception $e) {
                // Handle malformed JWT tokens silently
                error_log("JWT parsing error: " . $e->getMessage());
            }
        }
    }

    // HTTP header'da token yoksa, session'dan claims'i kontrol et
    if (session_status() == PHP_SESSION_NONE) {
        session_start();
    }

    if (isset($_SESSION['claims']) && !empty($_SESSION['claims'])) {
        $claims = $_SESSION['claims'];
        if (isset($claims['tables'])) {
            return $claims['tables'];
        }
    }

    return null;
}

$request = RequestFactory::fromGlobals();
$api = new Api($config);
$response = $api->handle($request);
ResponseUtils::output($response);

//file_put_contents('request.log',RequestUtils::toString($request)."===\n",FILE_APPEND);
//file_put_contents('request.log',ResponseUtils::toString($response)."===\n",FILE_APPEND);