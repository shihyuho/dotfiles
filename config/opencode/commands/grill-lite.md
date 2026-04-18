---
description: Execute the user's request with grill-me discipline — auto-decide when confident, surface only high-value questions
---

## Your task

Apply the grill-me skill's discipline to the user's request below: walk the decision tree **one decision at a time**, in dependency order. For each decision, decide or ask — then wait before moving on. Never batch questions. Never pre-resolve later decisions before the current one is settled.

For each decision, in order, emit a block in the user's language covering all four parts — never collapse to a one-liner:

- **Question** — what's being decided, in one sentence.
- **Options considered** — the main alternatives and the tradeoff between them (bullets).
- **Judgment** — confidence 1-10, reversibility, blast radius, and the reason in one sentence.
- **Recommendation / Ask** — the chosen answer (when acting) or the question back to the user (when asking).

Then gate on confidence:

- **8-10 (high)**: lock in the recommendation; move to the next decision.
- **5-7 (medium)**: lock in if the choice is reversible and low blast radius; otherwise stop and ask.
- **1-4 (low)**: **stop.** Present the block ending with your question; wait for the user's answer before touching the next decision.

If a question can be answered by exploring the codebase, explore instead of asking. Read-only exploration is allowed during this phase.

**Execution gate:** After every decision is settled, summarize the plan in 3-6 bullets and **stop**. Wait for the user's explicit go-ahead before starting implementation — edits, writes, or any mutating command. Even when every decision was high-confidence, the user confirms direction before any code is written. High confidence means "I don't need to ask mid-way", not "I can skip the final check-in".

**Output discipline:** Emit each decision's block the moment you settle it, then proceed to the next. Do **not** pre-resolve the whole tree internally and dump a batch summary at the end — that defeats the one-at-a-time purpose. The execution-gate summary is the plan for the user to confirm, not a replay of decisions already logged.

### High confidence (auto-decide)

- Codebase patterns or user conventions give a clear answer
- Decision is reversible and low blast radius
- Alternatives converge on similar outcomes

### Low confidence (ask)

- Decision locks in architecture, naming, or scope that's hard to undo
- Valid paths have meaningfully different tradeoffs
- User intent is ambiguous and can't be inferred from context
- The choice reflects taste not derivable from the repo

Only surface questions that actually change what you do. Don't ask to validate — ask to decide.

$ARGUMENTS
