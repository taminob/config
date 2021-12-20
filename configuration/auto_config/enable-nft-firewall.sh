#!/bin/sh

set -e
set -v

cp -v /home/me/sync/config/configuration/files/nftables.conf /etc/nftables.conf
systemctl enable nftables.service
