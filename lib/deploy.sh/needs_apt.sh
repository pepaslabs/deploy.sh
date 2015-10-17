#!/usr/bin/env bash

set -eu -o pipefail

echo_step_component=needs/apt
echo
echo_step "Step 1."
echo_step_color "${color_purple}" "This is purple."
echo_step_ok "Command succeeded."
echo_step_warning "Expected condition not met."
echo_step_error "File not found."

for PKG in "${@}"
do
    if ! apt_pkg_is_installed.sh $PKG
    then
        apt-get --yes install $PKG
    fi
done
