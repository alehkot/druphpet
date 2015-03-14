if $vsftpd_values == undef { $vsftpd_values = hiera_hash('vsftpd', false) }

if hash_key_equals($vsftpd_values, 'install', 1) {
  class { 'vsftpd':
    firewall          => false,
    write_enable      => true,    
    local_umask       => "022",
    template          => "vsftpd/vsftpd.conf.erb"
  }

  if ! defined(Firewall["21 tcp/ftp"]) {
    firewall { "21 tcp/ftp":
      port   => 21,
      proto  => tcp,
      action => 'accept',
    }
  }

  if ! defined(Firewall["20 tcp/ftp"]) {
    firewall { "20 tcp/ftp":
      port   => 20,
      proto  => tcp,
      action => 'accept',
    }
  }
}
