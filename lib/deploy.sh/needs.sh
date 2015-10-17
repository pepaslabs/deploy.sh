#!/bin/bash

# needs.sh: subcommand of deploy.sh
# see https://github.com/pepaslabs/deploy.sh


# "strict" mode
# thanks to http://stackoverflow.com/a/13099228
# thanks to https://sipb.mit.edu/doc/safe-shell/
set -o pipefail    # trace ERR through pipes
set -o errtrace    # trace ERR through 'time command' and other functions
set -o nounset     # set -u : exit the script if you try to use an uninitialised variable
set -o errexit     # set -e : exit the script if any statement returns a non-true return value
shopt -s failglob  # if a glob doesn't expand, fail.

# honor verbosity recursively
# thanks to http://unix.stackexchange.com/a/21929/136746
use_x=`case "$-" in *x*) echo "-x" ;; esac`

source "${deploysh_lib_dir}/exit_codes.bash"

echo_step_component=needs

needs_subcmd="${1}"
shift

needs_subcmd_fpath="${deploysh_lib_dir}/needs_${needs_subcmd}.sh"
if [ ! -e "${needs_subcmd_fpath}" ]
then
    echo_step_error "No such subcommand: needs_${needs_subcmd}.sh"
    exit $needs_err_no_such_subcommand
fi

bash ${use_x} "${needs_subcmd_fpath}" "${@}"
