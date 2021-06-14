# .zprofile

if [ "$(tty)" = "/dev/tty1" ] ; then
	# environment variables
	export QT_QPA_PLATFORM=wayland
	export GDK_BACKEND=wayland
	export SDL_VIDEODRIVER=wayland

	export XDG_SESSION_TYPE=wayland
	export XDG_CURRENT_DESKTOP=sway
#	export XDG_CURRENT_DESKTOP=Unity # fix for functional tray

	export MOZ_ENABLE_WAYLAND=1
	export MOZ_WEBRENDER=1
	export MOZ_DBUS_REMOTE=1 # fix for "firefox is already running"

	export QT_QPA_PLATFORMTHEME=qt5ct
	export GTK_THEME=Breeze-Dark
	export GTK2_RC_FILES=$HOME/.gtkrc-2.0
	export GTK_USE_PORTAL=1 # use qt file dialog for gtk applications

#	export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock # fix SWAYSOCK

	export $(gnome-keyring-daemon --start --components=ssh,secrets)

	echo "$(date): start sway" >> $HOME/.swaylog
	exec >> $HOME/.swaylog 2>&1
	exec sway
fi
