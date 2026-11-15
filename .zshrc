# ~/.zshrc — interactive zsh. Environment and PATH live in ~/.zshenv.
# Ported from ~/.bashrc; aliases stay shared in ~/.aliases.bash (lf reads it too).

# =============================================================================
# OPTIONS
# =============================================================================

setopt GLOB_DOTS             # bash: dotglob (** recursion is built in)
setopt INTERACTIVE_COMMENTS  # allow `# comments` at the prompt like bash
setopt NO_BEEP

# Vi mode
bindkey -v
KEYTIMEOUT=1                                    # fast Esc
bindkey -M viins '^?' backward-delete-char      # backspace past insert start
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M viins '^S' history-incremental-search-forward

[[ -t 0 ]] && stty -ixon   # no Ctrl+S/Ctrl+Q flow control

# =============================================================================
# HISTORY
# =============================================================================

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY        # bash: histappend
setopt INC_APPEND_HISTORY    # write each command right away
setopt HIST_IGNORE_SPACE     # bash: ignorespace
setopt HIST_IGNORE_DUPS      # bash: ignoredups

# =============================================================================
# COLORS, PAGER, COMPLETION
# =============================================================================

if [[ -x /usr/bin/lesspipe ]]; then
  export LESSOPEN="| /usr/bin/lesspipe %s"
  export LESSCLOSE="/usr/bin/lesspipe %s %s"
fi

if (( $+commands[dircolors] )); then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
fi

[[ -d /usr/share/zsh/site-functions ]] && fpath=(/usr/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# =============================================================================
# PROMPT (same look as the bash one)
# =============================================================================

PROMPT_LONG=20
PROMPT_MAX=95
PROMPT_AT=@

__ps1() {
  local P='$' dir=${PWD##*/} B countme short long double nl=$'\n' \
    r='%F{red}' h='%F{blue}' u='%F{yellow}' p='%F{blue}' w='%F{magenta}' \
    b='%F{cyan}' x='%f' g='%F{#5a524c}'

  [[ $EUID == 0 ]] && P='#' && u=$r && p=$u
  [[ $PWD = / ]] && dir=/
  [[ $PWD = "$HOME" ]] && dir='~'

  B=$(git branch --show-current 2>/dev/null)
  [[ $dir = "$B" ]] && B=.
  countme="$USER$PROMPT_AT$HOST:$dir($B)\$ "

  [[ $B == master || $B == main ]] && b=$r
  dir=${dir//\%/%%} B=${B//\%/%%}   # a literal % would be a prompt escape
  [[ -n $B ]] && B="$g($b$B$g)"

  short="$u%n$g$PROMPT_AT$h%m$g:$w$dir$B$p$P$x "
  long="${g}╔$u%n$g$PROMPT_AT$h%m$g:$w$dir$B$nl${g}╚$p$P$x "
  double="${g}╔$u%n$g$PROMPT_AT$h%m$g:$w$dir$nl${g}║$B$nl${g}╚$p$P$x "

  if (( ${#countme} > PROMPT_MAX )); then
    PROMPT=$double
  elif (( ${#countme} > PROMPT_LONG )); then
    PROMPT=$long
  else
    PROMPT=$short
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd __ps1

# =============================================================================
# FUNCTIONS
# =============================================================================

# broot: lets `br` cd the shell
br() {
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

# Clear a stale WAYLAND_DISPLAY/DISPLAY before starting a compositor
_clear_stale_display_vars() {
  if [[ -n ${WAYLAND_DISPLAY:-} ]]; then
    local sock="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/${WAYLAND_DISPLAY}"
    if [[ ! -S $sock ]]; then
      echo "note: clearing stale WAYLAND_DISPLAY=$WAYLAND_DISPLAY (socket not found)" >&2
      unset WAYLAND_DISPLAY
    fi
  fi
  if [[ -n ${DISPLAY:-} ]] && (( $+commands[xset] )); then
    if ! xset q >/dev/null 2>&1; then
      echo "note: clearing stale DISPLAY=$DISPLAY (no X server responding)" >&2
      unset DISPLAY
    fi
  fi
}
sway()     { _clear_stale_display_vars; command sway "$@"; }
Hyprland() { _clear_stale_display_vars; command Hyprland "$@"; }

# =============================================================================
# INTEGRATIONS
# =============================================================================

[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash   # only exports FZF_* variables
# fzf keys: Ctrl+T insert file path, Alt+C cd into dir (Ctrl+R is taken over by atuin below)
(( $+commands[fzf] )) && source <(command fzf --zsh)

# zoxide: `j foo` jumps to the most-used dir matching "foo", `ji` picks interactively
# (bound to j, not z, because z() already opens zathura in ~/.aliases.bash)
(( $+commands[zoxide] )) && eval "$(zoxide init zsh --cmd j)"

# atuin: searchable shell history on Ctrl+R (Up arrow keeps normal behaviour)
(( $+commands[atuin] )) && eval "$(atuin init zsh --disable-up-arrow)"

(( $+commands[pyenv] )) && eval "$(pyenv init - zsh)"

# =============================================================================
# ALIASES (shared with bash and lf)
# =============================================================================

alias tree='tree -a'
alias df='df -h'
[[ -f ~/.aliases.bash ]] && source ~/.aliases.bash

# =============================================================================
# PLUGINS (pacman: zsh-autosuggestions zsh-syntax-highlighting) — keep last
# =============================================================================

[[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
