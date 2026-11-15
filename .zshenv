# ~/.zshenv — read by every zsh (also scripts and nvim's :!), so keep it
# fast and silent: only environment variables and PATH here.

# Locale and basics
export LANG=en_US.UTF-8
export LC_TIME=de_DE.UTF-8
export LC_MONETARY=de_DE.UTF-8
export LC_NUMERIC=de_DE.UTF-8
export LC_COLLATE=C
export EDITOR=nvim
export GIT_EDITOR=$EDITOR
export IMAGE_VIEWER=imv
export TERMINAL=foot
export TZ=Europe/Berlin
export CLICOLOR=1
export HRULEWIDTH=73

# Wayland
export XDG_SESSION_TYPE=wayland
export WAYLAND_DISPLAY=wayland-1
export MOZ_ENABLE_WAYLAND=1

# Languages
export PYENV_ROOT="$HOME/.pyenv"
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"

# PATH: `path` is zsh's array view of $PATH; -U drops duplicates (first wins).
typeset -U path PATH
path=(
  $HOME/.local/bin/public-scripts
  $HOME/.local/bin/private-scripts
  $PYENV_ROOT/bin
  $HOME/.local/bin
  $HOME/bin
  $HOME/.local/go/bin
  $path
  $GOBIN
  /usr/local/bin /usr/local/sbin /usr/sbin /usr/bin /snap/bin /sbin /bin
)
path=($^path(N-/))   # keep only folders that exist

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
