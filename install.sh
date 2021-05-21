#!/bin/sh

HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
	HOSTNAME="$(uname -n)"
fi
CONFIGLOCATION="$HOME/sync/config"
DESTLOCATION="$HOME/.config"

checkifcontinue()
{
	read -p "$1" CONTINUE
	if [ ! -z "$CONTINUE" -a "$CONTINUE" != "y" -a "$CONTINUE" != "Y" ]; then
		echo "Installation aborted!"
		exit
	fi
}

#checkifcontinue "Continue installation of packages?"
#sudo pacman -S $(cat "$CONFIGLOCATION/packages") 

checkifcontinue "Continue installation of configuration: $HOSTNAME? (Y/n)"
mkdir "$DESTLOCATION/sway"
ln -sivn "$CONFIGLOCATION/sway/$HOSTNAME.conf" "$DESTLOCATION/sway/config"

mkdir "$DESTLOCATION/mako"
ln -sivn "$CONFIGLOCATION/mako/$HOSTNAME.conf" "$DESTLOCATION/mako/config"

ln -sivn "$CONFIGLOCATION/waybar" "$DESTLOCATION/waybar"

ln -sivn "$CONFIGLOCATION/wofi" "$DESTLOCATION/wofi"

ln -sivn "$CONFIGLOCATION/alacritty" "$DESTLOCATION/alacritty"

ln -sivn "$CONFIGLOCATION/nvim" "$DESTLOCATION/nvim"

mkdir -p "$DESTLOCATION/Code - OSS/User/"
ln -sivn "$CONFIGLOCATION/code/settings.json" "$DESTLOCATION/Code - OSS/User/settings.json"

ln -sivn "$CONFIGLOCATION/.bash_profile" "$HOME/.bash_profile"
ln -sivn "$CONFIGLOCATION/.bashrc" "$HOME/.bashrc"

ln -sivn "$CONFIGLOCATION/.zshrc" "$HOME/.zshrc"
ln -sivn "$CONFIGLOCATION/.zshenv" "$HOME/.zshenv"
ln -sivn "$CONFIGLOCATION/.zprofile" "$HOME/.zprofile"

ln -sivn "$CONFIGLOCATION/.gitconfig" "$HOME/.gitconfig"
ln -sivn "$CONFIGLOCATION/.tmux.conf" "$HOME/.tmux.conf"
ln -sivn "$CONFIGLOCATION/.nanorc" "$HOME/.nanorc"

echo "Configuration installed!"
