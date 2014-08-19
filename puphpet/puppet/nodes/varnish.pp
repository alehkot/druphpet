# Begin Varnish

if $varnish_values == undef {
  $varnish_values = hiera('varnish', false)
}

if has_key($varnish_values, 'install') and $varnish_values['install'] == 1 {
  class {'varnish':
    varnish_listen_port => 8080,
    varnish_storage_size => '1G',
  }

  class { 'varnish::vcl': }

  varnish::probe { 'health_check1': url => '/health_check_url1' }

  varnish::backend { 'drupaldev': host => '192.168.9.10', port => '80', probe => 'health_check1' }

  varnish::selector { 'drupaldev': condition => 'true' }
}
