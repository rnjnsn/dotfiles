#!/bin/bash

# Detect operating system and set clipboard command
case "$(uname -s)" in
    Linux*)     CLIPBOARD_CMD="xclip -selection clipboard -o";;
    Darwin*)    CLIPBOARD_CMD="pbpaste";;
    CYGWIN*)    CLIPBOARD_CMD="powershell.exe -command 'Get-Clipboard'";;
    MINGW*)     CLIPBOARD_CMD="powershell.exe -command 'Get-Clipboard'";;
    *)          echo "Unsupported operating system"; exit 1;;
esac

# Get clipboard content
clipboard_content=$(eval "$CLIPBOARD_CMD")

# Export for use in the zet script
export CLIPBOARD_CONTENT="$clipboard_content"

# Call your existing zet script
zet
