# Aliases and functions, sourced by ~/.zshrc and read by lf (the goto command in lfrc).

# Use neovim for vim if present
command -v nvim >/dev/null && alias vim="nvim" vimdiff="nvim -d"

# Verbosity and settings for better user feedback
alias \
  cp="cp -iv" \
  mv="mv -iv" \
  rm="rm -v" \
  mkd="mkdir -pv" \
  rsync="rsync -vrPlu"

# Colorize commands for Linux
alias \
  ls="ls -h --color=auto" \
  ll="ls -lh --color=auto" \
  la="ls -lah --color=auto" \
  grep="grep --color=auto" \
  diff="diff --color=auto"

# Claude
alias claude-w="cd ~/rnjnsn-website && git pull && claude"
alias claude-a='cd ~/docs/career && claude "/apply"'

# Editor aliases
alias \
  e="$EDITOR" \
  v="$EDITOR" \
  vim="nvim" \
  vi="nvim"

# Apps
alias \
  fzf="fzopen" \
  ffmpeg="ffmpeg -hide_banner"

# Terminal commands
alias wlcopy='wl-copy'

# System shortcuts
alias \
  ka="killall" \
  sd='sudo systemctl poweroff --no-wall'

# Directory navigation
alias \
  ..="cd .." \
  ...="cd ../.." \
  ....="cd ../../.." \
  .....="cd ../../../.." \
  ~="cd ~"
alias -- -="cd -"

# File finder aliases
alias ff='~/.local/bin/public-scripts/ffd -f -p -e'   # Find and open files
alias fd='~/.local/bin/public-scripts/ffd -d -p'      # Find directories

# ── Personal shortcuts ───────────────────────────────────────────────────────
alias \
  c="cd ~/.config" \
  dl="cd ~/downloads" \
  l="cd ~/docs/lit" \
  p="cd ~/projects" \
  g="git" \
  n="cd ~/notes" \
  r="cd ~/docs/career/resumebuilder" \
  s="cd ~/.local/bin/public-scripts"

## Career
alias \
  app="nvim ~/docs/career/resumebuilder/app.md" \
  cv="nvim ~/docs/career/resumebuilder/cv.md"


## Anki
ANKI="$HOME/docs/anki"
alias \
  dk="nvim $ANKI/dk-dump.csv" \
  en="nvim $ANKI/en-dump.csv" \
  fr="nvim $ANKI/fr-dump.csv" \
  ge="nvim $ANKI/ge-dump.csv"

# ── Media ────────────────────────────────────────────────────────────────────
alias \
  yt="yt-dlp --embed-metadata -i" \
  yta="yt -x -f bestaudio/best" \
  ytt="yt --skip-download --write-thumbnail"

# ── Network & remote ─────────────────────────────────────────────────────────
alias cmint="ssh rene@192.168.194.213"

mint="rene@192.168.194.213:~"
mintv="rene@192.168.194.213:~/Videos/"

rap() {
  local src="$1"
  local dest="${2:-$mint}"
  command rsync -avz --progress "$src" "$dest"
}

# ── Git ──────────────────────────────────────────────────────────────────────
alias \
  dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME' \
  privdot='/usr/bin/git --git-dir=$HOME/.dotfiles-private --work-tree=$HOME'

# ── Hardware ─────────────────────────────────────────────────────────────────
alias conairpods="bluetoothctl connect EC:46:54:53:BB:C4"
alias coniphone='~/.config/waybar/scripts/net.sh hotspot'   # password is in the NetworkManager profile, not here

# ── Functions ────────────────────────────────────────────────────────────────

# Open file(s) in zathura, detached from the terminal
unalias z 2>/dev/null
z() {
  zathura "$@" >/dev/null 2>&1 & disown
}

# Copy files modified today (since midnight) from a source dir to a destination dir
cptoday() {
  local src="${1:-$PWD}"
  local dest="$2"
  if [[ -z "$dest" ]]; then
    echo "Usage: cptoday [source_dir] <dest_dir>"
    return 2
  fi
  mkdir -p -- "$dest" || return
  find "$src" -maxdepth 1 -type f -daystart -mtime 0 -print0 \
    | xargs -0 -I{} cp -v -- "{}" "$dest/"
}

# Image → PDF (sorted, lossless, WhatsApp-safe)
imgspdf() {
  local src="${1:-.}"
  local out="${2:-output.pdf}"
  find "$src" -maxdepth 1 -type f \( \
      -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
    \) -print0 \
    | sort -zV \
    | xargs -0 img2pdf -o "$out"
}
