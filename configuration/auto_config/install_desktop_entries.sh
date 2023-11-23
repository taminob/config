#!/bin/sh

set -e

SRCLOCATION=/home/me/sync/config/configuration/files/custom_desktop_entries
DESTLOCATION=/home/me/.local/share/applications
mkdir -pv $DESTLOCATION
for entry in "${SRCLOCATION}"/*; do
	ln -sivn "${entry}" "${DESTLOCATION}" || echo "Installation skipped!"
done
