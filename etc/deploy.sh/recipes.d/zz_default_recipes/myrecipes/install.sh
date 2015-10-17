#!/bin/bash

# myrecipes/install.sh: interactively help a user install their recipe
# collection from github.

env
exit 0

function you_are_on_your_own()
{
    echo "Sorry, you're on your own."
    echo "Symlink your recipes directory as display.sh/recipes"
}

echo "This script will fetch your repository of recipes."

read -p "Are your recipes in a github repo? [Y/n]: " use_github
case $use_github in

y|Y|'') 

read -p "What is the github account name? [cellularmitosis]: " account
if [ -z "${account}" ]
then
    account="cellularmitosis"
fi

read -p "What is the name of your recipes repo? [deploy.sh_recipes]: " repo_name
if [ -z "${repo_name}" ]
then
    repo_name="deploy.sh_recipes"
fi

if [ ! -e "${repo_name}" ]
then
    echo "About to clone ${account}/${repo_name}"
    echo "  into ~/github/${account}/${repo_name}"
    echo "  using 'git clone https://github.com/${account}/${repo_name}'"
    read -p "Proceed? [Y/n]: " proceed
    case "${proceed}" in
    y|Y|'')
        mkdir -p ~/github/${account}
        cd ~/github/${account}
        #git clone git@github.com:${account}/${repo_name}
        git clone https://github.com/${account}/${repo_name}
    ;;
    *)
        you_are_on_your_own
        exit 0
    ;;
    esac
fi

cd ${_dir}/..
if [ ! -e "${repo_name}" ]
then
    ln -s -v ~/github/${account}/${repo_name} .
fi

;;

*)

you_are_on_your_own
exit 0

;;

esac

