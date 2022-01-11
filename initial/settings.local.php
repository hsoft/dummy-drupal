<?php
$databases['default']['default'] = [
  'database' => '$DBNAME',
  'username' => '$DBUSER',
  'password' => '$DBPASS',
  'prefix' => '',
  'host' => '$DBHOST',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
];
$settings['hash_salt'] = 'replace if you care about security';
$settings['config_sync_directory'] = 'sites/default/files/$CONFSYNCDIR';
