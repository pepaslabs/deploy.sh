#!/usr/bin/env bash

# status codes:
err_bad_usage=2
err_no_recipes_path=3

# "strict" mode
# thanks to http://stackoverflow.com/a/13099228
# thanks to https://sipb.mit.edu/doc/safe-shell/
set -o pipefail    # trace ERR through pipes
set -o errtrace    # trace ERR through 'time command' and other functions
set -o nounset     # set -u : exit the script if you try to use an uninitialised variable
set -o errexit     # set -e : exit the script if any statement returns a non-true return value
shopt -s failglob  # if a glob doesn't expand, fail.

# _script: the name of this script
# _scriptdir: the directory which this script resides in
# thanks to https://github.com/kvz/bash3boilerplate/blob/master/main.sh
_script="$(basename "${BASH_SOURCE[0]}")"
_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_libpath="${_dir}/../lib/deploy.sh"

export PATH="${_dir}:${_libpath}:${PATH}"

source bashx.bash
export -f bashx

default_recipes_path="${_dir}/recipes"
recipes_path="${DEPLOY_RECIPES_PATH:-${default_recipes_path}}"

function usage()
{
    cat << EOF
Usage: ${_script} {install|remove} <recipe>
EOF
}

function usage_fatal()
{
    echo $(usage) >&2
    exit $err_bad_usage
}

if [ -z "${1:-}" ]
then
    usage_fatal
fi
_command="${1}"


if [ -z "${2:-}" ]
then
    usage_fatal
fi
_recipe="${2}"

bash ${recipes_path}/${recipe}
