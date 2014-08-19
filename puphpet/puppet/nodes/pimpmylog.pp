# Begin PimpMyLog

if $pimpmylog_values == undef {
  $pimpmylog_values = hiera('pimpmylog', false)
}

if has_key($pimpmylog_values, 'install') and $pimpmylog_values['install'] == 1 {
  class { 'pimpmylog':

  }
}
