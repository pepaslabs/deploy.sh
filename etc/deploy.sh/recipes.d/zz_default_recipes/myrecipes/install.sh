#!/bin/bash

# myrecipes/install.sh: interactively help a user install their recipe collection from github.
# see https://github.com/pepaslabs/deploy.sh

function you_are_on_your_own()
{
    echo "Sorry, you're on your own."
    echo "Symlink your recipes directory as deploy.sh/recipes"
    exit 1
}

echo "This script will fetch your repository of recipes."

read -p "Are your recipes in a github repo? [Y/n]: " use_github
case $use_github in
    y|Y|yes|Yes|YES|'') 

        read -p "What is the github account name? [cellularmitosis]: " account
        if [ -z "${account}" ] ; then account="cellularmitosis" ; fi

        read -p "What is the name of your recipes repo? [deploy.sh_recipes]: " repo_name
        if [ -z "${repo_name}" ] ; then repo_name="deploy.sh_recipes" ; fi

        if [ ! -e "${repo_name}" ]
        then
            echo "About to clone ${account}/${repo_name}"
            echo "  into ~/github/${account}/${repo_name}"
            echo "  using 'git clone git@github.com:${account}/${repo_name}'"
            read -p "Proceed? [Y/n]: " proceed
            case "${proceed}" in
                y|Y|yes|Yes|YES|'')

                    mkdir -p ~/github/${account}
                    cd ~/github/${account}
                    git clone git@github.com:${account}/${repo_name}

                    ;;
                *)
                    you_are_on_your_own
                    ;;
            esac
        fi

        cd "${deploysh_etc_dir}/recipes.d"
        if [ ! -e "${repo_name}" ]
        then
            echo "Symlinking ${repo_name} into recipes.d."
            ln -s -v ~/github/${account}/${repo_name} .
        fi

        ;;

    *)
        you_are_on_your_own
        ;;
esac

