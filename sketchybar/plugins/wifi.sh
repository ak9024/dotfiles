#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

DEV=$(networksetup -listallhardwareports \
  | awk '/Hardware Port: Wi-Fi/{getline; print $2}')
DEV="${DEV:-en0}"

if ifconfig "$DEV" 2>/dev/null | grep -q 'status: active'; then
  # macOS 14+ gates SSID behind Location Services; blank is expected, not an error.
  SSID=$(networksetup -getairportnetwork "$DEV" 2>/dev/null \
    | sed -n 's/^Current Wi-Fi Network: //p')
  sketchybar --set "$NAME" \
    icon="󰖩" icon.color="$BLUE" label="${SSID:-Wi-Fi}"
else
  sketchybar --set "$NAME" \
    icon="󰖪" icon.color="$GREY" label="off"
fi
