#!/bin/bash

echo "This script will fetch your repository of recipes."

read -p "Are your recipes in a github repo? [y]:" use_github
case $use_github in

y|Y|'') 

read -p "What is your github username? [cellularmitosis]: " account
if [ -z "${account}" ]
then
    account="cellularmitosis"
fi


mkdir -p ~/github/${account}
cd ~/github/${account}

if [ ! -e recipes ]
then
    git clone git@github.com:${account}/recipes
fi

cd ${_dir}/..
if [ ! -e recipes ]
then
    ln -s -v ~/github/${account}/recipes .
fi

;;

*)

echo "Sorry kid, you're on your own."
echo "Symlink your recipes directory as display.sh/recipes"

;;

esac

