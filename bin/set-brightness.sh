#!/bin/bash
# MAX: 48000
DISPLAY_BRIGHTNESS="$1"

echo "$DISPLAY_BRIGHTNESS" > /sys/class/backlight/intel_backlight/brightness

