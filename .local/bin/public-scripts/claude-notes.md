# claude-* — Claude analyses saved as Zettelkasten notes

Four scripts that hand a text to Claude Code and get back a note in `~/notes/00_inbox`, which then opens in nvim.

| Script | Input | Kind of note |
|---|---|---|
| **`claude-concept`** | an idea, e.g. "the cognitive revolution" | deep, critical analysis of the idea (12 sections) |
| **`claude-passage`** | a passage of text (and its source) | text and citation analysis |
| **`claude-chapter`** | a PDF and a chapter number, optionally one passage of it | deep analysis of the chapter (14 sections) |
| **`claude-phil-extract`** | a PDF of a technical paper | philosophical reading of the paper (12 sections) |

You need the `claude` command on your PATH and logged in. All notes follow `~/notes/90_system/governance.md` (§4–6): `type`, `status` and `origin: claude` as properties, no blank line after the front matter, and 1–3 tags taken only from `~/notes/90_system/tags.md` (approved or under review). Claude never invents tags; if none fits, the note gets none and Claude suggests one in its reply. The three scripts read the tag list at run time and pass it into the prompt; `claude-passage` reads it itself. Notes end with empty `## Connections` (the curator fills it after you file the note) and `## Questions` (yours alone) sections, and a `## Sources` section that separates sources Claude actually opened from ones cited from memory.

## Usage

| Command | What it does |
|---|---|
| `claude-concept` | Asks for the idea |
| `claude-concept the extended mind` | Same, in one line |
| `claude-passage "text"` | Analyzes the text given as arguments |
| `echo "text" \| claude-passage` | Text from a pipe |
| `claude-passage` | Opens your editor to paste the text (lines starting with `%%` are ignored; add the source on its own last line, e.g. `-- Wittgenstein, Tractatus (1921)`) |
| `claude-chapter` | Asks for the PDF, chapter, page range and focus |
| `claude-chapter book.pdf 3` | Whole chapter 3 |
| `claude-chapter book.pdf 3 45-72` | Chapter 3, with the PDF page range given (faster and more reliable) |
| `claude-chapter -f "paragraph 4" book.pdf 3` | Only one passage; the chapter is used as context |
| `claude-chapter -f "p. 52, paragraph 2" -p 45-72 book.pdf 3` | Passage plus page range. Options must come before the PDF |
| `claude-chapter -h` | Help |
| `claude-phil-extract paper.pdf` | Analyzes the paper (asks for the PDF if you leave it out) |

## How they differ

- **`claude-concept` is interactive.** It opens a normal Claude session, because a short phrase can be ambiguous and Claude may ask which idea you mean. You can ask follow-up questions. Exit Claude (`/exit` or Ctrl+D) to open the note.
- **The others run headless** (`claude -p`) and take a few minutes. Nothing is printed except a short reply; the analysis goes into the note.
- **Where the prompt lives:** `claude-concept`, `claude-chapter` and `claude-phil-extract` carry their prompt at the bottom of the script itself; edit it there. `claude-passage` reads `~/.claude/commands/analyze_passage.md` (the same file as the `/analyze_passage` command in Claude Code) and stops if it's missing.
- **What Claude may do:** read and write files, search and fetch the web, and run `ls`, `pdfinfo` and `pdftotext` (`claude-passage`: `date`, `ls`, `test`, `echo`, `find`). It can only write in the inbox and, for PDFs, read the PDF's folder. `claude-passage` is the exception: it can read the whole vault (to check `tags.md` and that the note name is unique), and only its prompt keeps its writes in the inbox.

## Notes

- **Note names:** the title lowercased with hyphens, e.g. `after-virtue-chapter-15.md`. An existing note is never overwritten; `-2`, `-3`, … is added. After Claude finishes, the script also checks the whole vault (governance §4: links resolve by name) and renames the new note to the next free `-N` if a note with that name exists anywhere in `~/notes`, saying so in the terminal.
- **Titles:** `claude-chapter` uses `<Book> — Chapter N` (plus e.g. `, Paragraph 4` for a focus) and records the book, chapter, passage and PDF path in the front matter. `claude-phil-extract` records the paper and PDF path.
- **Model:** set `CLAUDE_MODEL` to use another model, e.g. `CLAUDE_MODEL=opus claude-chapter book.pdf 3` (not `claude-passage`).
- The new note's path is saved to `/tmp/last_zettel` (like `zet`). Inside Neovim's terminal it isn't opened; the path is printed instead.
- If Claude didn't write a note, the script says "no new note found".

## Test checklist

1. **Concept:** run `claude-concept`, give an ambiguous phrase like "functionalism". Claude should ask which one you mean. After `/exit`, the note should open in nvim.
2. **Passage:** run `claude-passage` with no input, paste a short quote with a `-- Source` line, save and quit. A note should be created and opened.
3. **Empty passage:** run `claude-passage`, quit the editor without typing. It should say "Nothing to analyze."
4. **Chapter:** run `claude-chapter book.pdf 1 1-20`. The note title should be `<Book> — Chapter 1`.
5. **Focus:** run `claude-chapter -f "paragraph 2" book.pdf 1`. The note should have a `passage` field and a `### The passage` section.
6. **Bad page range:** run `claude-chapter book.pdf 1 abc`. It should say the range must look like `45-72`.
7. **Paper:** run `claude-phil-extract paper.pdf`. The note should have `origin: claude` and only tags from `tags.md`.
8. **Same title twice:** run the same chapter again. The second note should end in `-2`.
