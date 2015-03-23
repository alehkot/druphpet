#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

VAGRANT_CORE_FOLDER=$(cat '/.puphpet-stuff/vagrant-core-folder.txt')

OS=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" ID)
RELEASE=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" RELEASE)
CODENAME=$(/bin/bash "${VAGRANT_CORE_FOLDER}/shell/os-detect.sh" CODENAME)

# deep_merge gem required by hiera
if [[ ! -f /.puphpet-stuff/install-deep_merge-03122015 ]]; then
    gem install deep_merge --no-ri --no-rdoc
    touch /.puphpet-stuff/install-deep_merge-03122015
fi

if [[ ! -f /.puphpet-stuff/install-activesupport-03132015 ]]; then
    gem install activesupport --no-ri --no-rdoc
    touch /.puphpet-stuff/install-activesupport-03132015
fi

if [[ -f /.puphpet-stuff/install-puppet-3.4.3 ]]; then
    exit 0
fi

rm -rf /usr/bin/puppet

if [ "${OS}" == 'debian' ] || [ "${OS}" == 'ubuntu' ]; then
    apt-get -y install augeas-tools libaugeas-dev
elif [[ "${OS}" == 'centos' ]]; then
    yum -y install augeas-devel
fi

echo 'Installing Puppet requirements'
gem install haml hiera facter json ruby-augeas deep_merge --no-ri --no-rdoc
echo 'Finished installing Puppet requirements'

echo 'Installing Puppet 3.4.3'
gem install puppet --version 3.4.3 --no-ri --no-rdoc
echo 'Finished installing Puppet 3.4.3'

cat >/usr/bin/puppet << 'EOL'
#!/bin/bash

rvm ruby-1.9.3-p551 do puppet "$@"
EOL

chmod +x /usr/bin/puppet

touch /.puphpet-stuff/install-puppet-3.4.3
