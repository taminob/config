# .zprofile

if [ "$(tty)" = "/dev/tty1" ] ; then
    # environment variables
    export QT_QPA_PLATFORM=wayland
    export MOZ_ENABLE_WAYLAND=1
    export MOZ_WEBRENDER=1
    export MOZ_DBUS_REMOTE=1 # fix for "firefox is already running"
    export XDG_SESSION_TYPE=wayland
    export XDG_CURRENT_DESKTOP=sway
#	export XDG_CURRENT_DESKTOP=Unity # fix for functional tray
    export QT_QPA_PLATFORMTHEME=qt5ct
    export GTK_THEME=Breeze-Dark
    export GTK2_RC_FILES=$HOME/.gtkrc-2.0

#	export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock

    export $(gnome-keyring-daemon --start --components=ssh,secrets)

    exec sway
fi
