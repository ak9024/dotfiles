#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# sysctl and memory_pressure are ~2-4ms each. Sampling `top` would cost a full
# second per tick, which is why this reports load average rather than a
# instantaneous CPU percentage.
read -r _ LOAD _ <<<"$(sysctl -n vm.loadavg)"
CORES=$(sysctl -n hw.ncpu)
FREE=$(memory_pressure -Q 2>/dev/null | sed -n 's/.*percentage: \([0-9]*\)%.*/\1/p')

# Load is per-machine, so scale it against core count before colouring.
PCT=$(awk -v l="$LOAD" -v c="$CORES" 'BEGIN{printf "%.0f", (l/c)*100}')
if   [ "$PCT" -ge 90 ]; then COLOR="$RED"
elif [ "$PCT" -ge 60 ]; then COLOR="$YELLOW"
else COLOR="$WHITE"
fi

sketchybar --set "$NAME" \
  icon="󰍛" icon.color="$COLOR" label="${LOAD}  ${FREE:-?}%"
