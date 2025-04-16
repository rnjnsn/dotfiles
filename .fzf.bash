# Set up fzf defaults
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Configure default options with preview and keybindings 
export FZF_DEFAULT_OPTS="--preview='bat --color=always {}' \
    --height 100% \
    --layout=reverse \
    --border \
    --bind='enter:execute(tmux new-window \"nvim {}\")+abort,ctrl-r:execute(cd \$(dirname {}) && ranger --selectfile={})'"
