# Begin New Relic

if $newrelic_values == undef {
  $newrelic_values = hiera('newrelic', false)
}

if has_key($newrelic_values, 'install') and $newrelic_values['install'] == 1 {

  #class { 'nrsysmond':
   # license_key => $newrelic_values['license_key'],
  #}

  newrelic::server {
    'drupal':
      newrelic_license_key => $newrelic_values['license_key'],
  }

  newrelic::php {
    'drupal':
      newrelic_license_key      => $newrelic_values['license_key'],
      newrelic_php_conf_appname => $newrelic_values['application_name'];
  }

  # Restart Apache
  if is_hash($apache_values) {
    exec { 'httpd-restart':
      command => 'service apache2 restart',
      require => [
        Class['apache'],
        Package['newrelic-php5'],
      ]
    }
  } elsif is_hash($nginx_values) {
    exec { 'nginx-restart':
      command => 'service nginx restart',
    }
  }
  #class { 'newrelic_php':
   # license_key => $newrelic_values['license_key'],
  #}
}
