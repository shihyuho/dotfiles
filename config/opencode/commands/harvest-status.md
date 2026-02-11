---
description: "Show Harvest second brain status at a glance (index, contexts, MOCs, and recent activity)."
---

Read and summarize Harvest state from the current project.

## What to Check

1. `docs/notes/00-INDEX.md` exists or not
2. `docs/notes/contexts/` exists and rough context count
3. `docs/notes/mocs/` exists and whether `lessons-learned.md` exists
4. Most recent 3 updates from index (if available)
5. Open questions count (if index section available)

## Output Format

```text
Harvest Status

Index: {present|missing}
Contexts: {count or unknown}
MOCs: {count or unknown}
Lessons MOC: {present|missing}
Recent updates: {up to 3 bullets}
Open questions: {count or unknown}
```

## If Not Initialized

```text
Harvest is not initialized in this project.
Run /harvest-init first.
```

Keep output brief and actionable.
