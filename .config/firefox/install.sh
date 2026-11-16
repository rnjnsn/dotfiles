#!/bin/sh
# Link this config into the Firefox default-release profile. Run after a fresh install (start Firefox once first).
# Existing user.js / chrome in the profile are moved aside to *.orig.
set -e
here=$(cd "$(dirname "$0")" && pwd)
prof=$(find ~/.mozilla/firefox -maxdepth 1 -name '*.default-release' | head -n1)
[ -n "$prof" ] || { echo "no default-release profile; start Firefox once" >&2; exit 1; }
for f in user.js chrome; do
  if [ -e "$prof/$f" ] && [ ! -L "$prof/$f" ]; then mv "$prof/$f" "$prof/$f.orig"; fi
  ln -sfn "$here/$f" "$prof/$f"
  echo "$prof/$f -> $here/$f"
done
echo "Vimium C: Options > Import settings > $here/vimium-c.json"
