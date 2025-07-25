<?php

namespace Tqdev\PhpCrudApi;

use Tqdev\PhpCrudApi\Api;
use Tqdev\PhpCrudApi\Config\Config;
use Tqdev\PhpCrudApi\RequestFactory;
use Tqdev\PhpCrudApi\ResponseUtils;

require_once __DIR__ . '/../vendor/autoload.php';
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

$config = new Config([
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
    'tables' => $_ENV['DB_TABLES'] ?? 'all',

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
    #'apiKeyAuth.keys' => $_ENV['PHP_CRUD_API_APIKEYAUTH_KEYS'] ?? '',
    #'apiKeyAuth.header' => $_ENV['PHP_CRUD_API_APIKEYAUTH_HEADER'] ?? 'X-API-Key',
    #'apiKeyAuth.mode' => $_ENV['PHP_CRUD_API_APIKEYAUTH_MODE'] ?? 'required',

    #'jwtAuth.secrets' => $_ENV['JWT_AUTH_SECRET'] ?? '',
    #'jwtAuth.header' => $_ENV['JWT_AUTH_HEADER'] ?? 'X-Authorization',
    #'jwtAuth.mode' => $_ENV['JWT_AUTH_MODE'] ?? 'required',

]);
$request = RequestFactory::fromGlobals();
$api = new Api($config);
$response = $api->handle($request);
ResponseUtils::output($response);

//file_put_contents('request.log',RequestUtils::toString($request)."===\n",FILE_APPEND);
//file_put_contents('request.log',ResponseUtils::toString($response)."===\n",FILE_APPEND);