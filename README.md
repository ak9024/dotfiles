# dotfiles

i3-style tiling on macOS: [AeroSpace](https://github.com/nikitabobko/AeroSpace)
for window management, [SketchyBar](https://github.com/FelixKratz/SketchyBar)
for the status bar, [JankyBorders](https://github.com/FelixKratz/JankyBorders)
for the focus indicator.

## Install

```bash
git clone <this repo> ~/dotfiles && ~/dotfiles/bootstrap.sh
```

Then finish the three manual permission steps it prints at the end.

## Layout

| Path in repo | Symlinked to |
|---|---|
| `aerospace/aerospace.toml` | `~/.aerospace.toml` |
| `aerospace/scratchpad.sh` | `~/.config/aerospace/scratchpad.sh` |
| `sketchybar/` | `~/.config/sketchybar/` |

Edits apply live — `auto-reload-config = true` in AeroSpace, and it follows the
symlink. SketchyBar needs `sketchybar --reload`.

## Keys

`alt` is Option.

| Key | Action |
|---|---|
| `alt+enter` | New iTerm |
| `alt+shift+q` | Close window |
| `alt+h/j/k/l` | Focus (arrows work too) |
| `alt+shift+h/j/k/l` | Move window |
| `alt+1`..`alt+0` | Workspace 1-10 |
| `alt+shift+1`..`0` | Send window to workspace |
| `alt+tab` | Last workspace |
| `alt+a` | Last window |
| `alt+f` | Fullscreen (stays tiled) |
| `alt+shift+f` | macOS native fullscreen (leaves tiling) |
| `alt+b` / `alt+v` | Tile horizontal / vertical |
| `alt+e` | Toggle tile orientation |
| `alt+w` | Accordion layout |
| `alt+shift+space` | Toggle floating |
| `alt+shift+e` | Flatten tree |
| `alt+shift+b` | Balance sizes |
| `alt+minus` | Scratchpad toggle |
| `alt+shift+minus` | Send window to scratchpad |
| `alt+r` | Resize mode — `hjkl`, `esc` exits |
| `alt+g` | Join mode — direction, then back to main |
| `alt+shift+;` | Service mode — `r` reloads |

### Join mode

Normalization flattens containers, so every window lands in the root and
`alt+v` flips the whole workspace rather than one split. `alt+g` + direction
puts two windows under a shared parent first; `alt+b`/`alt+v` then applies to
just that parent. This is how mixed layouts get built.

## Workspace assignment

| Workspace | Apps |
|---|---|
| 1 | iTerm2, OrbStack |
| 2 | Chrome, Safari |
| 3 | Xcode, Android Studio, DBeaver, Postman |
| 4 | Discord, Zoom |
| 5 | OBS, Transporter |
| S | Scratchpad |

Rules only fire on window *creation*. Already-open windows stay where they are.

## Gotchas

- **A broken config fails silently.** With `auto-reload-config` on, invalid TOML
  leaves the previous config running with no visible error. Run
  `aerospace reload-config` to see the parse error. Add bindings *inside* the
  existing `[mode.main.binding]` block — a second one at the end of the file is
  a duplicate table and will not parse.
- **Do not add the bar height to `outer.top`.** AeroSpace tiles inside
  `NSScreen.visibleFrame`, which already excludes the 38pt notch strip that
  sketchybar draws in. Adding it again double-counts and wastes 32pt.
- **`split` is rejected** while normalizations are enabled. Use explicit
  `layout tiles horizontal|vertical`, or `join-with`.
- **Workspace icons lag on window close.** AeroSpace has no window-closed
  callback; the bar catches up on the next focus change.
- **SSID shows as "Wi-Fi".** macOS 14+ gates the network name behind Location
  Services. Not a config bug.
