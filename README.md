# Druphpet Virtual Machine #
A Puppet-based Drupal-ready VM suitable for instant and unified configuration of awesome-Dev environments.
You can easily add sites, databases, packages, etc. simply be editing `puphpet/config.yaml` file in Yaml format.

Based on VMs generated using [Puphpet](http://puphpet.com "Puphpet").

## Included ##
- Ubuntu 64-bit Precise 14.04
- Drush 6.4
- Apache 2.2(4) with mod_pagespeed and/or nginx
- PHP 5.6 with steroids:
  - XDebug
  - XHProf
  - SOAP
  - Uploadprogress
  - APCu
  - Memcached
  - PHP_CodeSniffer
- Optionally, old versions of PHP are also available with the following extensions:
	- APC
	- XCache
- Apache Solr 4.6.0
- MySQL 5.5.37
- [Adminer](http://www.adminer.org/) (or [phpMyAdmin](http://www.phpmyadmin.net/home_page/index.php))
- [PimpMyLog](http://pimpmylog.com/)
- [MailCatcher](http://mailcatcher.me/)
- ImageMagick
- Webgrind
- Curl
- Sendmail
- Unzip
- Git
- RabbitMQ
- New Relic
- Graphviz
- MC
- Vim
- Samba Server
- Memcached
- Ruby 1.9.3 using RVM with gems:
  - Sass
  - Compass
  - Bundler
  - Guard
  - Guard-livereload
  - Nodemon
- node.js with packages:
    - Yeoman
    - Bower
    - Grunt
    - Gulp
    - Coffee-script
    - JSHint
    - CSSLint
    - JSLint

Some of the packages are not enabled by default. You can always adjust installed packages and settings in `puphpet/config.yaml` file.

## Local overrides
(not working at this moment)
`puphpet/local.config.yaml` can be used to set overrides for default configuration from `puphpet/config.yaml`.

## Defaults
**Hosts**

- http://awesome.dev
- http://xhprof.awesome.dev

**Database Credentials**

* Name: awesome
* User: awesome
* Pass: awesome

**Mailcatcher**

- http://192.168.9.10:8088

**PimpMyLog**

- http://192.168.9.10/pimpmylog

**Webgrind**

- http://webgrind.awesome.dev

**RabbitMQ**

- port: 5672

**Apache Solr**

- http://awesome.dev:8983/solr

**Samba server share (default)**

- \\\192.168.9.10\data

**Varnish**

- port: 8080

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
	- `192.168.9.10 awesome.dev`
	- `192.168.9.10 xhprof.awesome.dev`
- Execute `vagrant up`
- In case of any errors, try to provision the VM at least once again: `vagrant reload --provision`
- On Windows if you need SMB support, it's important to install [Power Shell 3](http://www.microsoft.com/en-us/download/details.aspx?id=34595) beforehand.
- To enable sharing of folders using default, NFS, Rsync methods, just remove comments from the appropriate lines in Vagrantfile. By default, only SMB  is enabled.

**Known issues**
- Integration of some of the modules in Druphpet is still in progress.

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

- Windows-only, if you receive the following error:
> "Vagrant uses the `VBoxManage` binary that ships with VirtualBox, and requires this to be available on the PATH. If VirtualBox is installed, please find the `VBoxManage` binary and add it to the PATH environmental variable."
- during `vagrant up` execution, then execute the following command:
	- `set PATH=%PATH%;C:\Program Files\Oracle\VirtualBox`

- If you experience problems with remote debugging (PHP, NodeJS) try creating SSH-tunnels as following:
  - PHP: `ssh -R 9000:localhost:9000 vagrant@awesome.dev`
  - NodeJS: `ssh -L 5858:127.0.0.1:5858 vagrant@awesome.dev -N`
