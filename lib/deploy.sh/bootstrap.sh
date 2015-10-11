#!/bin/bash

# bootstrap.sh: install deploy.sh and fetch your recipes from github.
# see https://github.com/pepaslabs/deploy.sh

# status codes:
err_git_not_installed=2

set -eu -o pipefail

if ! which git >/dev/null
then
    if [ -e /etc/debian_version ]
    then
        if [ "$(whoami)" == "root" ]
        then
            apt-get install git
        else
            sudo apt-get install git
        fi
    else
        echo "ERROR: please install git." >&2
        exit $git_not_installed
    fi
fi

mkdir -p ~/github/pepaslabs
cd ~/github/pepaslabs
git clone https://github.com/pepaslabs/deploy.sh

deploy.sh/bin/deploy.sh install recipes
