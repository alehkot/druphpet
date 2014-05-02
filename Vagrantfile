Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu-precise12042-x64-vbox43"
  config.vm.box_url = "http://box.puphpet.com/ubuntu-precise12042-x64-vbox43.box"
  
  config.vm.hostname = "drupal.dev"
 
  config.vm.network "private_network", ip: "192.168.9.10"
  
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true  
  
  config.vm.synced_folder "./www", "/var/www", owner: "vagrant", group: "vagrant"
  # To enable Samba (Windows-only) comment the previous and remove comments from the next lines.
  # config.vm.synced_folder "./www", "/var/www", owner: "vagrant", group: "vagrant", type: "smb"

  config.vm.usable_port_range = (2200..2250)
  config.vm.provider :virtualbox do |virtualbox|
    virtualbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    virtualbox.customize ["modifyvm", :id, "--memory", "512"]
    virtualbox.customize ["setextradata", :id, "--VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  end

  config.vm.provision :shell, :path => "puphpet/shell/initial-setup.sh"
  config.vm.provision :shell, :path => "puphpet/shell/update-puppet.sh"
  config.vm.provision :shell, :path => "puphpet/shell/librarian-puppet-vagrant.sh"
  config.vm.provision :puppet do |puppet|
    puppet.facter = {
      "ssh_username" => "vagrant"
    }

    puppet.manifests_path = "puphpet/puppet/manifests"
    puppet.options = ["--verbose", "--hiera_config /vagrant/puphpet/puppet/hiera.yaml", "--parser future"]
  end

  config.vm.provision :shell, :path => "puphpet/shell/execute-files.sh"

  config.ssh.username = "vagrant"

  config.ssh.shell = "bash -l"

  config.ssh.keep_alive = true
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = false  
end
