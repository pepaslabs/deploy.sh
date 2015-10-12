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

mkdir -p ~/github/${account}/recipes
cd ~/github/${account}

git clone git@github.com:${account}/recipes

cd ${_dir}/..
ln -s -v ~/github/${account}/recipes .

;;

*)

echo "Sorry kid, you're on your own."
echo "Symlink your recipes directory as display.sh/recipes"

;;

esac

