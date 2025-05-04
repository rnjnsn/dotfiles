export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='
--height=100%
--layout=reverse
--border
--preview="bat --color=always {} || cat {}"
--header="Press Ctrl+L to open file, Ctrl+R to open directory"
--bind="ctrl-l:execute(bash -c \"~/.local/bin/public-scripts/fzopen \\\"{}\\\"\")+abort"
--bind="ctrl-r:execute(bash -c \"cd \\\"$(dirname {})\\\" && lf\")"
'
