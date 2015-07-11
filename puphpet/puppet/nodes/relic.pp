# Begin New Relic.

class druphpet_relic($relic, $apache, $nginx) {
  newrelic::server {
    'drupal':
      newrelic_license_key => $relic['settings']['license_key'],
  }

  newrelic::php {
    'drupal':
      newrelic_license_key      => $relic['settings']['license_key'],
      newrelic_php_conf_appname => $relic['settings']['application_name']
  }

  if array_true($apache, 'install') {
    exec { 'httpd-restart':
      command => 'service apache2 restart',
      require => [
        Class['apache'],
        Package['newrelic-php5'],
      ]
    }
  }

  if array_true($nginx, 'install') {
    exec { 'nginx-restart':
      command => 'service nginx restart',
    }
  }
}
