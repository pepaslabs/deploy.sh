#!/usr/bin/env bash

pkd="${1}"

pip list \
| sed 's/ (.*//' \
| grep --quiet "^${pkg}$"

exit $?
