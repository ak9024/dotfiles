#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# netstat reports cumulative counters, so a rate needs the previous sample.
# The default route can move (Wi-Fi to Ethernet, VPN up), hence the device is
# re-read each tick and cached alongside the counters — a device change makes
# the stored deltas meaningless and has to reset them.
CACHE="${TMPDIR:-/tmp}/sketchybar_network_sample"
DEV=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')

if [ -z "$DEV" ]; then
  rm -f "$CACHE"
  sketchybar --set "$NAME" icon="󰲛" icon.color="$GREY" label="offline"
  exit 0
fi

# Only the <Link#N> row holds byte counters; the per-address rows repeat them.
read -r RX TX <<<"$(netstat -ibn \
  | awk -v d="$DEV" '$1==d && $3 ~ /^<Link#/ {print $7, $10; exit}')"
NOW=$(date +%s)

read -r P_DEV P_TS P_RX P_TX <<<"$(cat "$CACHE" 2>/dev/null)"
printf '%s %s %s %s' "$DEV" "$NOW" "$RX" "$TX" >"$CACHE"

# First sample, a device switch, or a counter wrap: no honest rate to show yet.
if [ "$P_DEV" != "$DEV" ] || [ -z "$P_TS" ] || [ "$NOW" -le "$P_TS" ] \
   || [ "$RX" -lt "${P_RX:-0}" ] || [ "$TX" -lt "${P_TX:-0}" ]; then
  DOWN=0; UP=0
else
  SPAN=$((NOW - P_TS))
  DOWN=$(( (RX - P_RX) / SPAN ))
  UP=$(( (TX - P_TX) / SPAN ))
fi

human() {
  awk -v b="$1" 'BEGIN{
    split("B K M G", u, " ")
    i = 1
    while (b >= 1024 && i < 4) { b /= 1024; i++ }
    printf (i == 1 || b >= 10) ? "%.0f%s" : "%.1f%s", b, u[i]
  }'
}

sketchybar --set "$NAME" \
  icon="󰓅" icon.color="$GREEN" label="$(human "$DOWN")  $(human "$UP")"
