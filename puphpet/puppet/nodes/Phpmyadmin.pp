if $phpmyadmin_values == undef { $phpmyadmin_values = hiera_hash('phpmyadmin', false) }

if hash_key_equals($phpmyadmin_values, 'install', 1) {
  class { 'phpmyadmin':
    ensure     => present,
    vhost_name => $phpmyadmin_values['settings']['domain'],
    vhost_port => '80',
  }
}
