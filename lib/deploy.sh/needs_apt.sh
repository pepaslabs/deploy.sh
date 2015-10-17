#!/usr/bin/env bash

set -eu -o pipefail

for PKG in "${@}"
do
    if ! apt_pkg_is_installed.sh $PKG
    then
        apt-get --yes install $PKG
    fi
done
