# Begin PHPMyAdmin.

class druphpet_phpmyadmin($phpmyadmin, $apache, $nginx) {
  if array_true($apache, 'install') {
    $settings = merge({ ensure => present }, $phpmyadmin['settings'])

    create_resources('class', {'phpmyadmin' => $settings})

    file { '/var/www/html/phpmyadmin':
      ensure => link,
      target => '/usr/share/phpMyAdmin/current',
      require => Class['phpmyadmin']
    }
  } else {
    fail('Phpmyadmin requires either Apache to be installed.')
  }
}
