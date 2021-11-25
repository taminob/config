#!/bin/sh

CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity)

STATUS=$(cat /sys/class/power_supply/BAT0/status)

BATTERY_LEVEL_WARNING=15
BATTERY_LEVEL_CRITICAL=5

if [ "$STATUS" = "Discharging" ]; then
	if [ "$CAPACITY" -le $BATTERY_LEVEL_CRITICAL ]; then
		/usr/bin/notify-send -u critical -a power_supply_low "Critical Battery" "Battery level is critical ($CAPACITY%)!"
	elif [ "$CAPACITY" -le $BATTERY_LEVEL_WARNING ]; then
		/usr/bin/notify-send -u normal -a power_supply_low "Low Battery" "Battery level is low ($CAPACITY%)."
	fi
fi

