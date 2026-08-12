#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# volume_change passes the level in $INFO; fall back to a query on forced updates.
VOL="$INFO"
if ! [[ "$VOL" =~ ^[0-9]+$ ]]; then
  VOL=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
fi
MUTED=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)

[[ "$VOL" =~ ^[0-9]+$ ]] || exit 0

if [ "$MUTED" = "true" ] || [ "$VOL" -eq 0 ]; then
  ICON="󰖁"
  COLOR="$GREY"
else
  case "$VOL" in
    100|9[0-9]|8[0-9]|7[0-9]|6[0-9]) ICON="󰕾" ;;
    5[0-9]|4[0-9]|3[0-9]) ICON="󰖀" ;;
    *) ICON="󰕿" ;;
  esac
  COLOR="$WHITE"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${VOL}%"
