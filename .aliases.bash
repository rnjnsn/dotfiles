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

# Apps
alias lf=lfub

alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias privdot='/usr/bin/git --git-dir=$HOME/.dotfiles-private --work-tree=$HOME'
