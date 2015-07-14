# Begin OPCacheGUI

class druphpet_opcachegui ($opcachegui, $apache, $nginx) {
  if array_true($apache, 'install') {
    require apache

    include ::puphpet::apache::params
    include ::apache::params

    create_resources('class', { 'opcachegui' => {}})

    file { $opcachegui['webroot_location']:
      ensure => link,
      target => '/usr/share/php/opcachegui/source/public',
      require => [Class['opcachegui'], Package['httpd']]
    }

    $vhost = {
      'port'         => $opcachegui['vhost_port'],
      'docroot'      => $opcachegui['webroot_location'],
      'servername'   => $opcachegui['vhost_name'],
      'directories'  => {
        'webgrind' => {
          'provider'        => 'directory',
          'path'            => $opcachegui['webroot_location'],
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

    $vhost_name = $opcachegui['vhost_name']

    create_resources(::apache::vhost, { "${vhost_name}" => $vhost_merged })
  }
}
