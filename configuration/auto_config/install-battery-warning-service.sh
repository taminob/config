#!/bin/sh

set -e

cp -v /home/me/sync/config/configuration/files/battery_warning.service /usr/lib/systemd/user/

# now service can be enabled using; do not execute as root! executed script is in user home:
#systemctl enable --user battery_warning

