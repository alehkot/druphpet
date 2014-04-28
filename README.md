# Druphpet Virtual Machine #
A Puppet-based Drupal-ready VM suitable for instant and unified configuration of Drupal-Dev environments.

Based on [https://drupal.org/project/vm](https://drupal.org/project/vm "Virtual Machine") project on Drupal.org.

[Puphpet](https://github.com/puphpet/puphpet "Puphpet") compatible.

## Included ##
- Ubuntu 64-bit Precise
- Drush 7.x
- Apache 2.4
- PHP 5.5 with steroids:
	- XDebug
	- APC
	- XHProf
    - Soap
    - XCache    
- Apache Solr 4.7.2
- MySQL 5.5.37
- phpMyAdmin

## Defaults
**Hosts**

- http://drupal.dev
- http://xhprof.drupal.dev

**Database Credentials**

* Name: drupal
* User: drupal
* Pass: drupal

## Minimum requirements ##
* Git
* VirtualBox 4.3.10
* Vagrant 1.5.4
* (For Samba, Windows-only) PowerShell 3

## Download links (Windows) ##
- [VirtualBox](http://download.virtualbox.org/virtualbox/4.3.10/VirtualBox-4.3.10-93012-Win.exe "Download VirtualBox 4.3.10")
- [Vagrant](https://dl.bintray.com/mitchellh/vagrant/vagrant_1.5.4.msi "Download Vagrant 1.5.4")
- [PowerShell 3](http://www.microsoft.com/en-us/download/details.aspx?id=34595 "Download PowerShell 3")

## Install ##

- Make sure you have the latests versions of VirtualBox and Vagrant installed (see 'minimum requirements' section). 
- Clone the repository
- Edit your hosts file and add entries for the following (on Windows, `C:\Windows\System32\drivers\etc\hosts`):
	- `192.168.9.10 drupal.dev`
	- `192.168.9.10 xhprof.drupal.dev`
- Execute `vagrant up`

**Notes**

- Windows-only, to enable Samba, follow the instuctions in Vagrantfile. If then you receive the following error:
> "Failed to mount folders in Linux guest. This is usually because the "vboxsf" file system is not available. Please verify that the guest additions are properly installed in the guest and can work properly." 

- execute the following statements:
	- `vagrant ssh
	- `sudo ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions` 
	- `sudo apt-get install make gcc`
	- `sudo apt-get install dkms`
	- `sudo /etc/init.d/vboxadd setup`
	- `exit`
	- `vagrant reload`
