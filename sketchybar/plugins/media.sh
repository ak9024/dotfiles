#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# media_change delivers a JSON payload in $INFO. There is no way to query the
# current track on demand, so an empty payload means "nothing playing" and the
# item hides rather than showing a stale track.
STATE=$(echo "$INFO" | jq -r '.state' 2>/dev/null)

if [ "$STATE" != "playing" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

TITLE=$(echo "$INFO" | jq -r '.title // empty' 2>/dev/null)
ARTIST=$(echo "$INFO" | jq -r '.artist // empty' 2>/dev/null)

[ -z "$TITLE" ] && { sketchybar --set "$NAME" drawing=off; exit 0; }

LABEL="$TITLE"
[ -n "$ARTIST" ] && LABEL="$TITLE — $ARTIST"
# Long track names would push the workspaces off-screen.
[ ${#LABEL} -gt 40 ] && LABEL="${LABEL:0:39}…"

sketchybar --set "$NAME" drawing=on icon="󰎈" icon.color="$MAGENTA" label="$LABEL"
