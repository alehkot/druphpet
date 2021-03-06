# Begin PHPMyAdmin.

class druphpet_phpmyadmin($phpmyadmin, $apache, $nginx) {
  if array_true($apache, 'install') {
    require apache

    include ::puphpet::apache::params
    include ::apache::params

    $phpmyadmin_obj = {
      'vhost_name' => 'phpmyadmin.local',
      'vhost_port' => 80,
      ensure       => present
    }

    create_resources('class', {'phpmyadmin' => $phpmyadmin_obj})

    file { $phpmyadmin['webroot_location']:
      ensure => link,
      target => '/usr/share/phpMyAdmin/current',
      require => [Class['phpmyadmin'], Package['httpd']]
    }

    $vhost = {
      'port'         => $phpmyadmin['vhost_port'],
      'docroot'      => $phpmyadmin['webroot_location'],
      'servername'   => $phpmyadmin['vhost_name'],
      'directories'  => {
        'webgrind' => {
          'provider'        => 'directory',
          'path'            => $phpmyadmin['webroot_location'],
          'options'         => ['Indexes', 'FollowSymlinks', 'MultiViews'],
          'allow_override'  => ['All'],
          'require'         => ['all granted'],
          'files_match'     => {'php_match' => {
            'provider'        => 'filesmatch',
            'path'            => '\.php$',
            'custom_fragment' => '',
            # @todo Remove hardcode.
            'sethandler'      => 'proxy:fcgi://127.0.0.1:9000',
          }},
          'custom_fragment' => '',
        }
      }
    }

    $apache_version = '2.4'
    $directories_hash   = $vhost['directories']
    $files_match        = template('puphpet/apache/files_match.erb')
    $directories_merged = merge($vhost['directories'], hash_eval($files_match))

    $vhost_name = $phpmyadmin['vhost_name']

    $vhost_merged = merge($vhost, {
     'directories'     => values_no_error($directories_merged),     
     'manage_docroot'  => false
    })

    create_resources(::apache::vhost, { "${vhost_name}" => $vhost_merged })

  }
}
