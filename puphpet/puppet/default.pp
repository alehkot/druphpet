## Begin Server manifest

if $server_values == undef {
  $server_values = hiera('server', false)
}

if $vagrant_values == undef {
  $vagrant_values = hiera('vagrantfile-local', false)
}

include 'puphpet'
include 'puphpet::params'

# Ensure the time is accurate, reducing the possibilities of apt repositories
# failing for invalid certificates
class { 'ntp': }

Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }
File { owner => 0, group => 0, mode => 0644 }

group { 'puppet': ensure => present }
group { 'www-data': ensure => present }

user { $::ssh_username:
  shell  => '/bin/bash',
  home   => "/home/${::ssh_username}",
  ensure => present
}

user { ['apache', 'nginx', 'httpd', 'www-data']:
  shell  => '/bin/bash',
  ensure => present,
  groups => 'www-data',
  require => Group['www-data']
}

file { "/home/${::ssh_username}":
  ensure => directory,
  owner  => $::ssh_username,
}

# copy dot files to ssh user's home directory
exec { 'dotfiles':
  cwd     => "/home/${::ssh_username}",
  command => "cp -r /vagrant/puphpet/files/dot/.[a-zA-Z0-9]* /home/${::ssh_username}/ \
              && chown -R ${::ssh_username} /home/${::ssh_username}/.[a-zA-Z0-9]* \
              && cp -r /vagrant/puphpet/files/dot/.[a-zA-Z0-9]* /root/",
  onlyif  => 'test -d /vagrant/puphpet/files/dot',
  returns => [0, 1],
  require => User[$::ssh_username]
}

case $::osfamily {
  # debian, ubuntu
  'debian': {
    class { 'apt': }

    Class['::apt::update'] -> Package <|
        title != 'python-software-properties'
    and title != 'software-properties-common'
    |>

    ensure_packages( ['augeas-tools'] )
  }
  # redhat, centos
  'redhat': {
    class { 'yum': extrarepo => ['epel'] }

    class { 'yum::repo::rpmforge': }
    class { 'yum::repo::repoforgeextras': }

    Class['::yum'] -> Yum::Managed_yumrepo <| |> -> Package <| |>

    if defined(Package['git']) == false {
      package { 'git':
        ensure  => latest,
        require => Class['yum::repo::repoforgeextras']
      }
    }

    exec { 'bash_git':
      cwd     => "/home/${::ssh_username}",
      command => "curl https://raw.github.com/git/git/master/contrib/completion/git-prompt.sh > /home/${::ssh_username}/.bash_git",
      creates => "/home/${::ssh_username}/.bash_git"
    }

    exec { 'bash_git for root':
      cwd     => '/root',
      command => "cp /home/${::ssh_username}/.bash_git /root/.bash_git",
      creates => '/root/.bash_git',
      require => Exec['bash_git']
    }

    file_line { 'link ~/.bash_git':
      ensure  => present,
      line    => 'if [ -f ~/.bash_git ] ; then source ~/.bash_git; fi',
      path    => "/home/${::ssh_username}/.bash_profile",
      require => [
        Exec['dotfiles'],
        Exec['bash_git'],
      ]
    }

    file_line { 'link ~/.bash_git for root':
      ensure  => present,
      line    => 'if [ -f ~/.bash_git ] ; then source ~/.bash_git; fi',
      path    => '/root/.bashrc',
      require => [
        Exec['dotfiles'],
        Exec['bash_git'],
      ]
    }

    file_line { 'link ~/.bash_aliases':
      ensure  => present,
      line    => 'if [ -f ~/.bash_aliases ] ; then source ~/.bash_aliases; fi',
      path    => "/home/${::ssh_username}/.bash_profile",
      require => File_line['link ~/.bash_git']
    }

    file_line { 'link ~/.bash_aliases for root':
      ensure  => present,
      line    => 'if [ -f ~/.bash_aliases ] ; then source ~/.bash_aliases; fi',
      path    => '/root/.bashrc',
      require => File_line['link ~/.bash_git for root']
    }

    ensure_packages( ['augeas'] )
  }
}

if $php_values == undef {
  $php_values = hiera('php', false)
}

case $::operatingsystem {
  'debian': {
    include apt::backports

    add_dotdeb { 'packages.dotdeb.org': release => $lsbdistcodename }

    if is_hash($php_values) {
      # Debian Squeeze 6.0 can do PHP 5.3 (default) and 5.4
      if $lsbdistcodename == 'squeeze' and $php_values['version'] == '54' {
        add_dotdeb { 'packages.dotdeb.org-php54': release => 'squeeze-php54' }
      }
      # Debian Wheezy 7.0 can do PHP 5.4 (default) and 5.5
      elsif $lsbdistcodename == 'wheezy' and $php_values['version'] == '55' {
        add_dotdeb { 'packages.dotdeb.org-php55': release => 'wheezy-php55' }
      }
    }

    $server_lsbdistcodename = downcase($lsbdistcodename)

    apt::force { 'git':
      release => "${server_lsbdistcodename}-backports",
      timeout => 60
    }
  }
  'ubuntu': {
    apt::key { '4F4EA0AAE5267A6C':
      key_server => 'keyserver.ubuntu.com'
    }
    apt::key { '4CBEDD5A':
      key_server => 'keyserver.ubuntu.com'
    }

    apt::ppa { 'ppa:pdoes/ppa': require => Apt::Key['4CBEDD5A'] }

    if is_hash($php_values) {
      # Ubuntu Lucid 10.04, Precise 12.04, Quantal 12.10 and Raring 13.04 can do PHP 5.3 (default <= 12.10) and 5.4 (default <= 13.04)
      if $lsbdistcodename in ['lucid', 'precise', 'quantal', 'raring'] and $php_values['version'] == '54' {
        if $lsbdistcodename == 'lucid' {
          apt::ppa { 'ppa:ondrej/php5-oldstable': require => Apt::Key['4F4EA0AAE5267A6C'], options => '' }
        } else {
          apt::ppa { 'ppa:ondrej/php5-oldstable': require => Apt::Key['4F4EA0AAE5267A6C'] }
        }
      }
      # Ubuntu Precise 12.04, Quantal 12.10 and Raring 13.04 can do PHP 5.5
      elsif $lsbdistcodename in ['precise', 'quantal', 'raring'] and $php_values['version'] == '55' {
        apt::ppa { 'ppa:ondrej/php5': require => Apt::Key['4F4EA0AAE5267A6C'] }
      }
      elsif $lsbdistcodename in ['lucid'] and $php_values['version'] == '55' {
        err('You have chosen to install PHP 5.5 on Ubuntu 10.04 Lucid. This will probably not work!')
      }
    }
  }
  'redhat', 'centos': {
    if is_hash($php_values) {
      if $php_values['version'] == '54' {
        class { 'yum::repo::remi': }
      }
      # remi_php55 requires the remi repo as well
      elsif $php_values['version'] == '55' {
        class { 'yum::repo::remi': }
        class { 'yum::repo::remi_php55': }
      }
    }
  }
}

if !empty($server_values['packages']) {
  ensure_packages( $server_values['packages'] )
}

define add_dotdeb ($release){
   apt::source { $name:
    location          => 'http://packages.dotdeb.org',
    release           => $release,
    repos             => 'all',
    required_packages => 'debian-keyring debian-archive-keyring',
    key               => '89DF5277',
    key_server        => 'keys.gnupg.net',
    include_src       => true
  }
}

# Begin Apache manifest

if $yaml_values == undef {
  $yaml_values = loadyaml('/vagrant/puphpet/config.yaml')
} if $apache_values == undef {
  $apache_values = $yaml_values['apache']
} if $php_values == undef {
  $php_values = hiera('php', false)
} if $hhvm_values == undef {
  $hhvm_values = hiera('hhvm', false)
}

if hash_key_equals($apache_values, 'install', 1) {
  include puphpet::params
  include apache::params

  $webroot_location = $puphpet::params::apache_webroot_location

  exec { "exec mkdir -p ${webroot_location}":
    command => "mkdir -p ${webroot_location}",
    creates => $webroot_location,
  }

  if (downcase($::provisioner_type) in ['virtualbox', 'vmware_fusion'])
    and ! defined(File[$webroot_location])
  {
    file { $webroot_location:
      ensure  => directory,
      mode    => 0775,
      require => [
        Exec["exec mkdir -p ${webroot_location}"],
        Group['www-data']
      ]
    }
  }

  if !(downcase($::provisioner_type) in ['virtualbox', 'vmware_fusion'])
    and ! defined(File[$webroot_location])
  {
    file { $webroot_location:
      ensure  => directory,
      group   => 'www-data',
      mode    => 0775,
      require => [
        Exec["exec mkdir -p ${webroot_location}"],
        Group['www-data']
      ]
    }
  }

  if hash_key_equals($hhvm_values, 'install', 1) {
    $mpm_module           = 'worker'
    $disallowed_modules   = ['php']
    $apache_conf_template = 'puphpet/apache/hhvm-httpd.conf.erb'
    $apache_php_package   = 'hhvm'
  } elsif hash_key_equals($php_values, 'install', 1) {
    $mpm_module           = 'prefork'
    $disallowed_modules   = []
    $apache_conf_template = $apache::params::conf_template
    $apache_php_package   = 'php'
  } else {
    $mpm_module           = 'prefork'
    $disallowed_modules   = []
    $apache_conf_template = $apache::params::conf_template
    $apache_php_package   = ''
  }

  if $::operatingsystem == 'ubuntu'
  and hash_key_equals($php_values, 'install', 1)
  and hash_key_equals($php_values, 'version', 55)
  {
    $apache_version = '2.4'
  } else {
    $apache_version = $apache::version::default
  }


  $apache_settings = merge($apache_values['settings'], {
    'mpm_module'     => $mpm_module,
    'conf_template'  => $apache_conf_template,
    'sendfile'       => $apache_values['settings']['sendfile'] ? { 1 => 'On', default => 'Off' },
    'apache_version' => $apache_version
  })

  create_resources('class', { 'apache' => $apache_settings })

  if $::osfamily == 'debian' {
    case $mpm_module {
      'prefork': { ensure_packages( ['apache2-mpm-prefork'] ) }
      'worker':  { ensure_packages( ['apache2-mpm-worker'] ) }
      'event':   { ensure_packages( ['apache2-mpm-event'] ) }
    }
  } elsif $::osfamily == 'redhat' and ! defined(Iptables::Allow['tcp/80']) {
    iptables::allow { 'tcp/80':
      port     => '80',
      protocol => 'tcp'
    }
  }

  if hash_key_equals($apache_values, 'mod_pagespeed', 1) {
    class { 'puphpet::apache::modpagespeed': }
  }

  if hash_key_equals($apache_values, 'mod_spdy', 1) {
    class { 'puphpet::apache::modspdy':
      php_package => $apache_php_package
    }
  }

  if count($apache_values['vhosts']) > 0 {
    each( $apache_values['vhosts'] ) |$key, $vhost| {
      exec { "exec mkdir -p ${vhost['docroot']} @ key ${key}":
        command => "mkdir -p ${vhost['docroot']}",
        creates => $vhost['docroot'],
      }

      if (downcase($::provisioner_type) in ['virtualbox', 'vmware_fusion'])
        and ! defined(File[$vhost['docroot']])
      {
        file { $vhost['docroot']:
          ensure  => directory,
          mode    => 0765,
          require => Exec["exec mkdir -p ${vhost['docroot']} @ key ${key}"]
        }
      }

      if !(downcase($::provisioner_type) in ['virtualbox', 'vmware_fusion'])
        and ! defined(File[$vhost['docroot']])
      {
        file { $vhost['docroot']:
          ensure  => directory,
          group   => 'www-user',
          mode    => 0765,
          require => [
            Exec["exec mkdir -p ${vhost['docroot']} @ key ${key}"],
            Group['www-user']
          ]
        }
      }

      create_resources(apache::vhost, { "${key}" => merge($vhost, {
          'custom_fragment' => template('puphpet/apache/custom_fragment.erb'),
          'ssl'             => 'ssl' in $vhost and str2bool($vhost['ssl']) ? { true => true, default => false },
          'ssl_cert'        => $vhost['ssl_cert'] ? { undef => undef, '' => undef, default => $vhost['ssl_cert'] },
          'ssl_key'         => $vhost['ssl_key'] ? { undef => undef, '' => undef, default => $vhost['ssl_key'] },
          'ssl_chain'       => $vhost['ssl_chain'] ? { undef => undef, '' => undef, default => $vhost['ssl_chain'] },
          'ssl_certs_dir'   => $vhost['ssl_certs_dir'] ? { undef => undef, '' => undef, default => $vhost['ssl_certs_dir'] }
        })
      })
    }
  }

  if count($apache_values['modules']) > 0 {
    apache_mod { $apache_values['modules']: }
  }
}

define apache_mod {
  if ! defined(Class["apache::mod::${name}"]) and !($name in $disallowed_modules) {
    class { "apache::mod::${name}": }
  }
}

## Begin Nginx manifest

if $nginx_values == undef {
   $nginx_values = hiera('nginx', false)
} if $php_values == undef {
   $php_values = hiera('php', false)
} if $hhvm_values == undef {
  $hhvm_values = hiera('hhvm', false)
}

if hash_key_equals($nginx_values, 'install', 1) {
  include nginx::params
  include puphpet::params

  Class['puphpet::ssl_cert'] -> Nginx::Resource::Vhost <| |>

  class { 'puphpet::ssl_cert': }

  if $lsbdistcodename == 'lucid' and hash_key_equals($php_values, 'version', '53') {
    apt::key { '67E15F46': key_server => 'hkp://keyserver.ubuntu.com:80' }
    apt::ppa { 'ppa:l-mierzwa/lucid-php5':
      options => '',
      require => Apt::Key['67E15F46']
    }
  }

  $webroot_location = $puphpet::params::nginx_webroot_location

  exec { "exec mkdir -p ${webroot_location}":
    command => "mkdir -p ${webroot_location}",
    onlyif  => "test -d ${webroot_location}",
  }

  if (downcase($::provisioner_type) in ['virtualbox', 'vmware_fusion'])
    and ! defined(File[$webroot_location])
  {
    file { $webroot_location:
      ensure  => directory,
      mode    => 0775,
      require => [
        Exec["exec mkdir -p ${webroot_location}"],
        Group['www-data']
      ]
    }
  }

  if !(downcase($::provisioner_type) in ['virtualbox', 'vmware_fusion'])
    and ! defined(File[$webroot_location])
  {
    file { $webroot_location:
      ensure  => directory,
      group   => 'www-data',
      mode    => 0775,
      require => [
        Exec["exec mkdir -p ${webroot_location}"],
        Group['www-data']
      ]
    }
  }

  if $::osfamily == 'redhat' {
      file { '/usr/share/nginx':
        ensure  => directory,
        mode    => 0775,
        owner   => 'www-data',
        group   => 'www-data',
        require => Group['www-data'],
        before  => Package['nginx']
      }
  }

  if hash_key_equals($php_values, 'install', 1) {
    $php5_fpm_sock = '/var/run/php5-fpm.sock'

    if $php_values['version'] == undef {
      $fastcgi_pass = null
    } elsif $php_values['version'] == '53' {
      $fastcgi_pass = '127.0.0.1:9000'
    } else {
      $fastcgi_pass = "unix:${php5_fpm_sock}"
    }

    if $::osfamily == 'redhat' and $fastcgi_pass == "unix:${php5_fpm_sock}" {
      exec { "create ${php5_fpm_sock} file":
        command => "touch ${php5_fpm_sock}",
        onlyif  => ["test ! -f ${php5_fpm_sock}", "test ! -f ${php5_fpm_sock}="],
        require => Package['nginx'],
      }

      exec { "listen = 127.0.0.1:9000 => listen = ${php5_fpm_sock}":
        command => "perl -p -i -e 's#listen = 127.0.0.1:9000#listen = ${php5_fpm_sock}#gi' /etc/php-fpm.d/www.conf",
        unless  => "grep -c 'listen = 127.0.0.1:9000' '${php5_fpm_sock}'",
        notify  => [
          Class['nginx::service'],
          Service['php-fpm']
        ],
        require => Exec["create ${php5_fpm_sock} file"]
      }

      set_php5_fpm_sock_group_and_user { 'php_rhel':
        require => Exec["create ${php5_fpm_sock} file"],
      }
    } else {
      set_php5_fpm_sock_group_and_user { 'php':
        require   => Package['nginx'],
        subscribe => Service['php5-fpm'],
      }
    }
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $fastcgi_pass        = '127.0.0.1:9000'

    set_php5_fpm_sock_group_and_user { 'hhvm':
      require => Package['nginx'],
    }
  } else {
    $fastcgi_pass        = ''
  }

  class { 'nginx': }

  if count($nginx_values['vhosts']) > 0 {
    each( $nginx_values['vhosts'] ) |$key, $vhost| {
      exec { "exec mkdir -p ${vhost['www_root']} @ key ${key}":
        command => "mkdir -p ${vhost['www_root']}",
        creates => $vhost['www_root'],
      }

      if ! defined(File[$vhost['www_root']]) {
        file { $vhost['www_root']:
          ensure  => directory,
          require => Exec["exec mkdir -p ${vhost['www_root']} @ key ${key}"]
        }
      }
    }

    create_resources(nginx_vhost, $nginx_values['vhosts'])
  }
}

define nginx_vhost (
  $server_name,
  $server_aliases = [],
  $www_root,
  $listen_port,
  $index_files,
  $envvars = [],
  $ssl = false,
  $ssl_cert = $puphpet::params::ssl_cert_location,
  $ssl_key = $puphpet::params::ssl_key_location,
  $ssl_port = '443',
  $rewrite_to_https = false,
  $spdy = $nginx::params::nx_spdy,
){
  $merged_server_name = concat([$server_name], $server_aliases)

  if is_array($index_files) and count($index_files) > 0 {
    $try_files = $index_files[count($index_files) - 1]
  } else {
    $try_files = 'index.php'
  }

  if hash_key_equals($php_values, 'install', 1) {
    $fastcgi_param_parts = [
      'PATH_INFO $fastcgi_path_info',
      'PATH_TRANSLATED $document_root$fastcgi_path_info',
      'SCRIPT_FILENAME $document_root$fastcgi_script_name'
    ]
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $fastcgi_param_parts = [
      'SCRIPT_FILENAME $document_root$fastcgi_script_name'
    ]
  } else {
    $fastcgi_param_parts = []
  }

  if $ssl == 0 or $ssl == false or $ssl == '' {
    $ssl_set = false
  } else {
    $ssl_set = true
  }

  if $ssl_cert == 0 or $ssl_cert == false or $ssl_cert == '' {
    $ssl_cert_set = $puphpet::params::ssl_cert_location
  } else {
    $ssl_cert_set = $ssl_cert
  }

  if $ssl_key == 0 or $ssl_key == false or $ssl_key == '' {
    $ssl_key_set = $puphpet::params::ssl_key_location
  } else {
    $ssl_key_set = $ssl_key
  }

  if $ssl_port == 0 or $ssl_port == false or $ssl_port == '' {
    $ssl_port_set = '443'
  } else {
    $ssl_port_set = $ssl_port
  }

  if $rewrite_to_https == 0 or $rewrite_to_https == false or $rewrite_to_https == '' {
    $rewrite_to_https_set = false
  } else {
    $rewrite_to_https_set = true
  }

  if $spdy == off or $spdy == 0 or $spdy == false or $spdy == '' {
    $spdy_set = off
  } else {
    $spdy_set = on
  }

  nginx::resource::vhost { $server_name:
    server_name      => $merged_server_name,
    www_root         => $www_root,
    listen_port      => $listen_port,
    index_files      => $index_files,
    try_files        => ['$uri', '$uri/', "/${try_files}?\$args"],
    ssl              => $ssl_set,
    ssl_cert         => $ssl_cert_set,
    ssl_key          => $ssl_key_set,
    ssl_port         => $ssl_port_set,
    rewrite_to_https => $rewrite_to_https_set,
    spdy             => $spdy_set,
    vhost_cfg_append => {
       sendfile => 'off'
    }
  }

  $fastcgi_param = concat($fastcgi_param_parts, $envvars)

  nginx::resource::location { "${server_name}-php":
    ensure              => present,
    vhost               => $server_name,
    location            => '~ \.php$',
    proxy               => undef,
    try_files           => ['$uri', '$uri/', "/${try_files}?\$args"],
    ssl                 => $ssl_set,
    www_root            => $www_root,
    location_cfg_append => {
      'fastcgi_split_path_info' => '^(.+\.php)(/.+)$',
      'fastcgi_param'           => $fastcgi_param,
      'fastcgi_pass'            => $fastcgi_pass,
      'fastcgi_index'           => 'index.php',
      'include'                 => 'fastcgi_params'
    },
    notify              => Class['nginx::service'],
  }
}

define set_php5_fpm_sock_group_and_user (){
  exec { 'set php5_fpm_sock group and user':
    command => "chmod 660 ${php5_fpm_sock} && chown www-data ${php5_fpm_sock} && chgrp www-data ${php5_fpm_sock} && touch /.puphpet-stuff/php5_fpm_sock",
    creates => '/.puphpet-stuff/php5_fpm_sock',
  }
}

## Begin PHP manifest
if $php_values == undef {
  $php_values = hiera('php', false)
} if $apache_values == undef {
  $apache_values = hiera('apache', false)
} if $nginx_values == undef {
  $nginx_values = hiera('nginx', false)
} if $mailcatcher_values == undef {
  $mailcatcher_values = hiera('mailcatcher', false)
}

if hash_key_equals($php_values, 'install', 1) {
  Class['Php'] -> Class['Php::Devel'] -> Php::Module <| |> -> Php::Pear::Module <| |> -> Php::Pecl::Module <| |>

  if $php_prefix == undef {
    $php_prefix = $::operatingsystem ? {
      /(?i:Ubuntu|Debian|Mint|SLES|OpenSuSE)/ => 'php5-',
      default                                 => 'php-',
    }
  }

  if $php_fpm_ini == undef {
    $php_fpm_ini = $::operatingsystem ? {
      /(?i:Ubuntu|Debian|Mint|SLES|OpenSuSE)/ => '/etc/php5/fpm/php.ini',
      default                                 => '/etc/php.ini',
    }
  }

  if hash_key_equals($apache_values, 'install', 1) {
    include apache::params

    if has_key($apache_values, 'mod_spdy') and $apache_values['mod_spdy'] == 1 {
      $php_webserver_service_ini = 'cgi'
    } else {
      $php_webserver_service_ini = 'httpd'
    }

    $php_webserver_service = 'httpd'
    $php_webserver_user    = $apache::params::user
    $php_webserver_restart = true

    class { 'php':
      service => $php_webserver_service
    }
  } elsif hash_key_equals($nginx_values, 'install', 1) {
    include nginx::params

    $php_webserver_service     = "${php_prefix}fpm"
    $php_webserver_service_ini = $php_webserver_service
    $php_webserver_user        = $nginx::params::nx_daemon_user
    $php_webserver_restart     = true

    class { 'php':
      package             => $php_webserver_service,
      service             => $php_webserver_service,
      service_autorestart => false,
      config_file         => $php_fpm_ini,
    }

    service { $php_webserver_service:
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
      require    => Package[$php_webserver_service]
    }
  } else {
    $php_webserver_service     = undef
    $php_webserver_service_ini = undef
    $php_webserver_restart     = false

    class { 'php':
      package             => "${php_prefix}cli",
      service             => $php_webserver_service,
      service_autorestart => false,
    }
  }

  class { 'php::devel': }

  if count($php_values['modules']['php']) > 0 {
    php_mod { $php_values['modules']['php']:; }
  }
  if count($php_values['modules']['pear']) > 0 {
    php_pear_mod { $php_values['modules']['pear']:; }
  }
  if count($php_values['modules']['pecl']) > 0 {
    php_pecl_mod { $php_values['modules']['pecl']:; }
  }
  if count($php_values['ini']) > 0 {
    each( $php_values['ini'] ) |$key, $value| {
      if is_array($value) {
        each( $php_values['ini'][$key] ) |$innerkey, $innervalue| {
          puphpet::ini { "${key}_${innerkey}":
            entry       => "CUSTOM_${innerkey}/${key}",
            value       => $innervalue,
            php_version => $php_values['version'],
            webserver   => $php_webserver_service_ini
          }
        }
      } else {
        puphpet::ini { $key:
          entry       => "CUSTOM/${key}",
          value       => $value,
          php_version => $php_values['version'],
          webserver   => $php_webserver_service_ini
        }
      }
    }

    if $php_values['ini']['session.save_path'] != undef {
      $php_sess_save_path = $php_values['ini']['session.save_path']

      exec {"mkdir -p ${php_sess_save_path}":
        onlyif => "test ! -d ${php_sess_save_path}",
        before => Class['php']
      }
      exec {"chmod 775 ${php_sess_save_path} && chown www-data ${php_sess_save_path} && chgrp www-data ${php_sess_save_path}":
        require => Class['php']
      }
    }
  }

  puphpet::ini { $key:
    entry       => 'CUSTOM/date.timezone',
    value       => $php_values['timezone'],
    php_version => $php_values['version'],
    webserver   => $php_webserver_service_ini
  }

  if hash_key_equals($php_values, 'composer', 1) {
    $php_composer_home = $php_values['composer_home'] ? {
      false   => false,
      undef   => false,
      ''      => false,
      default => $php_values['composer_home'],
    }

    if $php_composer_home {
      file { $php_composer_home:
        ensure  => directory,
        owner   => 'www-data',
        group   => 'www-data',
        mode    => 0775,
        require => [Group['www-data'], Group['www-user']]
      }

      file_line { "COMPOSER_HOME=${php_composer_home}":
        path => '/etc/environment',
        line => "COMPOSER_HOME=${php_composer_home}",
      }
    }

    class { 'composer':
      target_dir      => '/usr/local/bin',
      composer_file   => 'composer',
      download_method => 'curl',
      logoutput       => false,
      tmp_path        => '/tmp',
      php_package     => "${php::params::module_prefix}cli",
      curl_package    => 'curl',
      suhosin_enabled => false,
    }
  }

  # Usually this would go within the library that needs in (Mailcatcher)
  # but the values required are sufficiently complex that it's easier to
  # add here
  if hash_key_equals($mailcatcher_values, 'install', 1)
    and ! defined(Puphpet::Ini['sendmail_path'])
  {
    puphpet::ini { 'sendmail_path':
      entry       => 'CUSTOM/sendmail_path',
      value       => '/usr/bin/env catchmail',
      php_version => $php_values['version'],
      webserver   => $php_webserver_service_ini
    }
  }
}

define php_mod {
  if ! defined(Puphpet::Php::Module[$name]) {
    puphpet::php::module { $name:
      service_autorestart => $php_webserver_restart,
    }
  }
}
define php_pear_mod {
  if ! defined(Puphpet::Php::Pear[$name]) {
    puphpet::php::pear { $name:
      service_autorestart => $php_webserver_restart,
    }
  }
}
define php_pecl_mod {
  if ! defined(Puphpet::Php::Extra_repos[$name]) {
    puphpet::php::extra_repos { $name:
      before => Puphpet::Php::Pecl[$name],
    }
  }

  if ! defined(Puphpet::Php::Pecl[$name]) {
    puphpet::php::pecl { $name:
      service_autorestart => $php_webserver_restart,
    }
  }
}

## Begin Xdebug manifest

if $xdebug_values == undef {
  $xdebug_values = hiera('xdebug', false)
}

if is_hash($apache_values) {
  $xdebug_webserver_service = 'httpd'
} elsif is_hash($nginx_values) {
  $xdebug_webserver_service = 'nginx'
} else {
  $xdebug_webserver_service = undef
}

if $xdebug_values['install'] != undef and $xdebug_values['install'] == 1 {
  class { 'puphpet::xdebug':
    webserver => $xdebug_webserver_service
  }

  if is_hash($xdebug_values['settings']) and count($xdebug_values['settings']) > 0 {
    each( $xdebug_values['settings'] ) |$key, $value| {
      puphpet::ini { $key:
        entry       => "XDEBUG/${key}",
        value       => $value,
        php_version => $php_values['version'],
        webserver   => $xdebug_webserver_service
      }
    }
  }
}

# Begin Drush manifest

if $drush_values == undef {
  $drush_values = hiera('drush', false)
}

if $drush_values['install'] != undef and $drush_values['install'] == 1 {
  if ($drush_values['settings']['drush.tag_branch'] != undef) {
    $drush_tag_branch = $drush_values['settings']['drush.tag_branch']
  } else {
    $drush_tag_branch = ''
  }

  ## @see https://drupal.org/node/2165015
  include drush::git::drush

  ## class { 'drush::git::drush':
  ##   git_branch => $drush_tag_branch,
  ##   update     => true,
  ## }
}

## End Drush manifest

## Begin MySQL manifest

if $mysql_values == undef {
  $mysql_values = hiera('mysql', false)
}

if $php_values == undef {
  $php_values = hiera('php', false)
}

if $apache_values == undef {
  $apache_values = hiera('apache', false)
}

if $nginx_values == undef {
  $nginx_values = hiera('nginx', false)
}

if is_hash($apache_values) or is_hash($nginx_values) {
  $mysql_webserver_restart = true
} else {
  $mysql_webserver_restart = false
}

if $mysql_values['root_password'] {
  class { 'mysql::server':
    root_password => $mysql_values['root_password'],
    override_options => {
      'mysqld' => {
        'bind-address' => '0.0.0.0',
      }
    }
  }

  if is_hash($mysql_values['databases']) and count($mysql_values['databases']) > 0 {
    create_resources(mysql_db, $mysql_values['databases'])
  }

  if is_hash($php_values) {
    if $::osfamily == 'redhat' and $php_values['version'] == '53' and ! defined(Php::Module['mysql']) {
      php::module { 'mysql':
        service_autorestart => $mysql_webserver_restart,
      }
    } elsif ! defined(Php::Module['mysqlnd']) {
      php::module { 'mysqlnd':
        service_autorestart => $mysql_webserver_restart,
      }
    }
  }
}

define mysql_db (
  $user,
  $password,
  $host,
  $grant    = [],
  $sql_file = false
) {
  if $name == '' or $password == '' or $host == '' {
    fail( 'MySQL DB requires that name, password and host be set. Please check your settings!' )
  }

  mysql::db { $name:
    user     => $user,
    password => $password,
    host     => $host,
    grant    => $grant,
    sql      => $sql_file,
  }
}

if hash_key_equals($mysql_values, 'phpmyadmin', 1) {
  if hash_key_equals($apache_values, 'install', 1) {
    $mysql_pma_webroot_location = $puphpet::params::apache_webroot_location
  } elsif hash_key_equals($nginx_values, 'install', 1) {
    $mysql_pma_webroot_location = $puphpet::params::nginx_webroot_location

    mysql_nginx_default_conf { 'override_default_conf':
      webroot => $mysql_pma_webroot_location
    }
  } else {
    $mysql_pma_webroot_location = '/var/www'
  }

  class { 'puphpet::phpmyadmin':
    dbms             => 'mysql::server',
    webroot_location => $mysql_pma_webroot_location,
  }
}

if hash_key_equals($mysql_values, 'adminer', 1) {
  if hash_key_equals($apache_values, 'install', 1) {
    $mysql_adminer_webroot_location = $puphpet::params::apache_webroot_location
  } elsif hash_key_equals($nginx_values, 'install', 1) {
    $mysql_adminer_webroot_location = $puphpet::params::nginx_webroot_location
  } else {
    $mysql_adminer_webroot_location = $puphpet::params::apache_webroot_location
  }

  class { 'puphpet::adminer':
    location    => "${mysql_adminer_webroot_location}/adminer",
    owner       => 'www-data',
    php_package => $mysql_php_package
  }
}

define mysql_nginx_default_conf (
  $webroot
) {
  if $php5_fpm_sock == undef {
    $php5_fpm_sock = '/var/run/php5-fpm.sock'
  }

  if $fastcgi_pass == undef {
    $fastcgi_pass = $php_values['version'] ? {
      undef   => null,
      '53'    => '127.0.0.1:9000',
      default => "unix:${php5_fpm_sock}"
    }
  }

  class { 'puphpet::nginx':
    fastcgi_pass => $fastcgi_pass,
    notify       => Class['nginx::service'],
  }
}

# Begin beanstalkd

if $beanstalkd_values == undef {
  $beanstalkd_values = hiera('beanstalkd', false)
}

if has_key($beanstalkd_values, 'install') and $beanstalkd_values['install'] == 1 {
  beanstalkd::config { $beanstalkd_values: }
}

exec { 'public_html':
  path    => '/bin',
  command => 'ln -s /var/www/ /home/vagrant/public_html',
  creates => '/home/vagrant/public_html'
}

composer::exec { 'composer-install-drush':
  cmd  => 'install',
  cwd  => '/usr/share/drush',
  user => 'root'
}


# Begin Apache Solr

if $solr_values == undef {
  $solr_values = hiera('solr', false)
}

if has_key($solr_values, 'install') and $solr_values['install'] == 1 {
  class { 'solr':

  }
}


# Begin XHProf

if $php_xhprof_values == undef {
  $php_xhprof_values = hiera('php_xhprof', false)
}

if has_key($php_xhprof_values, 'install') and $php_xhprof_values['install'] == 1 {
  class { 'xhprof':
    version => '0.9.4'
  }
}

# Begin PimpMyLog

if $pimpmylog_values == undef {
  $pimpmylog_values = hiera('pimpmylog', false)
}

if has_key($pimpmylog_values, 'install') and $pimpmylog_values['install'] == 1 {
  class { 'pimpmylog':

  }
}

# Begin RabbitMQ

if $rabbitmq_values == undef {
  $rabbitmq_values = hiera('rabbitmq', false)
} if $php_values == undef {
  $php_values = hiera('php', false)
} if $apache_values == undef {
  $apache_values = hiera('apache', false)
} if $nginx_values == undef {
  $nginx_values = hiera('nginx', false)
}

if hash_key_equals($apache_values, 'install', 1)
  or hash_key_equals($nginx_values, 'install', 1)
{
  $rabbitmq_webserver_restart = true
} else {
  $rabbitmq_webserver_restart = false
}

if hash_key_equals($rabbitmq_values, 'install', 1) {
  create_resources('class', { 'rabbitmq' => $rabbitmq_values['settings'] })

  if hash_key_equals($php_values, 'install', 1) and ! defined(Php::Pecl::Module['amqp']) {
    php::pecl::module { 'amqp':
      use_package         => false,
      service_autorestart => $rabbitmq_webserver_restart,
      require             => Class['rabbitmq']
    }
  }
}

# Begin Samba

if $samba_server_values == undef {
  $samba_server_values = hiera('samba_server', false)
}

if hash_key_equals($samba_server_values, 'install', 1) {
  class {'samba::server':
    workgroup => 'Drupal',
    server_string => 'Drupal VM server',
    interfaces => 'eth1 lo',
    security => 'share',
  }

  samba::server::share { 'data':
    comment => 'data storage',
    path  => "/var/www",
    guest_only => true,
    guest_ok => true,
    guest_account => 'guest',
    browsable => true,
    create_mask => 0777,
    force_create_mask => 0777,
    directory_mask => 0777,
    force_directory_mask => 0777,
    force_group => 'root',
    force_user => 'root',
    writable => true,
  }
}

# Begin APCu

if $apcu_values == undef {
  $apcu_values = hiera('apcu', false)
}

if hash_key_equals($apcu_values, 'install', 1) {
  class {'apcu':

  }
}

# Begin PHP Memcached

if $php_memcached_values == undef {
  $php_memcached_values = hiera('php_memcached', false)
}

if hash_key_equals($php_memcached_values, 'install', 1) {
  ensure_packages(['php5-memcached'])
}

## Begin MariaDb manifest

if $mariadb_values == undef {
  $mariadb_values = hiera('mariadb', false)
} if $php_values == undef {
  $php_values = hiera('php', false)
} if $hhvm_values == undef {
  $hhvm_values = hiera('hhvm', false)
} if $apache_values == undef {
  $apache_values = hiera('apache', false)
} if $nginx_values == undef {
  $nginx_values = hiera('nginx', false)
}

if hash_key_equals($mariadb_values, 'install', 1) {
  if hash_key_equals($apache_values, 'install', 1) or hash_key_equals($nginx_values, 'install', 1) {
    $mariadb_webserver_restart = true
  } else {
    $mariadb_webserver_restart = false
  }

  if hash_key_equals($php_values, 'install', 1) {
    $mariadb_php_installed = true
    $mariadb_php_package   = 'php'
  } elsif hash_key_equals($hhvm_values, 'install', 1) {
    $mariadb_php_installed = true
    $mariadb_php_package   = 'hhvm'
  } else {
    $mariadb_php_installed = false
  }

  if has_key($mariadb_values, 'root_password') and $mariadb_values['root_password'] {
    include 'mysql::params'

    if (! defined(File[$mysql::params::datadir])) {
      file { $mysql::params::datadir :
        ensure => directory,
        group  => $mysql::params::root_group,
        before => Class['mysql::server']
      }
    }

    if ! defined(Group['mysql']) {
      group { 'mysql':
        ensure => present
      }
    }

    if ! defined(User['mysql']) {
      user { 'mysql':
        ensure => present,
      }
    }

    if (! defined(File['/var/run/mysqld'])) {
      file { '/var/run/mysqld' :
        ensure  => directory,
        group   => 'mysql',
        owner   => 'mysql',
        before  => Class['mysql::server'],
        require => [User['mysql'], Group['mysql']],
        notify  => Service['mysql'],
      }
    }

    if ! defined(File[$mysql::params::socket]) {
      file { $mysql::params::socket :
        ensure  => file,
        group   => $mysql::params::root_group,
        before  => Class['mysql::server'],
        require => File[$mysql::params::datadir]
      }
    }

    if ! defined(Package['mysql-libs']) {
      package { 'mysql-libs':
        ensure => purged,
        before => Class['mysql::server'],
      }
    }

    class { 'puphpet::mariadb':
      version => $mariadb_values['version']
    }

    class { 'mysql::server':
      package_name  => $puphpet::params::mariadb_package_server_name,
      root_password => $mariadb_values['root_password'],
      service_name  => 'mysql',
    }

    class { 'mysql::client':
      package_name => $puphpet::params::mariadb_package_client_name
    }

    if is_hash($mariadb_values['databases']) and count($mariadb_values['databases']) > 0 {
      create_resources(mariadb_db, $mariadb_values['databases'])
    }

    if $mariadb_php_installed and $mariadb_php_package == 'php' {
      if $::osfamily == 'redhat' and $php_values['version'] == '53' {
        $mariadb_php_module = 'mysql'
      } elsif $lsbdistcodename == 'lucid' or $lsbdistcodename == 'squeeze' {
        $mariadb_php_module = 'mysql'
      } else {
        $mariadb_php_module = 'mysqlnd'
      }

      if ! defined(Php::Module[$mariadb_php_module]) {
        php::module { $mariadb_php_module:
          service_autorestart => $mariadb_webserver_restart,
        }
      }
    }
  }

  if hash_key_equals($mariadb_values, 'adminer', 1) and $mariadb_php_installed {
    if hash_key_equals($apache_values, 'install', 1) {
      $mariadb_adminer_webroot_location = $puphpet::params::apache_webroot_location
    } elsif hash_key_equals($nginx_values, 'install', 1) {
      $mariadb_adminer_webroot_location = $puphpet::params::nginx_webroot_location
    } else {
      $mariadb_adminer_webroot_location = $puphpet::params::apache_webroot_location
    }

    class { 'puphpet::adminer':
      location    => "${mariadb_adminer_webroot_location}/adminer",
      owner       => 'www-data',
      php_package => $mariadb_php_package
    }
  }
}

define mariadb_db (
  $user,
  $password,
  $host,
  $grant    = [],
  $sql_file = false
) {
  if $name == '' or $password == '' or $host == '' {
    fail( 'MariaDB requires that name, password and host be set. Please check your settings!' )
  }

  mysql::db { $name:
    user     => $user,
    password => $password,
    host     => $host,
    grant    => $grant,
    sql      => $sql_file,
  }
}

# @todo update this!
define mariadb_nginx_default_conf (
  $webroot
) {
  if $php5_fpm_sock == undef {
    $php5_fpm_sock = '/var/run/php5-fpm.sock'
  }

  if $fastcgi_pass == undef {
    $fastcgi_pass = $php_values['version'] ? {
      undef   => null,
      '53'    => '127.0.0.1:9000',
      default => "unix:${php5_fpm_sock}"
    }
  }

  class { 'puphpet::nginx':
    fastcgi_pass => $fastcgi_pass,
    notify       => Class['nginx::service'],
  }
}

# Begin RVM

class { 'rvm':
  version => '1.20.12',
  install_dependencies => false,
}


rvm::system_user { vagrant: ; }

rvm_system_ruby {
  'ruby-1.9.3-p429':
    ensure => 'present',
    default_use => false;
}

rvm_gemset {
  'ruby-1.9.3-p429@vagrant':
    ensure => present,
    require => Rvm_system_ruby['ruby-1.9.3-p429'];
}

# Begin MailCatcher

if $mailcatcher_values == undef {
  $mailcatcher_values = hiera('mailcatcher', false)
}

if has_key($mailcatcher_values, 'install') and $mailcatcher_values['install'] == 1 {

  if ! defined(Class['supervisord']) {
    class { 'supervisord':
      install_pip => true,
    }
  }

  user { 'mailcatcher':
    ensure  => present,
    comment => 'Mailcatcher Mock Smtp Service User',
    home    => '/var/spool/mailcatcher',
    shell   => '/bin/true',
  }

  $log_path = '/var/log/mailcatcher/mailcatcher.log'

  file { '/var/log/mailcatcher':
    ensure  => directory,
    owner   => 'mailcatcher',
    group   => 'mailcatcher',
    mode    => 0755,
    require => User['mailcatcher'],
  }    

  file { $log_path:
    ensure  => file,
    owner   => 'mailcatcher',
    group   => 'mailcatcher',
    mode    => 0755,
    require => [User['mailcatcher'], File['/var/log/mailcatcher']],
  }  

  rvm_gem {
    'ruby-1.9.3-p429@vagrant/mailcatcher':
      name => 'mailcatcher',
      ensure => latest,
      require => Rvm_gemset['ruby-1.9.3-p429@vagrant'];
  }

  rvm_wrapper {
    'mailcatcher':
      target_ruby => 'ruby-1.9.3-p429@vagrant',
      prefix      => 'bootup',
      ensure      => present,
      require     => Rvm_system_ruby['ruby-1.9.3-p429'];
  }

  $supervisord_mailcatcher_options = sort(join_keys_to_values({
    ' --smtp-ip'   => $mailcatcher_values['settings']['smtp_ip'],
    ' --smtp-port' => $mailcatcher_values['settings']['smtp_port'],
    ' --http-ip'   => $mailcatcher_values['settings']['http_ip'],
    ' --http-port' => $mailcatcher_values['settings']['http_port']
  }, ' '))

  $supervisord_mailcatcher_cmd = "/usr/local/rvm/bin/bootup_mailcatcher ${supervisord_mailcatcher_options} -f  >> ${log_path}"

  supervisord::program { 'mailcatcher':
    command     => $supervisord_mailcatcher_cmd,
    priority    => '100',
    user        => 'vagrant',
    autostart   => true,
    autorestart => true,
    environment => {
      'PATH' => "/bin:/sbin:/usr/bin:/usr/sbin:${mailcatcher_values['settings']['mailcatcher_path']}"
    },
    require => [Rvm_wrapper['mailcatcher'], User['mailcatcher']]
  }
}
