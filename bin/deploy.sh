#!/usr/bin/env bash


# status codes:

err_bad_usage=2
err_no_recipes_path=3
err_no_such_recipe=4
err_no_such_subcommand=5


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


# deploy.sh-specific env

deploysh_base_dir="$( readlink -e "${_script_dir}/.." )"
deploysh_bin_dir="${deploysh_base_dir}/bin"
deploysh_lib_dir="${deploysh_base_dir}/lib/deploy.sh"
deploysh_etc_dir="${deploysh_base_dir}/etc/deploy.sh"

PATH="${deploysh_bin_dir}:${deploysh_lib_dir}:${PATH}"

recipesd_dir="${DEPLOYSH_RECIPESD_DIR:-${deploysh_etc_dir}/recipes.d}"


# make some env / functions available to the recipe scripts

export PATH deploysh_base_dir deploysh_bin_dir deploysh_lib_dir deploysh_etc_dir

source "${deploysh_lib_dir}/bashx.bash"
export -f bashx

source "${deploysh_lib_dir}/colors.bash"
export color_off color_none color_black color_red color_green color_yellow color_blue color_purple color_cyan color_white


# terminal output

function echo2()
{
    echo "${@}" >&2
}
export -f echo2

function echo_step_color()
{
    local color="${1}"
    shift
    echo -e "${color} * ${color_off}${@}"
}
export -f echo_step_color

function echo_step()
{
    echo_step_color "${color_cyan}" "${@}"
}
export -f echo_step

function echo_step_ok()
{
    echo -e "${color_green} * OK: ${color_off}${@}" >&2
}
export -f echo_step_ok

function echo_step_warning()
{
    echo -e "${color_yellow} * WARNING: ${color_off}${@}" >&2
}
export -f echo_step_warning

function echo_step_error()
{
    echo -e "${color_red} * ERROR: ${color_off}${@}" >&2
}
export -f echo_step_error


# usage functions

function usage()
{
    cat << EOF
Usage: ${_script_name} <subcommand> <recipe>
EOF
}

function usage_fatal()
{
    echo_step_error "Bad usage."
    echo2 $(usage)
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


# resolve the recipe location

function resolve_recipe_dir()
{
    find -L "${recipesd_dir}" -mindepth 2 -maxdepth 2 -type d -not -path '*/\.*'  -name "${recipe}" | head -n1
}

recipe_dir="$( resolve_recipe_dir )"
if [ ! -e "${recipe_dir}" ]
then
    echo_step_error "No such recipe: ${recipe}"
    exit $err_no_such_recipe
fi

echo_step "Selecting ${recipe_dir}"


# resolve the subcommand script

subcommand_fpath="${recipe_dir}/${subcommand}.sh"
if [ ! -e "${subcommand_fpath}" ]
then
    echo_step_error "No such subcommand: ${recipe}/${subcommand}.sh"
    exit $err_no_such_subcommand
fi


echo_step "Running ${recipe}/${subcommand}.sh"
bash -e -u -o pipefail "${subcommand_fpath}" || \
(
    exit_status=$?
    echo_step_error "${recipe}/${subcommand}.sh exited with status $exit_status"
    exit $exit_status
)

echo_step_ok "${recipe}/${subcommand}.sh succeeded."
