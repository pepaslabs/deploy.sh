#!/bin/bash

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

# _script: the name of this script
# _scriptdir: the directory which this script resides in
# thanks to https://github.com/kvz/bash3boilerplate/blob/master/main.sh
_script="$(basename "${BASH_SOURCE[0]}")"
_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_libpath="${_dir}/../lib/deploy.sh"

export PATH="${_dir}:${_libpath}:${PATH}"

subcmd=${1}
shift

bash ${use_x} needs_${subcmd}.sh "${@}"
