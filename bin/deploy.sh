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

color_scheme="${DEPLOYSH_COLOR_SCHEME:-"white_on_black"}"

echo_step_component="deploy.sh"


# import bash libs

source "${deploysh_lib_dir}/exit_codes.bash"
source "${deploysh_lib_dir}/bashx.bash"
source "${deploysh_lib_dir}/colors.bash"
source "${deploysh_lib_dir}/echo_step.bash"
source "${deploysh_lib_dir}/conditionals.bash"
source "${deploysh_lib_dir}/or_die.bash"


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
    echo_step_error "No such recipe: ${color_yellow}${recipe}${color_off}."
    exit $deploy_err_no_such_recipe
fi
resolved_recipes_dir="$( basename "$( dirname "${recipe_dir}" )" )"

function recipes_dirs()
{
    find -L "${recipesd_dir}" \
    -mindepth 1 -maxdepth 1 -type d \
    -not -path '*/\.*'
}

function nondefault_recipes_dirs()
{
    find -L "${recipesd_dir}" \
    -mindepth 1 -maxdepth 1 -type d \
    -not -path '*/\.*' \
    -not -name 'zz_default_recipes' \
    -not -name 'zzz_test_recipes'
}

printed_recipes_dir=""
if [ "${resolved_recipes_dir}" == "zz_default_recipes" \
     -o "${resolved_recipes_dir}" == "zzz_test_recipes" \
     -o "$( nondefault_recipes_dirs | wc -l )" -gt 1 ]
then
    # if the user has installed more than one recipes dir in recipes.d,
    # of if the user is running a default or test recipe, print the recipes dir.
    printed_recipes_dir="${resolved_recipes_dir}/"
fi


# resolve the subcommand script

subcommand_fpath="${recipe_dir}/${subcommand}.sh"
if [ ! -e "${subcommand_fpath}" ]
then
    echo_step_error "No such subcommand: ${recipe}/${color_yellow}${subcommand}.sh${color_off}."
    exit $deploy_err_no_such_subcommand
fi


# make some env / functions available to other scripts

export PATH
export deploysh_base_dir deploysh_bin_dir deploysh_lib_dir deploysh_etc_dir
export -f bashx
export color_off color_none color_black color_red color_green color_yellow \
color_blue color_purple color_cyan color_white
export -f echo2 echo_step echo_step_color echo_step_ok echo_step_warning \
echo_step_error
export -f is_root is_user is_linux is_darwin is_debian has_cmd files_differ \
is_arm is_nslu2 is_olpc_xo1 is_pogoplug_v4 is_virtualbox
export -f die_x_for_y_only die_recipe_for_x_only root_or_die user_or_die \
linux_or_die darwin_or_die debian_or_die


# run the script

echo_step "Running ${printed_recipes_dir}${color_yellow}${recipe}${color_off}/${subcommand}.sh."
cd "${recipe_dir}"
bash_opts="-eu -o pipefail"
echo_step_component="${recipe}/${subcommand}" bashx ${bash_opts} "${subcommand_fpath}" || \
(
    exit_status=$?
    echo_step_error "${printed_recipes_dir}${color_yellow}${recipe}${color_off}/${subcommand}.sh exited status $exit_status."
    exit $exit_status
)

echo_step_ok "${printed_recipes_dir}${color_yellow}${recipe}${color_off}/${subcommand}.sh succeeded."
