#!/bin/bash

echo "Uninstalling czet components..."

# Remove czet script
if [ -f "$HOME/.local/bin/czet" ]; then
    echo "Removing czet script..."
    rm -f "$HOME/.local/bin/czet"
fi

# Clean up PATH additions
echo "Cleaning up PATH in shell configs..."
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ]; then
        # Remove the PATH addition line
        sed -i.bak '/export PATH="\$PATH:\$HOME\/.local\/bin"/d' "$rc"
        rm -f "${rc}.bak"
    fi
done

# Clean up empty directories if they're empty
rmdir "$HOME/.local/bin" 2>/dev/null
rmdir "$HOME/.local" 2>/dev/null

echo "Uninstallation complete!"
echo "Please restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc) to update your PATH"
