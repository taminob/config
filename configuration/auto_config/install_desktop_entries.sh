#!/bin/sh

set -e

SRCLOCATION=/home/me/sync/config/configuration/files/custom_desktop_entries
DESTLOCATION=/home/me/.local/share/applications
mkdir -pv $DESTLOCATION
ln -sivn $SRCLOCATION/* $DESTLOCATION

