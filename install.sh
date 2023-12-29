#!/bin/sh

set -e

HOSTNAME="$1"
if [ -z "$HOSTNAME" ]; then
	HOSTNAME="$(uname -n)"
fi
CONFIGLOCATION="$HOME/sync/config"
DESTCONFIGLOCATION="$HOME/.config"
DESTHOMELOCATION="$HOME"

create_config_path()
{
	config_path="$1"
	mkdir -p "$config_path"
}

install_config()
{
	source_path="$1"
	dest_path="$2"
	create_dir=$3
	if [ create_dir ]; then
		create_config_path "$(dirname "$dest_path")"
	fi
	ln -sivn "$source_path" "$dest_path" || echo "Installation skipped"
}

checkifcontinue()
{
	read -p "$1 (y/N)" CONTINUE
	if [ "$CONTINUE" = "y" -o "$CONTINUE" = "Y" ]; then
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

if ! checkifcontinue 'If username is not "me", make sure to run (in config location): find . -type f -exec sed -i "s/\/home\/me/\/home\/$USERNAME/" {} +'; then
	exit
fi

if ! checkifcontinue 'If config location is not /sync/config, make sure to run (in config location): find . -type f -exec sed -i "s/\/sync\/config/\/path\/to\/config/" {} +'; then
	exit
fi

if checkifcontinue "Apply configuration to $DESTCONFIGLOCATION?"; then
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

	install_config "$CONFIGLOCATION/.clang-format" "$DESTHOMELOCATION/.clang-format"
	install_config "$CONFIGLOCATION/.clang-tidy" "$DESTHOMELOCATION/.clang-tidy"

	install_config "$CONFIGLOCATION/gnupg/gpg-agent.conf" "$DESTHOMELOCATION/.gnupg/gpg-agent.conf" true
	install_config "$CONFIGLOCATION/gnupg/gpg.conf" "$DESTHOMELOCATION/.gnupg/gpg.conf"

	install_config "$CONFIGLOCATION/ssh/config" "$DESTHOMELOCATION/.ssh/config" true
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

if checkifcontinue "Install custom packages?"; then
	packages/install_custom.sh
fi

if checkifcontinue "Change default shell to zsh?"; then
	chsh -s /usr/bin/zsh
fi

if checkifcontinue "Create ~/sync, ~/software/tests, ~/downloads, ~/videos/screen_recordings, ~/pictures/screenshots directories?"; then
	mkdir -pv "$HOME/sync"
	mkdir -pv "$HOME/software/tests"
	mkdir -pv "$HOME/downloads"
	mkdir -pv "$HOME/videos/screen_recordings"
	mkdir -pv "$HOME/pictures/screenshots"
fi

if checkifcontinue "Create ~/arch and ~/tests symlinks?"; then
	ln -sivn "$HOME/software/tests" "$HOME/tests"
	ln -sivn "$HOME/sync/arch" "$HOME/arch"
fi

echo "Configuration installed! Manual tweaks might be required depending on the system. See $CONFIGLOCATION/configuration for scripts/guides."

