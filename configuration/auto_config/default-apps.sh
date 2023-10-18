#!/bin/sh

# check current with e.g.:
# xdg-mime query default text/plain

# default file manager
xdg-mime default ranger.desktop inode/directory
xdg-mime default nvim.desktop text/plain

