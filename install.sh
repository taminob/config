#!/bin/sh

HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
	HOSTNAME="$(uname -n)"
fi
CONFIGLOCATION="$HOME/sync/config"
DESTCONFIGLOCATION="$HOME/.config"
DESTHOMELOCATION="$DESTHOMELOCATION"

create_config_path()
{
	config_path=$1
	mkdir -p config_path
}

install_config()
{
	source_path="$1"
	dest_path="$2"
	create_dir=$3
	if [ create_dir ]; then
		create_config_path $(dirname $dest_path)
	fi
	ln -sivn "$source_path" "$dest_path"
}

checkifcontinue()
{
	read -p "$1 (y/N)" CONTINUE
	if [ "$CONTINUE" == "y" -o "$CONTINUE" == "Y" ]; then
		true
	elif [ -z "$CONTINUE" -o "$CONTINUE" != "n" -o "$CONTINUE" != "N" ]; then
		false
	else
		echo "Installation aborted!"
		exit
	fi
}

if ! checkifcontinue "Continue installation for: $HOSTNAME?"; then
	exit
fi

if checkifcontinue "Apply configuration to $CONFIGLOCATION?"; then
	install_config "$CONFIGLOCATION/sway/$HOSTNAME.conf" "$DESTCONFIGLOCATION/sway/config" true

	install_config "$CONFIGLOCATION/mako/$HOSTNAME.conf" "$DESTCONFIGLOCATION/mako/config" true

	install_config "$CONFIGLOCATION/waybar" "$DESTCONFIGLOCATION/waybar"

	install_config "$CONFIGLOCATION/wofi" "$DESTCONFIGLOCATION/wofi"

	install_config "$CONFIGLOCATION/alacritty" "$DESTCONFIGLOCATION/alacritty"

	install_config "$CONFIGLOCATION/nvim" "$DESTCONFIGLOCATION/nvim"

	install_config "$CONFIGLOCATION/ranger" "$DESTCONFIGLOCATION/ranger"

	install_config "$CONFIGLOCATION/code/settings.json" "$DESTCONFIGLOCATION/Code - OSS/User/settings.json" true
fi

if checkifcontinue "Apply configuration to $DESTHOMELOCATION?"; then
	install_config "$CONFIGLOCATION/.bash_profile" "$DESTHOMELOCATION/.bash_profile"
	install_config "$CONFIGLOCATION/.bashrc" "$DESTHOMELOCATION/.bashrc"

	install_config "$CONFIGLOCATION/.zshrc" "$DESTHOMELOCATION/.zshrc"
	install_config "$CONFIGLOCATION/.zshenv" "$DESTHOMELOCATION/.zshenv"
	install_config "$CONFIGLOCATION/.zprofile" "$DESTHOMELOCATION/.zprofile"

	install_config "$CONFIGLOCATION/.gitconfig" "$DESTHOMELOCATION/.gitconfig"
	install_config "$CONFIGLOCATION/.tmux.conf" "$DESTHOMELOCATION/.tmux.conf"
	install_config "$CONFIGLOCATION/.nanorc" "$DESTHOMELOCATION/.nanorc"
fi

AUR_HELPER="yay"
AUR_BUILD_PATH="/tmp/$AUR_HELPER"
if checkifcontinue "Install AUR helper ($AUR_HELPER)?"; then
	mkdir -p "$AUR_BUILD_PATH" && cd "$AUR_BUILD_PATH" && git clone "https://aur.archlinux.org/$AUR_HELPER.git" "$AUR_BUILD_PATH" && makepkg -si
fi

PACKAGE_LIST_LOCATION="$CONFIGLOCATION/packages"
if checkifcontinue "Inspect package diff?"; then
	python "$PACKAGE_LIST_LOCATION/packages_diff.py"
fi

if checkifcontinue "Install packages?"; then
	sudo pacman -S --needed $("$PACKAGE_LIST_LOCATION/packages.sh")
fi

if checkifcontinue "Install aur packages?"; then
	$AUR_HELPER -S --needed $(cat "$PACKAGE_LIST_LOCATION/aur_packages_")
fi

echo "Configuration installed! Manual tweaks might be required depending on the system. See $CONFIGLOCATION/configuration for scripts/guides."

