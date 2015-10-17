#!/usr/bin/env bash

# path introspection on this script
# thanks to https://github.com/kvz/bash3boilerplate/blob/master/main.sh

# _script_path: canonicalized full path to this script
_script_path="$( readlink -e "${BASH_SOURCE[0]}")"

# _script_name: the name of this script
_script_name="$(basename "${_script_path}")"

echo_step_error "${color_yellow}${_script_name}${color_off} is not implemented yet"

source "${deploysh_lib_dir}/exit_codes.bash"
exit $needs_not_implemented_yet
