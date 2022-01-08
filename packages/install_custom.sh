#!/bin/sh

set -e

PACKAGES_GIT_DIR=/tmp/arch-packages

i=""
while [ -e "$PACKAGES_GIT_DIR"$i ]; do
	i=`expr $i + 1`
done
PACKAGES_GIT_DIR="$PACKAGES_GIT_DIR"$i

git clone https://github.com/taminob/arch-packages "$PACKAGES_GIT_DIR"
cd "$PACKAGES_GIT_DIR"

for x in *; do
	if [ -d $x ]; then
		cd $x
		makepkg -si
		cd ..
	fi
done
