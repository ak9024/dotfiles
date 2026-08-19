#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# The Wi-Fi device name never changes at runtime, but this script runs every
# 30s. Probe once, then read the cache.
CACHE="${TMPDIR:-/tmp}/sketchybar_wifi_device"
DEV=$(cat "$CACHE" 2>/dev/null)
if [ -z "$DEV" ]; then
  DEV=$(networksetup -listallhardwareports \
    | awk '/Hardware Port: Wi-Fi/{getline; print $2}')
  DEV="${DEV:-en0}"
  printf '%s' "$DEV" >"$CACHE"
fi

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
