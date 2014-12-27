# Begin Webgrind

if $webgrind_values == undef {
  $webgrind_values = hiera('webgrind', false)
}

if has_key($webgrind_values, 'install') and $webgrind_values['install'] == 1 {
  class { 'webgrind':
    domain => $webgrind_values['settings']['domain'],
  }
}
