# Druphpet Virtual Machine #
A Puppet-based Drupal-ready VM suitable for instant and unified configuration of Drupal-Dev environments.

Based on [https://drupal.org/project/vm](https://drupal.org/project/vm "Virtual Machine") project on Drupal.org.

[Puphpet](https://github.com/puphpet/puphpet "Puphpet") compatible.

Drupal.org project URL: [Druphpet](https://drupal.org/sandbox/k0teg/2247955).

## Included ##
- Ubuntu 64-bit Precise
- Drush 7.x
- Apache 2.4
- PHP 5.5 with steroids:
	- XDebug	
	- XHProf
    - Soap
    - Uploadprogress
- Optionally, old versions of PHP are also available with the following extensions:
	- APC
	- XCache
- Apache Solr 4.6.0
- MySQL 5.5.37
- [Adminer](http://www.adminer.org/) (or [phpMyAdmin](http://www.phpmyadmin.net/home_page/index.php))
- [PimpMyLog](http://pimpmylog.com/)
- [MailCatcher](http://mailcatcher.me/)
- ImageMagick

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

**Known issues**

- Windows-only, to enable Samba, follow the instuctions in Vagrantfile. 

- Windows-only, if during `vagrant up` you receive the following error:
> "Failed to mount folders in Linux guest. This is usually because the "vboxsf" file system is not available. Please verify that the guest additions are properly installed in the guest and can work properly." 
- execute the following statements:
	- `vagrant ssh`
	- `sudo ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions` 
	- `exit`
	- `vagrant reload`

- Windows-only, to enable "rsync", install the latest version of [Cygwin](http://www.cygwin.com) and in setup wizard pick "rsync" package to be installed (it's not included by default). Because Vagrant on Windows uses Cygdrive for rsync, you should `vagrant up` under Cygwin shell (an example location is 'c:\cygwin64\Cygwin.bat'). 

- Windows only, if during `vagrant up` using Cygwin you receive an error about "nio4r", execute the following statements:
	- `export NIO4R_PURE="yes"`
