#!/usr/bin/env bash

# needs_pip.sh: subcommand of needs.sh
# see https://github.com/pepaslabs/deploy.sh


# "strict" mode
# thanks to http://stackoverflow.com/a/13099228
# thanks to https://sipb.mit.edu/doc/safe-shell/
set -o pipefail    # trace ERR through pipes
set -o errtrace    # trace ERR through 'time command' and other functions
set -o nounset     # set -u : exit the script if you try to use an uninitialised variable
set -o errexit     # set -e : exit the script if any statement returns a non-true return value
shopt -s failglob  # if a glob doesn't expand, fail.


source "${deploysh_lib_dir}/exit_codes.bash"

echo_step_component=needs/pip

needs.sh apt python-pip

for pkg in "${@}"
do
    echo_step "Installing ${color_yellow}${pkg}${color_off}"
    pip install "${pkg}" || \
    (
        exit_status=$?
        echo_step_error "${color_yellow}pip install ${pkg}${color_off} exited status $exit_status."
        exit $exit_status
    )
    echo_step_ok "${color_yellow}${pkg}${color_off} installed."
done
