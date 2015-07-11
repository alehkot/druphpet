# Begin PimpMyLog

class druphpet_pimpmylog ($pimpmylog, $apache) {
  create_resources('class', { 'pimpmylog' => $pimpmylog['settings'] })

  if ($apache['install'] == 1) {
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
