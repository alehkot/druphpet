# Druphpet Virtual Machine #
A very fast and Puppet-based Drupal-ready VM suitable for instant and unified configuration of local environments. The ultimate goal of Druphpet is to provide a powerful set of tools out-of-the-box to develop typical enterprise websites with Drupal. You can easily add sites, databases, packages, etc. simply be editing `puphpet/config.yaml` file in YAML format.

Based on VMs by [Puphpet](http://puphpet.com "Puphpet").

The VM includes the fastest option available to synchronize folders in Windows - via SMB share. Please find the instructions below on how to map a network drive.

## Install ##
- Make sure you have the most recent versions of VirtualBox and Vagrant installed (see 'minimum requirements' section).
- Clone the repository `git clone https://github.com/alehkot/druphpet.git`.
- Add any number of Apache hosts and databases you want in appropriate sections of 'puphpet/config.yaml' file.
- Edit your hosts file and add entries for the following (on Windows, `C:\Windows\System32\drivers\etc\hosts`):
	`
192.168.9.10 druphpet.dev
192.168.9.10 phpmyadmin.druphpet.dev
192.168.9.10 webgrind.druphpet.dev
192.168.9.10 opcachegui.druphpet.dev
192.168.9.10 phpmemcacheadmin.druphpet.dev
192.168.9.10 pimpmylog.druphpet.dev`
- Add your hosts `192.168.9.10 [yourhost]`
- In the folder with Druphpet in your command line execute `vagrant up`.
- Important! In case of any errors during the initial setup, try to run provision the VM once again: `vagrant reload --provision`. It usually resolves any issues.
- It is strongly recommended to reboot the VM after successful provisioning using `vagrant reload`.

## Modification ##
- In case you later decide to add new hosts, PHP packages and/or install an additional software, then edit 'puphpet/config.yaml' file.
- Execute `vagrant provision`.
- Execute `vagrant reload`.

## Included ##
- [Ubuntu 64-bit Precise 14.04](http://www.ubuntu.com/)
- [Drush 7.x](http://drush.org/en/master/)
- [Apache 2.4.x](http://httpd.apache.org/) or [Nginx](http://nginx.org/)
- [PHP 5.6.x](http://php.net/) with extensions:
  - _(debugger, pecl)_ [XDebug](http://xdebug.org/)
  - _(profiler, tool, pecl)_ [XHProf](https://github.com/phacility/xhprof)
  - _(pecl)_ [SOAP](http://php.net/manual/en/intro.soap.php)
  - _(pecl)_ [Uploadprogress](http://pecl.php.net/package/uploadprogress)
  - _(pecl)_ [APCu](https://github.com/krakjoe/apcu/blob/simplify/INSTALL)
  - _(pecl)_ [Memcached](http://php.net/manual/en/intro.memcached.php)
  - _(tool, PEAR)_ [PHP_CodeSniffer](http://pear.php.net/package/PHP_CodeSniffer/redirected)
  - _(PEAR)_ [PHP_Console_Table](http://pear.php.net/package/Console_Table)
- Optionally, old versions of PHP are also available with the following extensions:
	- _(pecl)_ [APC](http://php.net/manual/en/book.apc.php)
	- _(pecl)_ [XCache](http://xcache.lighttpd.net/)
- [Apache Solr 4.x](http://lucene.apache.org/solr/)
- [PostgreSQL 9.3](http://www.postgresql.org/)
- [OPCacheGUI](https://github.com/PeeHaa/OpCacheGUI)
- [PHPMemcacheAdmin](https://code.google.com/p/phpmemcacheadmin)
- [MySQL 5.6.x](http://www.mysql.com/)
- [dos2unix](http://linuxcommand.org/man_pages/dos2unix1.html)
- [Percona Toolkit](http://www.percona.com/software/percona-toolkit)
- [Adminer](http://www.adminer.org/) (or [phpMyAdmin](http://www.phpmyadmin.net/home_page/index.php))
- [PimpMyLog](http://pimpmylog.com/)
- [MailCatcher](http://mailcatcher.me/)
- [ImageMagick](http://www.imagemagick.org/)
- [Webgrind](https://github.com/jokkedk/webgrind)
- [Curl](http://curl.haxx.se/)
- [Varnish](https://www.varnish-cache.org/)
- [Sendmail](http://www.linuxserverhowto.com/linux-mail-server-sendmail/index.html)
- [Unzip](http://www.cyberciti.biz/tips/how-can-i-zipping-and-unzipping-files-under-linux.html)
- [Git](http://git-scm.com/)
- [RabbitMQ](http://www.rabbitmq.com/) or [Beanstalkd](http://kr.github.io/beanstalkd/)
- [New Relic](http://newrelic.com/)
- [Graphviz](http://www.graphviz.org/)
- [Vsftpd](https://security.appspot.com/vsftpd.html)
- [MC](http://linux.die.net/man/1/mc)
- [Vim](http://www.vim.org/)
- [Samba Server](https://www.samba.org/samba/docs/using_samba/ch02.html)
- [Memcached](http://memcached.org/)
- [Ruby 1.9.3](https://www.ruby-lang.org/) using [RVM](https://rvm.io/) with gems:
  - [Sass](http://sass-lang.com/)
  - [Compass](http://compass-style.org/)
  - [Bundler](http://bundler.io/)
  - [Guard](https://github.com/guard/guard)
  - [Guard-livereload](https://github.com/guard/guard-livereload)
- [Node.js](http://nodejs.org/) with packages:
    - [Yeoman](http://yeoman.io/)
    - [Bower](http://bower.io/)
    - [Grunt](http://gruntjs.com/)
    - [Gulp](http://gulpjs.com/)
    - [Coffee-script](http://coffeescript.org/)
    - [JSHint](http://jshint.com/)
    - [CSSLint](http://csslint.net/)
    - [ESLint](http://eslint.org/)
    - [Nodemon](http://nodemon.io/)
- [Python](https://www.python.org/)

### Additional notes
- Some of the packages are not enabled by default. You can always adjust installed packages and settings in `puphpet/config.yaml` file.
- If you want to use **Nginx** HTTP server instead of **Apache** please checkout special ['nginx'](https://github.com/alehkot/druphpet/tree/nginx) branch of the repository. Please note, the following modules of Druphpet haven't been integrated with Nginx yet, hence disabled: Webgrind, Pimpmylog, Phpmyadmin.
- While it's possible to use older version of PHP and other software (you can simply update Druphpet configs), you can do it at your own risk. In the worst case some software won't be installed and settings and tunings of Druphpet won't be applied. On one hand there is an intention to stay current with Puphpet, on the other hand it's impossible at this moment to backport all Druphpet alterations even to older versions of PHP, which supported by Puphpet. If you need to use PHP 5.4, for example, better use the original [VM](http://puphpet.com "Puphpet").

## Defaults
**Hosts**

- http://druphpet.dev

**FTP**
* Host: 192.168.9.10
* User: vagrant
* Pass: vagrant

**Database Credentials (MySQL, PostgreSQL)**

* Host: 192.168.9.10
* Name: druphpet
* User: druphpet
* Pass: druphpet
* To connect using a MySQL client other than Phpmyadmin, after initial `vagrant up` it's recommended to reboot the VM using `vagrant reload`.

**Mailcatcher**

- http://192.168.9.10:1080

**Xdebug**

- Xdebug is configured to automatically connect back to host if _XDEBUG_SESSION_START_ query parameter is set, e.g. if you access http://druphpet.dev/index.php?XDEBUG_SESSION_START=PHPSTORM.
- To use Xdebug with [Jetbrains PHPStorm](https://www.jetbrains.com/phpstorm/) please follow the [instructions](http://randyfay.com/content/remote-drupalphp-debugging-xdebug-and-phpstorm).
- If upon accessing pages of your website _XDEBUG_SESSION_START_ Xdebug ignores breakpoints you set in your IDE, it might be a case of a misconfigured firewall in your host environment. Try disabling the firewall to see if the issue is resolved.

**XHProf**

- http://192.168.9.10/xhprof/xhprof_html

**PimpMyLog**

- http://pimpmylog.druphpet.dev

**Memcached**

- host: localhost (from VM)
- port: 11211

**Phpmyadmin**

- http://phpmyadmin.druphpet.dev

**Webgrind**

- http://webgrind.druphpet.dev

**OPCacheGUI**

- http://opcachegui.druphpet.dev
- username: druphpet
- password: druphpet

**PHPMemcacheAdmin**

- http://phpmemcacheadmin.druphpet.dev

**RabbitMQ**

- port: 5672

**Apache Solr**

- http://druphpet.dev:8984/solr

**Samba server share (default)**

- \\\192.168.9.10\data

On Windows, after `vagrant up`, you can just open "My computer", click "Map network drive" and enter the address above.

On Mac, In the Finder, choose Go > 'Connect to Server.' Type the following network address: `smb://192.168.9.10/data`

**Varnish**

- Varnish proxifies all requests from port 8080 to port 80, e.g. you can access http://192.168.9.10:8080/webgrind.
- You can edit its config in '/etc/varnish/default.vcl' file.

## Minimum requirements ##
* Git
* VirtualBox 4.3.10
* Vagrant 1.5.4

## Download links (Windows) ##
- [VirtualBox](http://download.virtualbox.org/virtualbox/4.3.10/VirtualBox-4.3.10-93012-Win.exe "Download VirtualBox 4.3.10")
- [Vagrant](https://dl.bintray.com/mitchellh/vagrant/vagrant_1.5.4.msi "Download Vagrant 1.5.4")
- [PowerShell 3](http://www.microsoft.com/en-us/download/details.aspx?id=34595 "Download PowerShell 3")

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

- If you experience problems with remote debugging (PHP, NodeJS) and don't want (or can't) configure your firewall try creating SSH-tunnels as following:
  - PHP: `ssh -R 9000:localhost:9000 vagrant@druphpet.dev`
  - NodeJS: `ssh -L 5858:127.0.0.1:5858 vagrant@druphpet.dev -N`

- In case of a public key warning with the previous commands try to delete your known_hosts file.

- You can change the sync_modules variable to false after the first time your box is provisioned.

- If you receive the error `Error: Unknown function loadyaml`, switch 'sync_modules' property in config.yaml to `true`.
