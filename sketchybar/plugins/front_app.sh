#!/usr/bin/env bash

# front_app_switched carries the app name in $INFO; on forced updates (startup)
# it is empty, so ask AeroSpace instead.
APP="$INFO"
if [ -z "$APP" ]; then
  APP=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null | head -1)
fi

[ -n "$APP" ] && sketchybar --set "$NAME" label="$APP"
