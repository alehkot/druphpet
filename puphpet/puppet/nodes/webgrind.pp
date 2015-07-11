# Begin Webgrind.

class druphpet_webgrind($webgrind, $apache, $nginx) {
  if array_true($apache, 'install') {
    create_resources('class', { 'webgrind' => $webgrind['settings']})

    file { '/var/www/html/webgrind':
      ensure => link,
      target => '/usr/share/php/webgrind/source',
      require => Class['webgrind']
    }
  } else {

  }
}
