#!/bin/bash

function check_r10k_installed() {
    if [[ ! -f '/usr/local/rvm/gems/ruby-1.9.3-p547/bin/r10k' ]]; then
        gem install r10k  --no-document
    fi
}

echo 'Checking if r10k is installed'

check_r10k_installed

cd /vagrant/puphpet/puppet

echo 'r10k: Sync modules'

r10k puppetfile install
