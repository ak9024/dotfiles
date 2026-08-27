#!/usr/bin/env bash
# i3-style scratchpad toggle.
# AeroSpace bindings cannot branch, so the conditional lives here: jump to the
# scratchpad workspace, or bounce back to wherever you came from.

SCRATCH="S"

if [ "$(aerospace list-workspaces --focused)" = "$SCRATCH" ]; then
  aerospace workspace-back-and-forth
else
  aerospace workspace "$SCRATCH"
fi
