# Begin VSFTPd.

class druphpet_vsftpd ($vsftpd) {
  create_resources('class', {'vsftpd' => $vsftpd['settings']})

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
