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
    force_group => 'vagrant',
    force_user => 'vagrant',
    writable => true,
  }
  
  if ! defined(Firewall["139 tcp/139, 445"]) {
    firewall { "139 tcp/139, 445":
      port   => [193, 445],
      proto  => tcp,
      action => 'accept',
    }
  }   
}
