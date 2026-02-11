---
description: "Review relevant Harvest lessons before work using existing index and lessons MOC."
---

Read lesson sources and return a concise pre-work brief.

## Read Sources

1. `docs/notes/00-INDEX.md` (if exists)
2. `docs/notes/mocs/lessons-learned.md` (if exists)

## Selection Heuristic

Select lessons most relevant to the current task by:
- same technology/framework
- same operation type (async/state/API/integration)
- similar error pattern

## Output

- 3 to 7 bullets max
- each bullet includes: lesson title + why relevant + context link
- if no lessons match, state that clearly and suggest running `/harvest-capture` after the task

Do not write or modify files in this command.
