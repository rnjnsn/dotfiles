#!/bin/bash

set -e  # Exit on errors

# --- CONFIG ---
DOTFILES_REPO="git@github.com:rnjnsn/dotfiles.git"
DWM_REPO="git@github.com:rnjnsn/dwm.git"
DOTFILES_DIR="$HOME/.dotfiles"
DWM_DIR="$HOME/builds/dwm"
CONFIG_H="$HOME/.config/dwm/config.h"
ALIAS_LINE="alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'"

# --- 1. Install essential packages ---
echo "📦 Installing base packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
  base-devel git xorg xorg-xinit \
  alacritty firefox dmenu lf \
  neovim zathura zathura-pdf-mupdf \
  xclip wget curl

# --- 1.5 Install Ubuntu Mono Nerd Font ---
echo "🔤 Installing Ubuntu Mono Nerd Font..."

FONT_DIR="$HOME/.local/share/fonts"
FONT_NAME="UbuntuMonoNerdFont-Regular.ttf"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/UbuntuMono/Regular/$FONT_NAME"

mkdir -p "$FONT_DIR"

if [ ! -f "$FONT_DIR/$FONT_NAME" ]; then
  curl -fLo "$FONT_DIR/$FONT_NAME" "$FONT_URL"
  echo "✅ Font downloaded: $FONT_NAME"
else
  echo "✅ Font already present, skipping download"
fi

fc-cache -fv

# --- 2. Clone dotfiles (bare repo) ---
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "🧠 Cloning dotfiles..."
    git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"
    git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" checkout
    echo "$ALIAS_LINE" >> ~/.bashrc
    eval "$ALIAS_LINE"
else
    echo "✅ Dotfiles already set up."
fi

# --- 3. Create config folder if missing ---
mkdir -p ~/.config/dwm

# --- 4. Clone and build DWM ---
if [ ! -d "$DWM_DIR" ]; then
    echo "🧱 Cloning dwm..."
    git clone "$DWM_REPO" "$DWM_DIR"
else
    echo "🔁 dwm repo already cloned."
fi

# --- 5. Inject config.h and build ---
if [ -f "$CONFIG_H" ]; then
    echo "🧩 Injecting config.h..."
    cp "$CONFIG_H" "$DWM_DIR/config.h"
else
    echo "⚠️ config.h not found at $CONFIG_H"
    exit 1
fi

cd "$DWM_DIR"
echo "🔨 Building dwm..."
sudo make clean install

# --- 6. Set up .xinitrc ---
echo "📝 Writing ~/.xinitrc..."
cat > ~/.xinitrc <<EOF
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
exec dwm
EOF

# --- 7. Add .scripts to PATH if needed ---
if ! grep -q '.scripts' ~/.bashrc; then
  echo 'export PATH="$HOME/.scripts:$PATH"' >> ~/.bashrc
  echo "✅ Added .scripts to PATH in .bashrc"
else
  echo "ℹ️ .scripts already in PATH"
fi

# --- Done ---
echo -e "\n✅ Setup complete. Run \033[1mstartx\033[0m to launch DWM!"
