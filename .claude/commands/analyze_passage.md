---
description: Deep text and citation analysis of a passage, saved (with the passage) as a Zettelkasten note
argument-hint: "<passage> [-- author, work, date]"
allowed-tools: Bash(date:*), Bash(test:*), Bash(ls:*), Bash(echo:*), Bash(find:*), Write, Read, WebSearch, WebFetch
---

# Deep Text and Citation Analysis

## Input

The raw input is between the markers below:

<<<INPUT
$ARGUMENTS
INPUT>>>

Parse it as follows:
- If the input contains a line or segment starting with `--`, everything before it is the **passage** and everything after it is the **author and source**.
- If there is no `--`, the whole input is the passage and the author/source is unknown. Try to verify the attribution with web search. If you can't verify it, say so plainly in section 4 and in the note; never guess an attribution and present it as fact.
- If the input is a path to an existing file, read the file and treat its contents as the passage (with an optional `--` source after the path).
- Preserve the passage exactly as given: same wording, line breaks and punctuation. Do not correct or "improve" it.

## Task

I want to understand the following passage as deeply as possible, including its explicit meaning, implicit assumptions, conceptual structure, intellectual context, and broader significance.

Analyze the text systematically, adapting the depth and method to the passage itself. Do not merely paraphrase it. Reconstruct its meaning, reasoning, and significance.

## 1. Plain-language explanation
- Restate the passage in clear, accessible language without losing its meaning.
- Explain what the author is trying to communicate.
- Identify the central claim, insight, question, or problem.
- If the passage is ambiguous, poetic, metaphorical, technical, or deliberately provocative, explain the relevant possibilities rather than forcing a single interpretation.

## 2. Close reading
- Unpack the passage sentence by sentence, clause by clause, or phrase by phrase where necessary.
- Explain the important words, technical terms, distinctions, metaphors, and formulations.
- Clarify what each part contributes to the whole.
- Identify emphases, contrasts, qualifications, presuppositions, and shifts in meaning.
- Explain why the author might have chosen this particular formulation rather than a simpler alternative.

## 3. Argument and conceptual structure
- Identify the passage's central claim and supporting claims.
- Reconstruct the reasoning step by step, where applicable.
- Distinguish premises, conclusions, examples, evidence, definitions, and rhetorical devices.
- Identify implicit assumptions and unstated inferential steps.
- Explain how the parts relate to one another and whether the reasoning is valid, plausible, incomplete, or ambiguous.
- If the passage is not making an argument, identify its actual function instead of forcing an argumentative structure onto it.

## 4. Context and intellectual background
- Explain the historical, biographical, disciplinary, or intellectual context necessary to understand the passage.
- Identify relevant concepts, debates, thinkers, traditions, or works that illuminate its meaning.
- Explain what the author may be responding to, rejecting, developing, or presupposing.
- Distinguish documented historical context from plausible interpretation.
- If the source or attribution is uncertain, state what can and cannot be verified.

## 5. Hidden assumptions and implications
- What does the passage take for granted?
- What does it imply without stating explicitly?
- What must be true for its central claim to hold?
- What follows if the author is correct?
- What does the passage not establish, even if its central claim is accepted?
- Identify important distinctions between what the text explicitly says, what it reasonably implies, and what a reader might infer more speculatively.

## 6. Examples and intuitive understanding
- Provide concrete examples that illustrate the passage's central idea.
- Where useful, give an analogy that makes its structure intuitive.
- Explain the limits of the analogy.
- If appropriate, provide a counterexample or contrasting case that reveals the idea's boundaries.
- Connect the abstract formulation to recognizable situations without reducing the original idea to an oversimplification.

## 7. Critical evaluation
- What is insightful, persuasive, original, or illuminating about the passage?
- What are its possible weaknesses, ambiguities, omissions, or unsupported assumptions?
- What are the strongest objections or alternative interpretations?
- How might the author or a sympathetic interpreter respond?
- Distinguish criticism of the passage's reasoning from disagreement with its conclusion.
- Give a reasoned assessment without assuming that the author is correct simply because the passage is influential or eloquently written.

## 8. Broader significance and connections
- How does the passage relate to the author's wider body of work, where relevant?
- How does it connect to other important ideas, theories, disciplines, or debates?
- Does it express a broader philosophical, scientific, political, ethical, or cultural position?
- What makes the passage significant beyond its immediate context?
- Identify only connections that clarify the passage, and explain the relationship rather than merely listing related thinkers or concepts.

## 9. Interpretive alternatives
- Are there multiple plausible readings of the passage?
- If so, explain the strongest interpretations and the textual evidence for each.
- Identify which interpretation is best supported, which remains uncertain, and what additional context would help resolve the ambiguity.
- Do not manufacture ambiguity where the meaning is reasonably clear.

## 10. Synthesis and retention
Conclude with:
- **Core meaning:** The passage's central point in one or two sentences.
- **Key concepts:** The essential terms and distinctions to understand.
- **Argument map:** A concise reconstruction of the reasoning, if applicable.
- **Underlying assumptions:** The most consequential unstated commitments.
- **Significance:** Why the passage is worth reading or remembering.
- **Critical question:** The most important question to ask about its claim.
- **Memorable takeaway:** A concise formulation that captures its central insight without distorting it.

## Methodological requirements
- Prioritize fidelity to the text over speculation about the author's intentions.
- Distinguish direct textual evidence, contextual knowledge, interpretive inference, and personal evaluation.
- Do not attribute claims to the author that the passage does not support.
- Use external sources when needed to verify attribution, recover context, or clarify disputed interpretations.
- Cite reliable sources for substantive contextual claims and provide precise references where available. Never invent citations: cite only sources you are confident exist, giving author, title and year, and a URL only if you actually retrieved it.
- If the passage is part of a larger work, explain how its surrounding context might affect its interpretation.
- Adapt the depth of each section to the passage; omit irrelevant sections rather than filling them with generic observations.
- Preserve important nuances, tensions, and ambiguities rather than forcing a neat conclusion.

The goal is to understand not only what the passage means, but how it produces that meaning, what it presupposes, why it matters, and how responsibly it can be interpreted and evaluated.

---

## Output: save as a Zettelkasten note

Do NOT print the full analysis in chat. Instead:

1. Get the timestamp: run `date '+%Y-%m-%d %H:%M:%S'`.
2. Title: `<Author Surname> – <short descriptive title of the passage's idea, 3–7 words>` in Title Case (e.g. "Wittgenstein – The Limits Of My Language"). If the author is unknown, use just the descriptive title.
3. Filename: take the title, lowercase it, keep only ASCII letters, digits and spaces, replace spaces with hyphens → `<slug>.md`. Full path: `/home/rene/notes/00_inbox/<slug>.md`. If `/home/rene/notes/00_inbox` doesn't exist, stop and report the error. Names must be unique across the vault: if `find /home/rene/notes -iname '<slug>.md'` finds anything, append `-2`, `-3`, … rather than overwriting.
4. Write the file with exactly this structure:

```markdown
---
title: "<Title>"
created: <timestamp>
type: source
status: developing
origin: claude
tags:
  - <tag from tags.md>
---
## <Title>

### Passage

> <the passage, verbatim; every line prefixed with "> ", blank lines as ">">
>
> — <Author>, *<Work>* (<Date>)   ← or "— Attribution unverified" if unknown

### 1. Plain-language explanation
...

### 2. Close reading
...

### 3. Argument and conceptual structure
...

### 4. Context and intellectual background
...

### 5. Hidden assumptions and implications
...

### 6. Examples and intuitive understanding
...

### 7. Critical evaluation
...

### 8. Broader significance and connections
...

### 9. Interpretive alternatives
...

### 10. Synthesis and retention
- **Core meaning:** ...
- **Key concepts:** ...
- **Argument map:** ...
- **Underlying assumptions:** ...
- **Significance:** ...
- **Memorable takeaway:** ...
- **Critical question:** ...

## Connections

## Sources

- <The passage's own source: Author, *Work* (Date), with page/section if known>

**Consulted** (opened during this session):
- Author, *Title* (Year). URL

**From general knowledge** (not checked in this session):
- Author, *Title* (Year)

## Questions
```

Rules for the note:
- **Governance:** this note follows `/home/rene/notes/90_system/governance.md` (§4 note format, §5 properties, §6 tags). If anything here conflicts with it, governance wins.
- **No blank line** between the closing `---` and `## <Title>`.
- **Tags:** 1–3 tags taken only from the Approved or Under review lists in `/home/rene/notes/90_system/tags.md` (read it). Never invent tags, and never use anything from its "Never use as tags" list (`resources`, `zettelkasten`, `from-claude`, `passage`, …). If no listed tag fits, use none and mention it in your chat reply.
- `## Connections` and `## Questions` are mine: leave both empty, just the heading. The daily curator adds Connections once I file the note; Questions only I ever write.
- All citations go under `## Sources`; inline, refer to them briefly (e.g. "Clark & Chalmers 1998"). Split them into **Consulted** (sources you actually opened in this session, with URL) and **From general knowledge** (everything else, no URL). Never put a source under Consulted that you did not open. Leave out an empty group.
- The passage's own source comes first under `## Sources`.
- Omit any numbered section that genuinely doesn't apply to this passage, rather than padding it.
- Section 8 is your analysis; it is not the vault's `## Connections`. The critical question stays in section 10, not under `## Questions`.
- The author's surname is not a tag (unless it is on the tags list, like `heidegger`).

5. Write the full path to `/tmp/last_zettel` (e.g. `echo "<path>" > /tmp/last_zettel`) so Neovim can open it.
6. Reply in chat with only: the path of the created note and the passage's core meaning in one sentence.
