#!/usr/bin/env bash

# tarfiles.sh: part of deploy.sh.
# see https://github.com/pepaslabs/deploy.sh


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

color_scheme="${DEPLOYSH_COLOR_SCHEME:-"white_on_black"}"

echo_step_component="tarfiles.sh"


# import bash libs

source "${deploysh_lib_dir}/exit_codes.bash"
source "${deploysh_lib_dir}/bashx.bash"
source "${deploysh_lib_dir}/colors.bash"
source "${deploysh_lib_dir}/echo_step.bash"
source "${deploysh_lib_dir}/mktemp.bash"
source "${deploysh_lib_dir}/prompt.bash"


# volatiles: support for cleaning up mktemp files and dirs on exit automatically 

declare -a _volatiles

function add_volatile()
{
    # this is ridiculous, but works with 'set -u' on bash 3.2 and 4.3 (OS X 10.10 and Debian 8)
    # see http://stackoverflow.com/questions/7577052/bash-empty-array-expansion-with-set-u
    # see http://unix.stackexchange.com/questions/56837/how-to-test-if-a-variable-is-defined-at-all-in-bash-prior-to-version-4-2-with-th
    if [ -z "${_volatiles+1}" ]
    then
        _volatiles[0]="${1}"
    else
        _volatiles[${#_volatiles[@]}]="${1}"
    fi
}

function cleanup_volatiles()
{
    if [ -n "${_volatiles+1}" ]
    then
        local num_files=${#_volatiles[@]}
        if [ $num_files -gt 0 ]
        then
            for i in $(seq 0 $(( ${num_files} - 1 )))
            do
                local volatile="${_volatiles[$i]}"
                echo_step "Cleaning up ${color_yellow}${volatile}${color_off}."
                rm -rf "${volatile}"
            done
        fi
    fi
}

function cleanup_at_exit()
{
    echo_step_component="tarfiles.sh"
    cleanup_volatiles
}
trap cleanup_at_exit EXIT


# usage functions

function usage()
{
    cat << EOF
Usage: ${_script_name} {edit|pull|check|diff}
EOF
}

function usage_fatal()
{
    echo_step_error "Bad usage."
    echo2 $(usage)
    exit $tarfiles_err_bad_usage
}


# check usage

if [ -z "${1:-}" ]
then
    usage_fatal
fi
subcommand="${1}"


# main:

if [ "${subcommand}" == "edit" ]
then
    echo_step_component="tarfiles/edit"

    workdir=$(mktempdir)
    add_volatile "${workdir}"

    echo_step "Unpacking ${color_yellow}files.tar${color_off} into ${color_yellow}${workdir}${color_off}."
    files_fpath="$(pwd)/files.tar"
    cd "${workdir}"
    cat "${files_fpath}" | tar xv

    echo_step "Starting a ${color_yellow}subshell${color_off} in ${color_yellow}${workdir}${color_off}."
    echo_step "When finished making changes, Hit ${color_yellow}CTRL+d${color_off} to exit the subshell."

    bash -l || true

    if prompt_Yn "Save changes?"
    then
        echo_step "Repacking ${color_yellow}files.tar${color_off}."
        newtarball=$(mktempfile)
        add_volatile "${newtarball}"
        tar cf "${newtarball}" .
        cd - >/dev/null
        cp "${newtarball}" files.tar
        echo_step_ok "Changes saved."
    else
        echo_step_warning "Cancelling and ${color_red}discarding${color_off} changes."
        exit $tarfiles_err_user_cancelled
    fi

elif [ "${subcommand}" == "pull" ]
then
    echo_step_component="tarfiles/pull"

    echo_step_error "Subcommand '${color_yellow}pull${color_off}' Not implemented yet."

elif [ "${subcommand}" == "check" ]
then
    echo_step_component="tarfiles/check"

    echo_step_error "Subcommand '${color_yellow}check${color_off}' Not implemented yet."
elif [ "${subcommand}" == "diff" ]
then
    echo_step_component="tarfiles/diff"

    echo_step_error "Subcommand '${color_yellow}diff${color_off}' Not implemented yet."

    workdir=$(mktempdir)
    add_volatile "${workdir}"

    echo_step "Unpacking ${color_yellow}files.tar${color_off} into ${color_yellow}${workdir}${color_off}."
    files_fpath="$(pwd)/files.tar"
    cd "${workdir}"
    cat "${files_fpath}" | tar xv

#FIXME left off here.  this isn't working.  it tries to compare against all of /.
    diff -urN $( find . ) --to-file=/

else
    usage_fatal
fi
