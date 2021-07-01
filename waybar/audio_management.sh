#!/bin/sh

AUDIO_MGMT_ID="pavucontrol"

focus_audio_mgmt()
{
	swaymsg '[app_id='"$AUDIO_MGMT_ID"'] focus'
}

AUDIO_TOOL="$AUDIO_MGMT_ID"

if type $AUDIO_TOOL && ! focus_audio_mgmt; then
	# audio tool async and switch back to previous workspace after quit
	($AUDIO_TOOL && swaymsg 'workspace back_and_forth') &
	sleep 0.5
	focus_audio_mgmt
fi

