#!/bin/bash

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

# portable mktemp calls (works with BSD or GNU mktemp, e.g. OS X or Linux)
# thanks to http://unix.stackexchange.com/a/84980

function mktempfile()
{
    mktemp 2>/dev/null || mktemp -t "${_script}"
}

function mktempdir()
{
    mktemp -d 2>/dev/null || mktemp -d -t "${_script}"
}

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
    local num_files=${#_volatiles[@]}
    if [ $num_files -gt 0 ]
    then
        for i in $(seq 0 $(( ${num_files} - 1 )))
        do
            local volatile="${_volatiles[$i]}"
            rm -rf "${volatile}"
        done
    fi
}

function cleanup_at_exit()
{
    cleanup_volatiles
    # extend this function as needed
}
trap cleanup_at_exit EXIT



# main:

workdir=$(mktempdir)
add_volatile "${workdir}"

echo "Unpacking files.tar in ${workdir}..."
files_fpath="$(pwd)/files.tar"
cd "${workdir}"
cat "${files_fpath}" | tar x

echo "Starting a subshell."
echo "To save your changes, type 'exit' or hit CTRL+d."
echo "To cancel (and discard changes), type 'exit 1'"
bash -l || (echo "Cancelling and discarding changes." && false)

echo "Repacking files.tar..."
newtarball=$(mktempfile)
add_volatile "${newtarball}"
tar cf "${newtarball}" .
cd - >/dev/null
cp "${newtarball}" files.tar
