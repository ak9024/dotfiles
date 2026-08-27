#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

# `/` is the sealed system snapshot on APFS and reports a misleading ~50%; the
# volume users actually fill is the Data volume sharing the same container.
read -r _ _ USED AVAIL PCT _ <<<"$(df -H /System/Volumes/Data | tail -1)"
PCT=${PCT%\%}

if   [ "$PCT" -ge 90 ]; then COLOR="$RED"
elif [ "$PCT" -ge 75 ]; then COLOR="$YELLOW"
else COLOR="$WHITE"
fi

sketchybar --set "$NAME" \
  icon="󰋊" icon.color="$COLOR" label="${AVAIL} free"
