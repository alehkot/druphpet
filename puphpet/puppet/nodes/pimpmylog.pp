# Begin PimpMyLog.

class druphpet_pimpmylog ($pimpmylog, $apache, $nginx) {
  if array_true($apache, 'install') {
    require apache

    include ::puphpet::apache::params
    include ::apache::params

    create_resources('class', { 'pimpmylog' => {}})

    file { $pimpmylog['webroot_location']:
      ensure => link,
      target => '/usr/share/php/pimpmylog/source',
      require => [Class['pimpmylog'], Package['httpd']]
    }

    file { '/var/log/apache2':
      ensure => directory,
      recurse => true,
      owner => 'www-data',
      group => 'www-data',
      mode => 0750,
      require => Package['httpd']
    }

    file { '/usr/share/php/pimpmylog/source':
      ensure => directory,
      mode => 0777,
      require => File[$pimpmylog['webroot_location']]
    }

    $vhost = {
      'port'         => $pimpmylog['vhost_port'],
      'docroot'      => $pimpmylog['webroot_location'],
      'servername'   => $pimpmylog['vhost_name'],
      'directories'  => {
        'webgrind' => {
          'provider'        => 'directory',
          'path'            => $pimpmylog['webroot_location'],
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

    $vhost_merged = merge($vhost, {
     'directories'     => values_no_error($directories_merged),
     'manage_docroot'  => false
    })

    $vhost_name = $pimpmylog['vhost_name']

    create_resources(::apache::vhost, { "${vhost_name}" => $vhost_merged })

  }
}
