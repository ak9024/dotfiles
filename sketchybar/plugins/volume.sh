#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# One osascript for both fields. Two separate calls cost ~306ms; this is ~147ms,
# and osascript startup dominates either way, so the $INFO fast path bought
# nothing once `output muted` still had to be queried.
read -r VOL MUTED <<<"$(osascript \
  -e 'set v to (get volume settings)' \
  -e '(output volume of v as text) & " " & (output muted of v as text)' 2>/dev/null)"

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
