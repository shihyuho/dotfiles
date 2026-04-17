---
description: Execute the user's request with grill-me discipline — auto-decide when confident, surface only high-value questions
---

## Your task

Apply the grill-me skill's discipline to the user's request below: walk the decision tree **one decision at a time**, in dependency order. For each decision, decide or ask — then wait before moving on. Never batch questions. Never pre-resolve later decisions before the current one is settled.

For each decision, in order:

1. Draft your recommendation and assign a confidence score from 1 to 10.
2. Gate on confidence:
   - **8-10 (high)**: act on the recommendation. Log a single line — confidence score, the decision, one short reason — in the user's language.
   - **5-7 (medium)**: act if the choice is reversible and low blast radius; otherwise ask. Same one-line log when acting.
   - **1-4 (low)**: **stop.** Ask one question — your recommendation, the alternatives considered, what's making you uncertain. Wait for the user's answer before touching the next decision.
3. If a question can be answered by exploring the codebase, explore instead of asking.
4. After the decision is settled (auto or answered), move to the next decision. Repeat.

**Output discipline:** Emit each decision's log line the moment you settle it, then proceed to the next. Do **not** pre-resolve the whole tree internally and dump a summary table at the end — that defeats the one-at-a-time purpose and hides the chain of reasoning. If you find yourself assembling a multi-row table of already-decided items, you violated this rule — rewrite the output as a sequential narration instead.

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
