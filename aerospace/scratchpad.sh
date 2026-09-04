#!/usr/bin/env bash
# i3-style scratchpad toggle — summon edition.
# Show: pull every window parked on the scratchpad workspace onto the focused
# workspace as floating windows (like i3 `scratchpad show`, no context switch).
# Hide: send them back to the scratchpad workspace.
# AeroSpace has no window marks, so "which windows did we summon" lives in a
# state file; entries for windows that got closed or moved are simply skipped.

set -euo pipefail

SCRATCH="S"
STATE="${TMPDIR:-/tmp}/aerospace-scratchpad-summoned"

focused="$(aerospace list-workspaces --focused)"

# On the scratchpad workspace itself there is nothing to summon; bounce back.
if [ "$focused" = "$SCRATCH" ]; then
  aerospace workspace-back-and-forth
  exit 0
fi

# Hide: previously summoned windows that are still open go back.
if [ -f "$STATE" ]; then
  while IFS= read -r id; do
    aerospace move-node-to-workspace --window-id "$id" "$SCRATCH" 2>/dev/null || true
  done < "$STATE"
  rm -f "$STATE"
  exit 0
fi

# Show: float every window parked on the scratchpad and bring it here.
# Float BEFORE moving so it never tiles into the current layout, even briefly.
ids="$(aerospace list-windows --workspace "$SCRATCH" --format '%{window-id}')"
[ -z "$ids" ] && exit 0  # empty scratchpad — i3 does nothing here too

while IFS= read -r id; do
  aerospace layout floating --window-id "$id" 2>/dev/null || true
  aerospace move-node-to-workspace --window-id "$id" "$focused" 2>/dev/null || continue
  printf '%s\n' "$id" >>"$STATE"
done <<<"$ids"

[ -f "$STATE" ] && aerospace focus --window-id "$(head -n1 "$STATE")"
