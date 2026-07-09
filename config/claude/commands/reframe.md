---
description: Zoom out and re-examine this conversation's problem framing — original problem, frozen assumptions, alternative frames — then judge whether to stay the course, adjust, or reframe.
argument-hint: [optional focus hint] [--fresh]
---

Step out of the current line of discussion and re-examine the problem framing of **this conversation** — the problem definition, not the solution quality.

Arguments: a focus hint (`focus on the caching direction`), and/or `--fresh` (clean-context mode, below). Empty = whole discussion, inline.

## Rules

- The object under review is the problem definition, not the solution. Don't use this as an excuse to keep solving.
- Distinguish two moves: digging down finds the root cause within the current frame; pulling up questions the frame itself. This command pulls up — digging down is only meaningful after the frame is confirmed.
- Quote the original problem verbatim — rewriting it in your current understanding smuggles the frame in. If the original wording is no longer in context (e.g. compacted away), say so and label your version a reconstruction; never fake a quote.
- Honesty first: if on review the current frame still holds, say so and stop; don't invent alternative frames to justify the exercise.

## Output

1. **Original problem vs. problem being solved** — how the conversation first asked it (verbatim quote) vs. what is actually being solved now. The gap is the evidence of frame drift.
2. **Frozen assumptions** — premises accumulated along the way that were never validated (defining a problem freezes its context).
3. **Ask upward** — climb 2-3 levels of "why does this matter", using only motivations the conversation actually stated; where it has no answer, mark that level as a question for the user instead of inventing one.
4. **Alternative frames** — 0-3 concrete replacement problem definitions ("the elevator is slow" → "the wait is annoying"), not restatements of §3's chain. If none, say none.
5. **Verdict** — stay the course / adjust / reframe, with reasoning and confidence (high / medium / low). No fence-sitting. On adjust or reframe, end with the redefined problem in one sentence and ask the user to confirm adopting it.
6. **Next checkpoint** — name the next moment to re-examine (e.g., before converging on an implementation, when scope grows), and proactively remind when it arrives.

## --fresh (clean-context mode)

A conversation that has drilled deep inherits its own framing blind spots — including yours. With `--fresh`:

1. Complete sections 1-6 yourself first and commit to your verdict before reading the subagent's reply.
2. Package a brief for a clean-context subagent: the original problem (verbatim), the current conclusion or direction, the focus hint if given, and constraints **labeled by provenance** — user-stated (in or before the original ask, or externally imposed) vs. inferred during the discussion; inferred ones are inputs to question, not premises. Do **not** include the reasoning path.
3. Have the subagent treat the current direction as a hypothesis to refute, answering from its package alone: how it would define the problem, which given constraints it would question, the gap between the current direction and the original problem, alternative frames, and its own verdict.
4. Present both verdicts side by side, calling out divergences.

ARGUMENTS: $ARGUMENTS
