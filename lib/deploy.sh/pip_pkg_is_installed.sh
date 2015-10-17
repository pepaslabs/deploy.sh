#!/usr/bin/env bash

# turns out this is slow enough that it isn't worth using as a pre-install check.

pkd="${1}"

pip list \
| sed 's/ (.*//' \
| grep --quiet "^${pkg}$"

exit $?
