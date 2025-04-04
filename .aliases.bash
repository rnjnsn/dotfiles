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

# Colorize commands for macOS
alias \
    ls="ls -G" \
    ll="ls -lG" \
    la="ls -laG" \
    grep="grep --color=auto" \
    diff="diff --color=auto"

# System shortcuts
alias ka="killall"

# Editor aliases
alias \
    e="$EDITOR" \
    v="$EDITOR"

# Directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# Personal shortcuts
alias d="cd ~/Dropbox"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias c="cd /Users/renejensen/.config"
alias p="cd ~/projects"
alias g="git"
alias z='cd ~/Google\ Drive/My\ Drive/rnjnsn/3.\ zettelkasten'
alias w="cd /Users/renejensen/rnjnsn-website"
alias wc="cd /Users/renejensen/rnjnsn-website/content"
alias wl="cd /Users/renejensen/rnjnsn-website/layouts"
alias wac="cd /Users/renejensen/rnjnsn-website/assets/css"
alias wab="nvim /Users/renejensen/rnjnsn-website/layouts/about/index.html"
alias wco="cd /Users/renejensen/rnjnsn-website/layouts/contact/index.html"
alias wre="cd /Users/renejensen/rnjnsn-website/layouts/resources/index.html"
alias djoefda="zathura /Users/renejensen/Dropbox/career/guides/djoef-app-da.pdf"
alias djoefen="zathura /Users/renejensen/Dropbox/career/guides/djoef-app-en.pdf"

# Scripts, related

alias editcv="nvim /Users/renejensen/Dropbox/career/templates/cv-light.md"
alias editapp="nvim /Users/renejensen/Dropbox/career/templates/app.md"
