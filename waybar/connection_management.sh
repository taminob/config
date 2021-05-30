#!/bin/sh

NETWORK_WINDOW_NAME="nm_tui_win"

focus_network_window()
{
	swaymsg '[title='"$NETWORK_WINDOW_NAME"'] focus'
}

NETWORK_TOOL="nmtui"

if type $NETWORK_TOOL && ! focus_network_window; then
	# start terminal with network_tool async and switch back to previous workspace after quit
	(alacritty -t "$NETWORK_WINDOW_NAME" -e "$NETWORK_TOOL" && swaymsg 'workspace back_and_forth') &
	sleep 0.5
	focus_network_window
fi

