# .zprofile

function export_environment_variables() {
	# environment variables
	export QT_QPA_PLATFORM=wayland # force X11: xcb
	export GDK_BACKEND="wayland,x11"
#	export SDL_VIDEODRIVER=wayland # force X11: x11
#	export CLUTTER_BACKEND=wayland

	export XDG_SESSION_TYPE=wayland
	export XDG_CURRENT_DESKTOP=sway
#	export XDG_CURRENT_DESKTOP=Unity # fix for functional tray

	export MOZ_ENABLE_WAYLAND=1
	export MOZ_WEBRENDER=1
	export MOZ_DBUS_REMOTE=1 # fix for "firefox is already running"

	export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
	export QT_QPA_PLATFORMTHEME=qt5ct
	export GTK_THEME=Breeze-Dark
	export GTK2_RC_FILES=$HOME/.gtkrc-2.0
#	export GTK_USE_PORTAL=1 # use qt file dialog for gtk applications
	export _JAVA_AWT_WM_NONREPARENTING=1

	# chinese pinyin input method
	export GTK_IM_MODULE=fcitx
	export QT_IM_MODULE=fcitx
	export XMODIFIERS=@im=fcitx
}

function setup_logging() {
	LOGS_DIRECTORY="${HOME}/.logs"
	mkdir -p "${LOGS_DIRECTORY}"
	SWAY_LOGS_DIRECTORY="${LOGS_DIRECTORY}/sway"
	mkdir -p "${SWAY_LOGS_DIRECTORY}"
	NEXTCLOUD_LOGS_DIRECTORY="${LOGS_DIRECTORY}/nextcloud"
	mkdir -p "${NEXTCLOUD_LOGS_DIRECTORY}"

	export CURRENT_SESSION_LOG_FILE="$(date +'%Y-%m-%d_%H-%M-%S')"
}

function start_services() {
	export $(gnome-keyring-daemon --start --components=ssh,secrets)
}

function start_sway() {
	CURRENT_SWAYLOG_FILE="${SWAY_LOGS_DIRECTORY}/${CURRENT_SESSION_LOG_FILE}"
	echo "$(date): start sway" >> "${CURRENT_SWAYLOG_FILE}"
	exec >> "${CURRENT_SWAYLOG_FILE}" 2>&1
	exec sway

	# use this command to fix SWAYSOCK environment variable after sway startup
#	export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep --exact --newest sway).sock
}

function start_desktop() {
	export_environment_variables
	setup_logging
	start_services
	start_sway
}

if [ "$(tty)" = "/dev/tty1" ] ; then
	start_desktop
fi
