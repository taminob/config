#!/bin/sh

set -e

sudo systemctl enable --now tlp
sudo systemctl enable --now tlp-sleep.service
sudo systemctl enable NetworkManager-dispatcher.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
