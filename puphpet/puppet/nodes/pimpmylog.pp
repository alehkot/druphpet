# Begin PimpMyLog

if $pimpmylog_values == undef {
  $pimpmylog_values = hiera('pimpmylog', false)
}

if $apache_values == undef {
  $apache_values = hiera('apache', false)
}

if has_key($pimpmylog_values, 'install') and $pimpmylog_values['install'] == 1 {
  class { 'pimpmylog':
    webroot_location => '/var/www/default'
  }

  if ($apache_values['install'] == 1) {
    file { '/var/log/apache2':
      ensure => directory,
      recurse => true,
      owner => 'www-data',
      group => 'www-data',
      mode => 0750,
      require => Package['httpd']
    }
  }
}
