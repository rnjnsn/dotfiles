#!/bin/bash
# Set the Lexicon directory
LEX_DIR="/Users/renejensen/Library/CloudStorage/GoogleDrive-r@rnjnsn.com/My Drive/rnjnsn/6. lexicon"

# Function to convert word to lowercase for filename
sanitize_filename() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:] ' | tr ' ' '-'
}

# Check if the directory exists
if [ ! -d "$LEX_DIR" ]; then
    echo "Error: Lexicon directory not found at $LEX_DIR"
    mkdir -p "$LEX_DIR"
    echo "Created directory: $LEX_DIR"
fi

# Get the word from user input
echo -n "Enter word: "
read input_word

# Get language
echo -n "Enter language: "
read language

# Create filename version (lowercase)
filename_word=$(sanitize_filename "$input_word")

# Create filename using the hyphenated version
filename="$LEX_DIR/$filename_word.md"

# Create the dictionary entry with template
cat > "$filename" << EOL
---
word: "$input_word"
language: "$language"
created: $(date '+%Y-%m-%d %H:%M:%S')
tags:
  - vocabulary
  - ${language}
---

### Definition


### Example


### Etymology


### Notes


