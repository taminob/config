#!/bin/sh

HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
	HOSTNAME="$(uname -n)"
fi

PACKAGES_LISTS_PATH=$(dirname $0)

for file_name in "$PACKAGES_LISTS_PATH"/*_packages; do
	cat "$file_name"
done

cat "$PACKAGES_LISTS_PATH""/""$HOSTNAME""_packages_"
