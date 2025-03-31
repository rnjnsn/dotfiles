#!/bin/bash

# Installation path
INSTALL_DIR="$HOME/.local/bin"

# Detect operating system
case "$(uname -s)" in
    Linux*)
        if ! command -v xclip >/dev/null 2>&1; then
            echo "Installing xclip..."
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get install -y xclip
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S xclip
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y xclip
            else
                echo "Please install xclip manually"
                exit 1
            fi
        fi
        ;;
    Darwin*)
        # pbcopy/pbpaste come with macOS
        ;;
    *)
        # Windows checks removed since you want platform agnostic
        echo "Note: On Windows, make sure PowerShell is available"
        ;;
esac

# Create installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Install the script
cp czet.sh "$INSTALL_DIR/czet"
chmod +x "$INSTALL_DIR/czet"

# Add to PATH if not already there
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Adding $INSTALL_DIR to PATH..."
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bashrc"
    echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.zshrc" 2>/dev/null || true
fi

echo "Installation complete!"
echo "You can now use 'czet' to create notes with clipboard content"
echo "Please run: source ~/.bashrc (or ~/.zshrc) to update your PATH"
