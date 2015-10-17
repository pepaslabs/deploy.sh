#!/usr/bin/env bash

# bootstrap_deploy.sh: install deploy.sh and fetch your recipes from github.
# see https://github.com/pepaslabs/deploy.sh


# status codes:

err_user_cancelled=2
err_git_not_installed=3


# strict mode

set -eu -o pipefail


# functions

echo2()
{
    echo "$@" >&2
}

prompt_Yn()
{
    local message="${1}"

    echo -n " * PROMPT: ${message} [Y/n]: "

    read yn
    case $yn in
        y|Y|yes|Yes|YES|'') return 0 ;;
        *) return 1 ;;
    esac
    # thanks to http://stackoverflow.com/a/226724
}


# install git

if ! which git >/dev/null
then
    echo2 " * WARNING: git not found."
    if [ -e /etc/debian_version ]
    then
        if [ "$(whoami)" == "root" ]
        then
            install_git_command="apt-get install git"
        else
            install_git_command="sudo apt-get install git"
        fi
        if prompt_Yn "About to '${install_git_command}'.  Proceed?"
        then
            echo " * Running '${install_git_command}'."
            eval "${install_git_command}"
        else
            echo2 "Exiting..."
            exit $err_user_cancelled
        fi
    else
        echo2 " * ERROR: Please install git."
        exit $err_git_not_installed
    fi
fi


# install deploy.sh

mkdir -p ~/github/pepaslabs
cd ~/github/pepaslabs
if [ ! -e "deploy.sh" ]
then
    git_clone_command='git clone https://github.com/pepaslabs/deploy.sh'
    if prompt_Yn "About to clone github.com/pepaslabs/deploy.sh.  Proceed?"
    then
        echo " * Running '${git_clone_command}'."
        eval "${git_clone_command}"
    else
        echo2 "Exiting..."
        exit $err_user_cancelled
    fi
fi

mkdir -p ~/bin
if [ ! -e ~/bin/deploy.sh ]
then
    echo " * Symlinking deploy.sh into ~/bin."
    cd ~/bin
    ln -s ~/github/pepaslabs/deploy.sh/bin/deploy.sh .
fi


# adjust PATH

if ! which deploy.sh >/dev/null 2>&1
then
    if prompt_Yn "Add ~/bin to PATH in ~/.bashrc?"
    then
        echo " * NOTE: Please source ~/.bashrc for PATH changes to take effect."
        cat >> ~/.bashrc << EOF

# added by deploy.sh
export PATH="~/bin:${PATH}"
EOF
    else
        echo " * NOT modifying ~/.bashrc"
    fi
fi


# fetch the user's recipes

install_myrecipes_command='deploy.sh install myrecipes'
if prompt_Yn "About to '${install_myrecipes_command}'.  Proceed?"
then
    echo " * Running '${install_myrecipes_command}'."
    bash ~/github/pepaslabs/deploy.sh/bin/deploy.sh install myrecipes
else
    echo2 "Exiting..."
    exit $err_user_cancelled
fi
