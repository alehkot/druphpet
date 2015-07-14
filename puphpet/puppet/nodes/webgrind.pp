# Begin Webgrind.

class druphpet_webgrind($webgrind, $apache, $nginx) {
  if array_true($apache, 'install') {
    require apache

    include ::puphpet::apache::params
    include ::apache::params

    create_resources('class', { 'webgrind' => {}})

    file { $webgrind['webroot_location']:
      ensure => link,
      target => '/usr/share/php/webgrind/source',
      require => Class['webgrind']
    }

    $vhost = {
      'port'         => $webgrind['vhost_port'],
      'docroot'      => $webgrind['webroot_location'],
      'servername'   => $webgrind['vhost_name'],
      'directories'  => {
        'webgrind' => {
          'provider'        => 'directory',
          'path'            => $webgrind['webroot_location'],
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

    $vhost_name = $webgrind['vhost_name']

    create_resources(::apache::vhost, { "${vhost_name}" => $vhost_merged })
  }
}
