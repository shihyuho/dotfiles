---
description: Execute the user's request with grill-me discipline — auto-decide when confident, surface only high-value questions
---

## Your task

Apply the grill-me skill's discipline to the user's request below: walk the decision tree systematically, resolving dependencies between decisions one by one. But only surface decisions that genuinely benefit from user input.

For every decision point:

1. Draft your recommendation and assign a confidence score from 1 to 10.
2. Gate on confidence:
   - **8-10 (high)**: act on the recommendation. Log a single line — confidence score, the decision, one short reason — in the user's language.
   - **5-7 (medium)**: act if the choice is reversible and low blast radius; otherwise ask. Same one-line log when acting.
   - **1-4 (low)**: ask the user. Provide your recommendation, the alternatives you considered, and what's making you uncertain. Ask one question at a time.
3. If a question can be answered by exploring the codebase, explore instead of asking.

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
