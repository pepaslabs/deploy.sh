#!/usr/bin/env bash

set -eu -o pipefail

needs.sh apt python-pip

for pkg in "${@}"
do
    if ! pip_pkg_is_installed.sh "${pkg}"
    then
        pip install "${pkg}"
    fi
done
