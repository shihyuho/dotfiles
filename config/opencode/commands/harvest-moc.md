---
description: "Create or update Harvest topic MOCs from existing context notes with confirmation-first behavior."
---

Invoke the `harvest` skill and execute MOC management behavior from `Workflow` Phase 3 Step 6 in `skills/harvest/SKILL.md`.

Use confirmation-first behavior for any file writes.

## Rules

- Keep link-based structure; do not duplicate full context bodies.
- If user does not confirm, do not write files.
- Keep updates compact and reversible.

Finish with a short summary of updated files.
