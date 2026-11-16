---
description: Deep, critical analysis of an idea, saved as a Zettelkasten note in your notes inbox
argument-hint: "<idea>"
allowed-tools: Bash(date:*), Bash(test:*), Bash(ls:*), Bash(echo:*), Bash(find:*), Write, Read, WebSearch, WebFetch
---

# Deep Analysis of an Idea: $ARGUMENTS

I want to develop a deep, precise, and critical understanding of the following idea:

**$ARGUMENTS**

Explain it in a way that enables me to understand not only what it is, but why it exists, how it works, what makes it significant, and how to evaluate it independently.

Structure your analysis around the following questions, adapting them to the nature of the idea rather than mechanically applying every question.

**1. Meaning and essence**
- What is the idea, stated as clearly and precisely as possible?
- What is its central insight?
- What is the simplest way to understand it intuitively?
- What does it mean, and what does it not mean?
- Which distinctions are essential to understanding it correctly?

**2. The problem and motivation**
- What question, problem, observation, need, or dissatisfaction gives rise to the idea?
- Why does this problem matter?
- What would remain unexplained, unresolved, or misunderstood without the idea?
- What makes the idea worth considering?

**3. Origins and context**
- Where does the idea come from, and under what circumstances did it emerge?
- What intellectual, historical, scientific, social, or practical context helps explain its development?
- Which earlier ideas influenced it, and what did it change, challenge, or build upon?
- Distinguish the origin of the idea from the origin of the problem it addresses.

**4. Internal structure and mechanism**
- How does the idea work, conceptually, logically, causally, or practically?
- What are its constituent parts, underlying assumptions, and essential relationships?
- Reconstruct its reasoning step by step, where applicable.
- What makes its conclusion follow from its premises, or its proposed mechanism produce its claimed result?
- Identify hidden assumptions, ambiguities, and potential gaps in reasoning.

**5. Examples and applications**
- Provide concrete examples that make the idea understandable.
- Show how it applies in practice, where relevant.
- Include a case where it works well and a case where its application becomes questionable or fails.
- Explain what the examples demonstrate and what they do not establish.

**6. Connections and intellectual landscape**
- How does the idea relate to other important ideas, theories, disciplines, or traditions?
- What does it share with them, and what distinguishes it?
- Which related concepts are necessary for understanding it?
- Does it depend on, contradict, extend, or challenge other ideas?
- Map the most important relationships without creating superficial connections.

**7. Evidence, justification, and explanatory power**
- What reasons, evidence, arguments, observations, or experiences support the idea?
- What kind of justification is appropriate for its subject matter?
- What does it explain, illuminate, predict, or enable us to do?
- Which claims are well established, which are plausible, and which remain speculative or contested?
- What evidence or reasoning would weaken the idea?

**8. Criticism and alternatives**
- What are the strongest objections to the idea?
- What are the best alternative explanations, theories, or approaches?
- Where are the genuine disagreements, and what assumptions drive them?
- How might a knowledgeable defender respond to the strongest criticism?
- After considering both sides, which arguments are most convincing, and why?

**9. Development and present significance**
- How has the idea evolved, been interpreted, or been challenged over time?
- What is its current standing in the relevant fields or communities?
- What is its significance today, and what practical or theoretical consequences follow from it?
- What remains unresolved, and what developments could change our understanding of it?

**10. Boundaries, implications, and consequences**
- What follows if the idea is correct?
- What does it not establish, and where does its explanatory power end?
- What further assumptions are needed to move from the idea to stronger conclusions?
- What are its broader implications, including unintended consequences where relevant?
- Under what conditions would accepting or applying it be justified?

**11. Overall assessment**
- What are the idea's greatest strengths and weaknesses?
- How important is it relative to competing ideas?
- What is the strongest defensible version of the idea?
- What should a reasonable person believe about it, and with what degree of confidence?
- Which questions are most important for reaching a more definitive judgment?

**12. Conceptual synthesis**
Conclude by providing:
- A concise explanation of the idea in plain language.
- Its central insight in one sentence.
- A map of its problem, assumptions, mechanism, justification, implications, and limitations.
- The most important distinctions needed to avoid misunderstanding it.
- One or two powerful examples that capture its essence.
- The most important unresolved question.
- A short list of the most valuable next topics to explore for deeper understanding.

## Instructions for the analysis

Begin with the simplest useful explanation and progressively develop greater precision and depth. Make the reasoning explicit rather than merely listing facts. Use examples to clarify abstract claims, not to substitute for arguments.

Adapt the analysis to the type of idea. A scientific theory requires attention to empirical evidence and prediction; a philosophical argument requires logical reconstruction and conceptual distinctions; a mathematical idea requires definitions, derivations, and proofs where appropriate; a political or moral idea requires attention to values, institutions, consequences, and competing principles. Do not force every framework onto every subject.

Distinguish description from evaluation, historical influence from truth, correlation from causation, and a claim's plausibility from its evidential support. Represent opposing positions fairly without assuming they are equally strong.

Use reliable sources when factual, historical, or scholarly claims warrant them (use web search to check current standing and recent developments). Cite substantive claims, identify significant disagreements, and be transparent about uncertainty. Do not invent consensus or manufacture controversy. Never invent citations: cite only sources you are confident exist, giving author, title and year, and a URL only if you actually retrieved it.

Prioritize explanatory depth, conceptual precision, and intellectual coherence over length, exhaustive coverage, or impressive terminology. Avoid repetition and superficial name-dropping.

The ultimate goal is to build a connected mental model that allows me to explain the idea in my own words, recognize it in unfamiliar contexts, evaluate its strengths and weaknesses, and understand what follows from accepting or rejecting it.

---

## Output: save as a Zettelkasten note

Do NOT print the full analysis in chat. Instead:

1. Get the timestamp: run `date '+%Y-%m-%d %H:%M:%S'`.
2. Title: the idea in Title Case.
3. Filename: take the title, lowercase it, keep only ASCII letters, digits and spaces, replace spaces with hyphens → `<slug>.md`. Full path: `/home/rene/notes/00_inbox/<slug>.md`. If `/home/rene/notes/00_inbox` doesn't exist, stop and report the error. Names must be unique across the vault: if `find /home/rene/notes -iname '<slug>.md'` finds anything, append `-2`, `-3`, … rather than overwriting.
4. Write the file with exactly this structure:

```markdown
---
title: "<Title Case Idea>"
created: <timestamp>
type: note
status: developing
origin: claude
tags:
  - <tag from tags.md>
---
## <Title Case Idea>

### 1. Meaning and essence
...

### 2. The problem and motivation
...

### 3. Origins and context
...

### 4. Internal structure and mechanism
...

### 5. Examples and applications
...

### 6. Connections and intellectual landscape
...

### 7. Evidence, justification, and explanatory power
...

### 8. Criticism and alternatives
...

### 9. Development and present significance
...

### 10. Boundaries, implications, and consequences
...

### 11. Overall assessment
...

### 12. Conceptual synthesis
(plain-language explanation, one-sentence insight, map, key distinctions, essential examples, most important unresolved question, next topics to explore)

## Connections

## Sources

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
- Section 6 is your analysis of the idea's intellectual landscape; it is not the vault's `## Connections`. The unresolved question and next topics stay inside section 12, not under `## Questions`.

5. Write the full path to `/tmp/last_zettel` (e.g. `echo "<path>" > /tmp/last_zettel`) so Neovim can open it.
6. Reply in chat with only: the path of the created note and a two-sentence summary of the idea.
