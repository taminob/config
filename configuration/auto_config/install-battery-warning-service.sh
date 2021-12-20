#!/bin/sh

set -e

cp -v /home/me/sync/config/configuration/scripts/battery_warning.sh /opt/bin/
cp -v /home/me/sync/config/configuration/files/battery_warning.timer /usr/lib/systemd/user/
cp -v /home/me/sync/config/configuration/files/battery_warning.service /usr/lib/systemd/user/

echo "now service can be enabled using (do not execute as root):"
echo "systemctl enable --user battery_warning.timer"

