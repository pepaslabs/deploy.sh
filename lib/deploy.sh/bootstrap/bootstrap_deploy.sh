#!/bin/bash

# bootstrap_deploy.sh: install deploy.sh and fetch your recipes from github.
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
if [ ! -e "deploy.sh" ]
then
    git clone https://github.com/pepaslabs/deploy.sh
fi

mkdir -p ~/bin
cd ~/bin
ln -s ~/github/pepaslabs/deploy.sh/bin/deploy.sh .

if ! which deploy.sh >/dev/null 2>&1
then
    
read -p "Append PATH entry for ~/bin to ~/.bashrc? [Y/n]: " should_append_path
case $should_append_path in
y|Y|'')
echo "Please source ~/.bashrc for PATH changes to take effect."
cat >> ~/.bashrc << EOF
export PATH="~/bin:${PATH}"
EOF
;;
*)
echo "NOT modifying ~/.bashrc"
;;
esac

fi

bash ~/github/pepaslabs/deploy.sh/bin/deploy.sh install recipes
