#!/usr/bin/env bash

pkg="${1}"

dpkg-query --show --showformat='${Package} ${Status}\n' \
| grep "install ok installed" \
| awk '{ print $1 }' \
| grep --quiet "^${pkg}$"

exit $?
