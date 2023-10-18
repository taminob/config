#!/bin/sh

current_mode="$(makoctl mode)"

if [ "${1}" = "toggle" ]; then
	if [ "${current_mode}" = "default" ]; then
		makoctl mode -s do-not-disturb
	else
		makoctl mode -s default
	fi
else
	if [ "${current_mode}" = "default" ]; then
		echo '{"alt": "notifications_on"}'
	else
		echo '{"alt": "notifications_off"}'
	fi
fi
