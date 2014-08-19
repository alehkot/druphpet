# Begin Apache Solr

if $solr_values == undef {
  $solr_values = hiera('solr', false)
}

if has_key($solr_values, 'install') and $solr_values['install'] == 1 {
  class { 'solr':

  }
}
