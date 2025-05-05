#!/bin/bash

# Use neovim for vim if present
command -v nvim >/dev/null && alias vim="nvim" vimdiff="nvim -d"

# Verbosity and settings for better user feedback
alias \
    cp="cp -iv" \
    mv="mv -iv" \
    rm="rm -v" \
    mkd="mkdir -pv" \
    rsync="rsync -vrPlu"

# Media and download aliases
alias \
    yt="yt-dlp --embed-metadata -i" \
    yta="yt -x -f bestaudio/best" \
    ytt="yt --skip-download --write-thumbnail" \
    ffmpeg="ffmpeg -hide_banner"

# Colorize commands for Linux
alias \
    ls="ls -h --color=auto" \
    ll="ls -lh --color=auto" \
    la="ls -lah --color=auto" \
    grep="grep --color=auto" \
    diff="diff --color=auto"

# System shortcuts
alias ka="killall"
alias sd='sudo systemctl poweroff --no-wall'

# Editor aliases
alias \
    e="$EDITOR" \
    v="$EDITOR"

# File finder aliases
alias ff='~/.local/bin/public-scripts/ffd -f -p -e' # Find and open files
alias fd='~/.local/bin/public-scripts/ffd -d -p' # Find directories

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# Personal shortcuts
alias c="cd ~/.config"
alias dl="cd ~/downloads"
alias dt="cd ~/Desktop"
alias p="cd ~/projects"
alias g="git"
alias h="nvim ~/.config/hypr/hyprland.conf"
alias s="cd ~/.local/bin/public-scripts"
alias z='cd ~\notes/3.\ zettelkasten'
alias w="cd ~/projects/rnjnsn-website"
alias wc="cd ~/projects/rnjnsn-website/content"
alias wl="cd ~/projects/rnjnsn-website/layouts"
alias wac="cd ~/projects/rnjnsn-website/static/css"
alias wab="nvim ~/projects/rnjnsn-website/layouts/about/index.html"
alias wco="nvim ~/projects/rnjnsn-website/layouts/contact/index.html"
alias wre="nvim ~/projects/rnjnsn-website/layouts/resources/index.html"

# Apps
alias lf="lfub"
alias vim="nvim"
alias vi="nvim"
alias ncd="nordvpn connect denmark"
alias ncd="nordvpn connect germany"

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias privdot='/usr/bin/git --git-dir=$HOME/.dotfiles-private --work-tree=$HOME'
