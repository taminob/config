#!/bin/sh

SRCLOCATION=/home/me/sync/config/configuration/custom_desktop_entries
DESTLOCATION=/home/me/.local/share/applications
mkdir -pv $DESTLOCATION
ln -sivn $SRCLOCATION/* $DESTLOCATION

