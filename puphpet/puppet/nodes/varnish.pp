# Begin Varnish.

class druphpet_varnish($varnish) {
  create_resources('class', {'varnish' => {
      varnish_listen_port => $varnish['settings']['varnish_listen_port'],
      varnish_storage_size => $varnish['settings']['varnish_storage_size']
  }})
  class {'varnish::vcl': , require => Class['varnish']}
  varnish::probe { 'health_check1': url => '/health_check_url1' }
  varnish::backend { 'drupaldev': host => $varnish['settings']['host'], port => $varnish['settings']['host_port'], probe => 'health_check1' }
  varnish::selector { 'drupaldev': condition => 'true' }
}
