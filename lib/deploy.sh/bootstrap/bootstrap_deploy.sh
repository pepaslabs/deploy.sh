#!/usr/bin/env bash

# bootstrap_deploy.sh: install deploy.sh and fetch your recipes from github.
# see https://github.com/pepaslabs/deploy.sh

# status codes:
err_git_not_installed=2

set -eu -o pipefail

echo2()
{
    echo "$@" >&2
}

prompt_to_proceed()
{
    local message="${1}"

    read -p "${message} [Y/n]: " yn
    case $yn in
        y|Y|'') echo "Proceeding..." ;;
        * ) echo2 "Exiting..." ; exit 1 ;;
    esac
    # thanks to http://stackoverflow.com/a/226724
}


if ! which git >/dev/null
then
    echo2 "ERROR: git not found."
    if [ -e /etc/debian_version ]
    then
        if [ "$(whoami)" == "root" ]
        then
            install_git_command="apt-get install git"
        else
            install_git_command="sudo apt-get install git"
        fi
        prompt_to_proceed "About to '${install_git_command}'.  Proceed?"
        eval "${install_git_command}"
    else
        echo2 "ERROR: please install git."
        exit $git_not_installed
    fi
fi

mkdir -p ~/github/pepaslabs
cd ~/github/pepaslabs
if [ ! -e "deploy.sh" ]
then
    git_clone_command='git clone https://github.com/pepaslabs/deploy.sh'
    echo "Running '${git_clone_command}'"
    eval "${git_clone_command}"
fi

mkdir -p ~/bin
if [ ! -e ~/bin/deploy.sh ]
then
    cd ~/bin
    ln -s ~/github/pepaslabs/deploy.sh/bin/deploy.sh .
fi

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
