#!/usr/bin/env bash
# Install the Firefox autoconfig script (Ctrl+number tab switching).
# Run with sudo. Re-run after editing mozilla.cfg. Restart Firefox afterwards.
# Undo: sudo rm /usr/lib/firefox/defaults/pref/autoconfig.js /usr/lib/firefox/mozilla.cfg
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
FF=/usr/lib/firefox
[[ $EUID -eq 0 ]] || { echo "run with sudo" >&2; exit 1; }
install -m 644 "$SRC/autoconfig.js" "$FF/defaults/pref/autoconfig.js"
install -m 644 "$SRC/mozilla.cfg"   "$FF/mozilla.cfg"
echo "Installed. Restart Firefox."
