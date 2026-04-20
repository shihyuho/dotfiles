---
description: Grill-me in quick mode — auto-decide confident calls with rationale shown, ask only when uncertain or high-risk
---

## Your task

Apply the grill-me skill to the user's target.

```
for each grill-me question:
  decision point?
    ├ no  → continue
    └ yes → draft answer + self-score 1–10 → passes gate below?
              ├ yes → lock in, surface {question, alternatives, score+reason, answer}
              └ no  → ask user
```

Confidence gates:

- **8-10**: lock in the decision; move to the next question.
- **5-7**: lock in if the choice is reversible and low blast radius; otherwise stop and let the user answer.
- **1-4**: stop and let the user answer.

$ARGUMENTS
