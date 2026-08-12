#!/usr/bin/env bash
# Rebuild this setup on a fresh Mac. Idempotent — safe to re-run.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_FONT_VERSION="v2.0.74"

log() { printf '\n==> %s\n' "$1"; }

# ── Packages ──────────────────────────────────────────────────────────────
# Homebrew refuses third-party taps until trusted. This grants trust to two
# specific formulae, not to the whole tap.
log "Taps and packages"
brew tap FelixKratz/formulae
brew trust --formula felixkratz/formulae/sketchybar
brew trust --formula felixkratz/formulae/borders
brew install sketchybar borders
brew install --cask nikitabobko/tap/aerospace
brew install --cask font-hack-nerd-font

# ── App icon font ─────────────────────────────────────────────────────────
# Gitignored: a generated artifact, pinned here rather than committed.
log "sketchybar-app-font $APP_FONT_VERSION"
base="https://github.com/kvndrsslr/sketchybar-app-font/releases/download/$APP_FONT_VERSION"
curl -fsSL -o "$HOME/Library/Fonts/sketchybar-app-font.ttf" "$base/sketchybar-app-font.ttf"
curl -fsSL -o "$REPO/sketchybar/plugins/icon_map.sh" "$base/icon_map.sh"
chmod +x "$REPO/sketchybar/plugins/icon_map.sh"

# ── Symlinks ──────────────────────────────────────────────────────────────
log "Linking configs"
mkdir -p "$HOME/.config/aerospace"
link() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.backup-$(date +%s)"
    echo "    moved existing $dest aside"
  fi
  ln -sfn "$src" "$dest"
  echo "    $dest -> $src"
}
link "$REPO/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
link "$REPO/aerospace/scratchpad.sh"  "$HOME/.config/aerospace/scratchpad.sh"
link "$REPO/sketchybar"               "$HOME/.config/sketchybar"

chmod +x "$REPO/aerospace/scratchpad.sh" "$REPO/sketchybar/sketchybarrc" \
         "$REPO/sketchybar/colors.sh" "$REPO/sketchybar"/plugins/*.sh

# ── macOS settings ────────────────────────────────────────────────────────
log "macOS defaults"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock mru-spaces -bool false
killall Dock

# ── Services ──────────────────────────────────────────────────────────────
log "Starting services"
brew services start sketchybar
open -a AeroSpace

cat <<'MANUAL'

==> Remaining manual steps (macOS will not let a script do these):

  1. Grant AeroSpace Accessibility permission
     System Settings > Privacy & Security > Accessibility

  2. Hide the native menu bar so it does not double up with sketchybar
     System Settings > Control Center > Menu Bar > "Automatically hide
     and show the menu bar" = Always

  3. Reduce motion, or workspace switches animate and feel slow
     System Settings > Accessibility > Display > Reduce motion

MANUAL
