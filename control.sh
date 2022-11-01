#!/bin/bash

# Copyright 2022 Mark Jaquith
# License: MIT

###############################################################################
# CONFIGURATION
###############################################################################

# Light configuration.
# ===================
LIGHT_IPS=(192.168.1.135) # Separate multiple IPs with spaces.
LIGHT_MIN=0 # Cannot be less than 0.
LIGHT_MAX=100 # Cannot be greater than 100.
LIGHT_INCREMENT=2
LIGHT_TEMPERATURE=200 # 143-344... where 143 is cool (7000K) and 344 is warm (2700K)

# Strip configuration.
# ====================
STRIP_IPS=(192.168.1.140) # Separate multiple IPs with spaces.
STRIP_MIN=0 # Cannot be less than 0.
STRIP_MAX=100 # Cannot be greater than 100.
STRIP_HUE=39
STRIP_SATURATION=15
#STRIP_BRIGHTNESS=100 # Hardcode the brightness... OR:
STRIP_PERCENTAGE_OF_LIGHT=800 # Set it to a percentage of the main light.
###############################################################################

# Get the current script dir.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Default to on.
ON=1

# Get the main light ip.
LIGHT_IP=${LIGHT_IPS[0]}

# Read the last set brightness.
BRIGHTNESS=$(<"$SCRIPT_DIR"/brightness.txt)

# Constrain the brightness to the range 0–100.
BRIGHTNESS=$(( BRIGHTNESS < LIGHT_MIN ? LIGHT_MIN : BRIGHTNESS ))
BRIGHTNESS=$(( BRIGHTNESS > LIGHT_MAX ? LIGHT_MAX : BRIGHTNESS ))

# If the first argument is not "up", "down", "on", "off", or "toggle" exit with error.
if [[ "$1" != "up" && "$1" != "down" && "$1" != "on" && "$1" != "off" && "$1" != "toggle" ]]; then
		echo "Usage: $0 [up|down|on|off]"
		exit 1
fi

# Add increment to the old bringhtness if the first argument is "up".
if [[ "$1" == "up" ]]; then
	BRIGHTNESS=$((BRIGHTNESS+LIGHT_INCREMENT))
fi

# Subtract increment from the old bringhtness if the first argument is "down".
if [[ "$1" == "down" ]]; then
	BRIGHTNESS=$((BRIGHTNESS-LIGHT_INCREMENT))
fi

# Turn on the light if the first argument is "on".
if [[ "$1" == "on" ]]; then
	ON=1
fi

# Turn off the light if the first argument is "off".
if [[ "$1" == "off" ]]; then
	ON=0
fi

# If the first argument is "toggle", fetch the current status of the light and flip it.
if [[ "$1" == "toggle" ]]; then
	ON=$(curl --silent --header "Content-Type: application/json" --request GET http://"$LIGHT_IP":9123/elgato/lights | grep -oE '"on": ?\d' | grep -oE '\d')
	if [[ "$ON" == "1" ]]; then
		ON=0
	else
		ON=1
	fi
fi

# Constrain the brightness to the range 0–100.
BRIGHTNESS=$(( BRIGHTNESS < LIGHT_MIN ? LIGHT_MIN : BRIGHTNESS ))
BRIGHTNESS=$(( BRIGHTNESS > LIGHT_MAX ? LIGHT_MAX : BRIGHTNESS ))

# If strip brightness was hardcoded, use that, else base it off of the main brightness
if [[ -z "$STRIP_BRIGHTNESS" ]]; then
	STRIP_BRIGHTNESS=$(( BRIGHTNESS * STRIP_PERCENTAGE_OF_LIGHT / 100 ))
fi

# Constrain the strip brightness to the range 0–100.
STRIP_BRIGHTNESS=$(( STRIP_BRIGHTNESS < STRIP_MIN ? STRIP_MIN : STRIP_BRIGHTNESS ))
STRIP_BRIGHTNESS=$(( STRIP_BRIGHTNESS > STRIP_MAX ? STRIP_MAX : STRIP_BRIGHTNESS ))
STRIP_BRIGHTNESS = echo $STRIP_BRIGHTNESS | awk '{print int($1+0.5)}'

# Update the brightness value on disk. We cache it locally so we don't have to wait for the server response when we increment or decrement.
echo $BRIGHTNESS > "$SCRIPT_DIR"/brightness.txt

# Adjust the lights.
for ip in "${LIGHT_IPS[@]}"; do
	curl --silent --header "Content-Type: application/json" --request PUT --data '{"lights":[{"on":'"$ON"',"brightness":'"$BRIGHTNESS"',"temperature":'"$LIGHT_TEMPERATURE"'}],"numberOfLights":1}' http://"$ip":9123/elgato/lights
done

# Adjust the strips.
for ip in "${STRIP_IPS[@]}"; do
	curl --silent --header "Content-Type: application/json" --request PUT --data '{"lights":[{"on":'"$ON"',"brightness":'"$STRIP_BRIGHTNESS"',"hue":'"$STRIP_HUE"',"saturation":'"$STRIP_SATURATION"'}],"numberOfLights":1}' http://"$ip":9123/elgato/lights
done

if [[ "$ON" == "1" ]]; then
	ON_TEXT="on"
else
	ON_TEXT="off"
fi
echo "$ON_TEXT ($BRIGHTNESS)"