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

# path introspection on this script
# thanks to https://github.com/kvz/bash3boilerplate/blob/master/main.sh

# _script_path: canonicalized full path to this script
_script_path="$( readlink -e "${BASH_SOURCE[0]}")"

# _script_name: the name of this script
_script_name="$(basename "${_script_path}")"

# _script_dir: the directory which this script resides in
_script_dir="$(dirname "${_script_path}")"

deploysh_base_dir="$( readlink -e "${_script_dir}/.." )"
export deploysh_base_dir

deploysh_bin_dir="${deploysh_base_dir}/bin"
export deploysh_bin_dir

deploysh_lib_dir="${deploysh_base_dir}/lib/deploy.sh"
export deploysh_lib_dir

export PATH="${deploysh_bin_dir}:${deploysh_lib_dir}:${PATH}"

source "${deploysh_lib_dir}/bashx.bash"
export -f bashx

recipes_dir="${deploysh_base_dir}/recipes"
recipes_dir="${DEPLOYSH_RECIPES_DIR:-${recipes_dir}}"

function usage()
{
    cat << EOF
Usage: ${_script_name} {install|remove} <recipe>
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
subcommand="${1}"

if [ -z "${2:-}" ]
then
    usage_fatal
fi
recipe="${2}"

if [ "${subcommand}" == "install" ]
then
    recipe_script_path="${recipes_path}/${recipe}/install.sh"
    if [ ! -e "${recipe_script_path}" ]
    then
        recipe_script_path="${deploysh_lib_dir}/default_recipes/${recipe}/install.sh"
        if [ ! -e "${recipe_script_path}" ]
        then
            echo "ERROR: couldn't find recipe: ${recipe}" >&2
            exit 1
        fi
    fi

    echo "Running ${recipe_script_path}"
    bash -e -u -o pipefail "${recipe_script_path}"
fi
