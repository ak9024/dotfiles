#!/usr/bin/env bash

# Repaints every workspace item in one pass.
#
# This used to be a per-item script: 11 items x (bash + `aerospace
# list-windows --workspace N` + `sketchybar --set`) on every app switch, ~140ms.
# Two queries and one batched --set cover the same ground in ~25ms.

source "$CONFIG_DIR/colors.sh"

# Events carry the focused workspace; timer ticks and system_woke do not.
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

# Space-delimited set of workspaces holding at least one window, padded on both
# ends so a substring test cannot match "1" inside "10".
OCCUPIED=" $(aerospace list-windows --all --format '%{workspace}' 2>/dev/null \
  | awk '!seen[$0]++' | tr '\n' ' ')"

# persistent-workspaces in aerospace.toml makes this list static for the life of
# the bar, and the script runs on a 5s timer. Probe once, then read the cache.
CACHE="${TMPDIR:-/tmp}/sketchybar_aerospace_workspaces"
WORKSPACES=$(cat "$CACHE" 2>/dev/null)
if [ -z "$WORKSPACES" ]; then
  WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null)
  [ -n "$WORKSPACES" ] && printf '%s' "$WORKSPACES" >"$CACHE"
fi

ARGS=()
for sid in $WORKSPACES; do
  if [ "$sid" = "$FOCUSED" ]; then
    ARGS+=(--set space."$sid" drawing=on background.drawing=on icon.color="$WHITE")
  elif [[ "$OCCUPIED" == *" $sid "* ]]; then
    ARGS+=(--set space."$sid" drawing=on background.drawing=off icon.color="$GREY")
  else
    # i3 behavior: empty, unfocused workspace is not drawn at all.
    # Clear the highlight too, else it flashes stale on the next reveal.
    ARGS+=(--set space."$sid" drawing=off background.drawing=off)
  fi
done

[ ${#ARGS[@]} -gt 0 ] && sketchybar "${ARGS[@]}"
