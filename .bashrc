#!/bin/bash

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

# Basic environment variables
export LANG=en_US.UTF-8
export LC_TIME=de_DE.UTF-8
export LC_MONETARY=de_DE.UTF-8
export LC_NUMERIC=de_DE.UTF-8
export LC_COLLATE=C
export USER="${USER:-$(whoami)}"
export EDITOR=nvim
export GIT_EDITOR=$EDITOR
export IMAGE_VIEWER=imv
export TERMINAL=foot
export TZ=Europe/Berlin
export CLICOLOR=1
export HRULEWIDTH=73

# Wayland session configuration
export XDG_SESSION_TYPE=wayland
export WAYLAND_DISPLAY=wayland-1

# Application-specific environment variables
export MOZ_ENABLE_WAYLAND=1
export PYENV_ROOT="$HOME/.pyenv"
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--preview='bat --color=always {} || cat {}' \
  --height=100% \
  --layout=reverse \
  --border"

# =============================================================================
# PATH CONFIGURATION
# =============================================================================

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

# Prepend user-specific paths (highest priority)
pathprepend \
    "$HOME/.local/bin" \
    "$HOME/bin" \
    "$HOME/.local/go/bin" \
    "$GHREPOS/cmd-"*

# Add custom script directories
pathprepend \
    "$HOME/.local/bin/public-scripts" \
    "$HOME/.local/bin/private-scripts"

# Add pyenv to PATH
pathprepend "$PYENV_ROOT/bin"

# Append system paths and Go binary path
pathappend \
    "$GOBIN" \
    /usr/local/bin \
    /usr/local/sbin \
    /usr/sbin \
    /usr/bin \
    /snap/bin \
    /sbin \
    /bin

# =============================================================================
# BASH SHELL OPTIONS
# =============================================================================

# Shell options
shopt -s checkwinsize    # enables $COLUMNS and $ROWS
shopt -s expand_aliases
shopt -s globstar
shopt -s dotglob
shopt -s extglob
shopt -s histappend

# Vi mode
set -o vi

# Disable control-s/control-q tty flow control
stty -ixon

# =============================================================================
# HISTORY CONFIGURATION
# =============================================================================

export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTFILESIZE=10000

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Check if a command exists
_have() {
    command -v "$1" >/dev/null 2>&1
}

# Source a file if it exists
source*if() {
    [[ -f "$1" ]] && source "$1"
}

# broot integration
function br {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" "$@"; then
        cmd=$(<"$cmd_file")
        command rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        command rm -f "$cmd_file"
        return "$code"
    fi
}

# =============================================================================
# PAGER CONFIGURATION
# =============================================================================

if [[ -x /usr/bin/lesspipe ]]; then
    export LESSOPEN="| /usr/bin/lesspipe %s"
    export LESSCLOSE="/usr/bin/lesspipe %s %s"
fi

# =============================================================================
# DIRCOLORS CONFIGURATION
# =============================================================================

if _have dircolors; then
    if [[ -r "$HOME/.dircolors" ]]; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi

# =============================================================================
# SMART PROMPT CONFIGURATION
# =============================================================================

PROMPT_LONG=20
PROMPT_MAX=95
PROMPT_AT=@

__ps1() {
	local P='$' dir="${PWD##*/}" B countme short long double \
		r='\[\e[31m\]' h='\[\e[34m\]' \
		u='\[\e[33m\]' p='\[\e[34m\]' w='\[\e[35m\]' \
		b='\[\e[36m\]' x='\[\e[0m\]' \
		g="\[\033[38;2;90;82;76m\]"

	[[ $EUID == 0 ]] && P='#' && u=$r && p=$u
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

# =============================================================================
# ALIASES
# =============================================================================

alias ls='ls -h --color=auto'
alias tree='tree -a'
alias df='df -h'
alias fzfopen="~/.local/bin/public-scripts/fzfopen"
alias fzd="~/.local/bin/public-scripts/fzd"
alias fzl="~/.local/bin/public-scripts/fzl"

# =============================================================================
# EXTERNAL SOURCES AND INTEGRATIONS
# =============================================================================

# Source FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Source aliases file
[ -f ~/.aliases.bash ] && source ~/.aliases.bash

# Source bash completion
[[ -r /usr/share/bash-completion/bash_completion ]] && source /usr/share/bash-completion/bash_completion

# Source git completion if available
[[ -r /usr/share/git/completion/git-completion.bash ]] && source /usr/share/git/completion/git-completion.bash

# Source broot launcher
source /home/rene/.config/broot/launcher/bash/br

# Source cargo environment
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
. "$HOME/.cargo/env"

# Initialize pyenv
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# --- Wayland launch wrappers added by add_wayland_launch_wrappers.sh ---
# Clears a stale WAYLAND_DISPLAY/DISPLAY (pointing at a socket that no
# longer exists) before launching a compositor, so a crashed previous
# session can't cause "could not connect to remote display" errors.
_clear_stale_display_vars() {
    if [ -n "${WAYLAND_DISPLAY:-}" ]; then
        local sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/${WAYLAND_DISPLAY}"
        if [ ! -S "$sock" ]; then
            echo "note: clearing stale WAYLAND_DISPLAY=$WAYLAND_DISPLAY (socket not found)" >&2
            unset WAYLAND_DISPLAY
        fi
    fi
    if [ -n "${DISPLAY:-}" ] && ! command -v xset >/dev/null 2>&1; then
        : # no X tooling available to verify DISPLAY; leave it alone
    elif [ -n "${DISPLAY:-}" ] && command -v xset >/dev/null 2>&1; then
        if ! xset q >/dev/null 2>&1; then
            echo "note: clearing stale DISPLAY=$DISPLAY (no X server responding)" >&2
            unset DISPLAY
        fi
    fi
}

sway() {
    _clear_stale_display_vars
    command sway "$@"
}

Hyprland() {
    _clear_stale_display_vars
    command Hyprland "$@"
}
export PATH="$HOME/.local/bin/public-scripts:$PATH"
z() { zathura "$@" >/dev/null 2>&1 & disown; }
