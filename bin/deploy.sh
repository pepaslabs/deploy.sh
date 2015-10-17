#!/usr/bin/env bash

# deploy.sh: configuration management, written in bash.
# see https://github.com/pepaslabs/deploy.sh

# env vars

# this script's behavior is modified by the following env vars:
#
# DEPLOYSH_RECIPESD_DIR
# * the location where deploy.sh looks for the recipes.d directory.
# * set to e.g. '$HOME/recipes.d'.
# * defaults to '$0/../etc/deploy.sh/recipes.d'
# * note: your repo of recipes should be symlinked into recipes.d.
#
# DEPLOYSH_COLOR_SCHEME
# * adjusts the color scheme to suit xterms with light or dark backgrounds.
# * set to one of: 'white_on_black', 'black_on_white', or 'no_color'.
# * defaults to 'white_on_black'.


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


# import bash libs

source "${deploysh_lib_dir}/exit_codes.bash"
source "${deploysh_lib_dir}/bashx.bash"

color_scheme="${DEPLOYSH_COLOR_SCHEME:-"white_on_black"}"
source "${deploysh_lib_dir}/colors.bash"


# terminal output functions

echo_step_component="deploy.sh"

function echo2()
{
    echo "${@}" >&2
}

function echo_step()
{
    echo_step_color "${color_cyan}" "${@}"
}

function echo_step_color()
{
    local color="${1}" ; shift
    echo -e "${color} * ${echo_step_component}: ${color_off}${@}"
}

function echo_step_ok()
{
    echo -e "${color_green} * OK (${echo_step_component}): ${color_off}${@}" >&2
}

function echo_step_warning()
{
    echo -e "${color_yellow} * WARNING (${echo_step_component}): ${color_off}${@}" >&2
}

function echo_step_error()
{
    echo -e "${color_red} * ERROR (${echo_step_component}): ${color_off}${@}" >&2
}


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
    exit $deploy_err_bad_usage
}


# check usage

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

function resolved_recipe_dir()
{
    find -L "${recipesd_dir}" -mindepth 2 -maxdepth 2 -type d -not -path '*/\.*' -name "${recipe}" | head -n1
}

recipe_dir="$( resolved_recipe_dir )"
if [ ! -e "${recipe_dir}" ]
then
    echo_step_error "No such recipe: ${color_yellow}${recipe}${color_off}"
    exit $deploy_err_no_such_recipe
fi
resolved_recipes_dir="$( basename "$( dirname "${recipe_dir}" )" )"

function recipes_dirs()
{
    find -L "${recipesd_dir}" -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*'
}

function nondefault_recipes_dirs()
{
    find -L "${recipesd_dir}" -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' -not -name 'zz_default_recipes'
}

printed_recipes_dir="${resolved_recipes_dir}/"
if [ "$( nondefault_recipes_dirs | wc -l )" -eq 1 ]
then
    # if the user has only installed one recipes dir in recipes.d, don't bother printing it.
    printed_recipes_dir=""
fi


# resolve the subcommand script

subcommand_fpath="${recipe_dir}/${subcommand}.sh"
if [ ! -e "${subcommand_fpath}" ]
then
    echo_step_error "No such subcommand: ${recipe}/${color_yellow}${subcommand}.sh${color_off}"
    exit $deploy_err_no_such_subcommand
fi


# make some env / functions available to other scripts

export PATH
export deploysh_base_dir deploysh_bin_dir deploysh_lib_dir deploysh_etc_dir
export -f bashx
export color_off color_none color_black color_red color_green color_yellow color_blue color_purple color_cyan color_white
export -f echo2 echo_step echo_step_color echo_step_ok echo_step_warning echo_step_error


# run the script

echo_step "Running ${printed_recipes_dir}${color_yellow}${recipe}${color_off}/${subcommand}.sh"
echo_step_component="${recipe}/${subcommand}" bash -e -u -o pipefail "${subcommand_fpath}" || \
(
    exit_status=$?
    echo_step_error "${printed_recipes_dir}${color_yellow}${recipe}${color_off}/${subcommand}.sh exited status $exit_status"
    exit $exit_status
)

echo_step_ok "${printed_recipes_dir}${color_yellow}${recipe}${color_off}/${subcommand}.sh succeeded."
