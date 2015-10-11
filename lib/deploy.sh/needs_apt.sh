#!/usr/bin/env bash

set -e

echo "${@}"
exit 0

for PKG in "${@}"
do
    if ! apt_pkg_is_installed.sh $PKG
    then
        apt-get install $PKG
    fi
done
