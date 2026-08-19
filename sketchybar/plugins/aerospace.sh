#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

SID="$1"

# Event may not carry the var (e.g. on initial --update), so fall back to a query.
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

WINDOWS=$(aerospace list-windows --workspace "$SID" --format '%{window-id}' 2>/dev/null | grep -c .)

if [ "$SID" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    background.drawing=on \
    icon.color="$WHITE"
elif [ "$WINDOWS" -gt 0 ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    background.drawing=off \
    icon.color="$GREY"
else
  # i3 behavior: empty, unfocused workspace is not drawn at all.
  # Clear the highlight too, else it flashes stale on the next reveal.
  sketchybar --set "$NAME" drawing=off background.drawing=off
fi
