#!/bin/bash

# ----------------------- environment variables ----------------------

# Basic environment variables
export LANG=en_US.UTF-8
export LC_TIME=de_DE.UTF-8
export LC_MONETARY=de_DE.UTF-8
export LC_NUMERIC=de_DE.UTF-8
export USER="${USER:-$(whoami)}"
export EDITOR=nvim
export GIT_EDITOR=$EDITOR
export TZ=Europe/Berlin
export CLICOLOR=1
export HRULEWIDTH=73
export LC_COLLATE=C

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec Hyprland

# Path manipulation functions
pathappend() {
    declare arg
    for arg in "$@"; do
        test -d "$arg" || continue
        PATH=${PATH//":$arg:"/:}
        PATH=${PATH/#"$arg:"/}
        PATH=${PATH/%":$arg"/}
        export PATH="${PATH:+"$PATH:"}$arg"
    done
} && export -f pathappend

pathprepend() {
    for arg in "$@"; do
        test -d "$arg" || continue
        PATH=${PATH//:"$arg:"/:}
        PATH=${PATH/#"$arg:"/}
        PATH=${PATH/%":$arg"/}
        export PATH="$arg${PATH:+":${PATH}"}"
    done
} && export -f pathprepend

# Combine all path configurations
pathprepend \
    "$HOME/.local/bin" \
    "$HOME/bin" \
    "$HOME/.local/go/bin" \
    "$GHREPOS/cmd-"*

# Go configuration
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
pathappend "$GOBIN"

# Additional paths
pathappend \
    /usr/local/bin \
    /usr/local/sbin \
    /usr/sbin \
    /usr/bin \
    /snap/bin \
    /sbin \
    /bin


# ------------------- helper functions -------------------

# Check if a command exists
_have() {
    command -v "$1" >/dev/null 2>&1
}

# Source a file if it exists
_source_if() {
    [[ -f "$1" ]] && source "$1"
}

# ------------------------------- pager ------------------------------

if [[ -x /usr/bin/lesspipe ]]; then
    export LESSOPEN="| /usr/bin/lesspipe %s"
    export LESSCLOSE="/usr/bin/lesspipe %s %s"
fi

# ----------------------------- dircolors ----------------------------

if _have dircolors; then
    if [[ -r "$HOME/.dircolors" ]]; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi

# ------------------------ bash shell options ------------------------

shopt -s checkwinsize # enables $COLUMNS and $ROWS
shopt -s expand_aliases
shopt -s globstar
shopt -s dotglob
shopt -s extglob

# -------------------------- stty annoyances -------------------------

stty -ixon # disable control-s/control-q tty flow control

# ------------------------------ history -----------------------------

export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTFILESIZE=10000

set -o vi
shopt -s histappend

# --------------------------- smart prompt ---------------------------

PROMPT_LONG=20
PROMPT_MAX=95
PROMPT_AT=@

__ps1() {
    local P='$' dir="${PWD##*/}" B countme short long double \
        r='\[\e[31m\]' h='\[\e[34m\]' \
        u='\[\e[33m\]' p='\[\e[34m\]' w='\[\e[35m\]' \
        b='\[\e[36m\]' x='\[\e[0m\]' \
        g="\[\033[38;2;90;82;76m\]"

    [[ $EUID == 0 ]] && P='#' && u=$r && p=$u # root
    [[ $PWD = / ]] && dir=/
    [[ $PWD = "$HOME" ]] && dir='~'

    B=$(git branch --show-current 2>/dev/null)
    [[ $dir = "$B" ]] && B=.
    countme="$USER$PROMPT_AT$(hostname):$dir($B)\$ "

    [[ $B == master || $B == main ]] && b="$r"
    [[ -n "$B" ]] && B="$g($b$B$g)"

    short="$u\u$g$PROMPT_AT$h\h$g:$w$dir$B$p$P$x "
    long="${g}╔$u\u$g$PROMPT_AT$h\h$g:$w$dir$B\n${g}╚$p$P$x "
    double="${g}╔$u\u$g$PROMPT_AT$h\h$g:$w$dir\n${g}║$B\n${g}╚$p$P$x "

    if ((${#countme} > PROMPT_MAX)); then
        PS1="$double"
    elif ((${#countme} > PROMPT_LONG)); then
        PS1="$long"
    else
        PS1="$short"
    fi
}

PROMPT_COMMAND="__ps1"

# ------------------------------ aliases -----------------------------

unalias -a
alias ls='ls -h --color=auto'
alias tree='tree -a'
alias df='df -h'
alias vim='nvim'
alias vi='nvim'
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
alias mkd="mkdir -pv"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# ------------------------- source extras --------------------------

# Source FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Source personal configurations if they exist
_source_if "$HOME/.bash_personal"
_source_if "$HOME/.bash_private"

# Source aliases file
[ -f ~/.aliases.bash ] && source ~/.aliases.bash

# Source bash completion
[[ -r /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

# Source git completion if available
[[ -r /usr/share/git/completion/git-completion.bash ]] && source /usr/share/git/completion/git-completion.bash

# Source cargo environment if it exists
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Start tmux if it's installed and not already running
if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
    # Attach to a session or create a new one
    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
fi

# Add custom scripts directory to PATH
alias lf=~/.local/bin/lfub

# FZF launcher setup 
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--preview='bat --color=always {} || cat {}' \
  --height=100% \
  --layout=reverse \
  --border"
alias fzopen="~/.local/bin/fzopen"
alias fzd="~/.local/bin/fzd"
alias fzl="~/.local/bin/fzl"
