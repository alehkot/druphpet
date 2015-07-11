# Begin Samba

class druphpet_samba($samba) {
  create_resources('class', {'samba::server' => $samba['settings']['server']})

  $share_settings = $samba['settings']['share']

  samba::server::share { 'data':
    comment => $share_settings['comment'],
    path  => $share_settings['path'],
    guest_only => $share_settings['guest_only'],
    guest_ok => $share_settings['guest_ok'],
    guest_account => $share_settings['guest_account'],
    browsable => $share_settings['browsable'],
    create_mask => $share_settings['create_mask'],
    force_create_mask => $share_settings['force_create_mask'],
    directory_mask => $share_settings['directory_mask'],
    force_directory_mask => $share_settings['force_directory_mask'],
    force_group => $share_settings['force_group'],
    force_user => $share_settings['force_user'],
    writable => $share_settings['writable']
  }

  if ! defined(Firewall["139 tcp/139, 445"]) {
    firewall { "139 tcp/139, 445":
      port   => [193, 445],
      proto  => tcp,
      action => 'accept',
    }
  }
  #samba::server::share { 'data': 'data'}
}
