# claude-prompt — the prompt library, runnable from the terminal

Every prompt lives once, in Obsidian: `~/notes/90_system/prompts/<name>.md`. Each one runs the same way from two places:

- **Claude Code:** `/<name> …` (`~/.claude/commands/<name>.md` is a symlink to the prompt file)
- **Terminal:** `claude-<name> …` (a symlink to `claude-prompt`, which reads the same file)

| Prompt | Input | Result |
|---|---|---|
| `analyze-chapter` | `<PDF> <chapter> [page range] [-- focus]` | chapter analysis (14 sections) → note in `00_inbox` |
| `analyze-concept` | an idea, e.g. `the extended mind` | idea analysis (12 sections) → note; interactive, Claude may ask which idea you mean |
| `analyze-paper` | a PDF, URL or DOI of a technical paper | philosophical reading (12 sections) → note |
| `analyze-passage` | `<passage> [-- author, work, date]` | text and citation analysis → note |
| `ingest` | a URL, PDF or pasted text | source note + full text; interactive (asks which chapter for books) |
| `compare-concepts` | `<text A> -- <text B> [-- phenomenon]` | comparison of two conceptions (13 sections) → note |
| `apply-banlist` | a text or a file path | the text rewritten to follow the banlist (`ban` copies the list itself) |
| `apply-report-to-role` | `<report> -- <job ad> [-- CV]` | interview/role report in chat; interactive |

## Usage

| Command | What it does |
|---|---|
| `claude-analyze-chapter book.pdf 3 45-72 -- paragraph 4` | Arguments are passed to the prompt as `$ARGUMENTS`, exactly like `/analyze-chapter …` |
| `echo "text" \| claude-analyze-passage` | Input from a pipe |
| `claude-analyze-passage` | No input: opens your editor (lines starting with `%%` are ignored) |
| `claude-prompt --list` | List all prompts |
| `claude-prompt --link` | Recreate the `/name` and `claude-name` symlinks after adding, renaming or deleting a prompt |
| `CLAUDE_MODEL=opus claude-analyze-paper paper.pdf` | Use another model |

## How it works

The prompt's front matter controls everything, so the slash command and the terminal command behave the same:

- `allowed-tools`: what Claude may do (used by both Claude Code and `claude-prompt`).
- `run: headless` (`claude -p`, prints only the short reply) or `run: interactive` (a normal session; exit with `/exit` or Ctrl+D).
- `output: note`: after the run, the newest note in `00_inbox` gets a vault-unique name (`-2`, `-3`, … on a clash, governance §4), its path goes to `/tmp/last_zettel`, and it opens in nvim (not inside Neovim's terminal). `output: chat`: nothing more.
- Claude can read the vault, plus the folder of any file named in the input.

## Adding a prompt

1. Create `~/notes/90_system/prompts/<verb>-<object>.md` with front matter: `title`, `type: prompt`, `description`, `argument-hint`, `allowed-tools`, `run`, `output`. Put `$ARGUMENTS` where the input goes.
2. Run `claude-prompt --link`.

The old self-contained scripts (`claude-concept`, `claude-chapter`, `claude-passage`, `claude-phil-extract`) are kept as `*.bak-20261116-prompts`.
