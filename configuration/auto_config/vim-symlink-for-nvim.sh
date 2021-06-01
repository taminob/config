#!/bin/sh

echo "WARNING: this will break install for vim if not installed already!"
echo "Delete the created symlink /usr/bin/vim to fix this."

SRC_PATH=/usr/bin/nvim
DEST_PATH=/usr/bin/vim
SAVE_PATH=/usr/bin/viim

if [ -f $DEST_PATH ]; then
	sudo mv $DEST_PATH $SAVE_PATH
fi
sudo ln -sfvn $SRC_PATH $DEST_PATH
