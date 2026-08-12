#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"

SID="$1"

# Event may not carry the var (e.g. on initial --update), so fall back to a query.
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

# One icon per distinct app on this workspace, in the font's ligature form.
ICONS=""
while read -r app; do
  [ -z "$app" ] && continue
  __icon_map "$app"
  ICONS+="$icon_result"
done < <(aerospace list-windows --workspace "$SID" --format '%{app-name}' 2>/dev/null | awk '!seen[$0]++')

if [ "$SID" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    background.drawing=on \
    icon.color="$WHITE" \
    label="$ICONS"
elif [ -n "$ICONS" ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    background.drawing=off \
    icon.color="$GREY" \
    label="$ICONS"
else
  # i3 behavior: empty, unfocused workspace is not drawn at all.
  # Clear the highlight too, else it flashes stale on the next reveal.
  sketchybar --set "$NAME" drawing=off background.drawing=off
fi
