---
description: "Rebuild Harvest 00-INDEX.md from contexts and MOCs with a preview-before-write safety step."
---

Invoke the `harvest` skill and run index rebuild behavior using the index update responsibilities defined in `skills/harvest/SKILL.md` (`Workflow` Phase 3 Step 5 and Phase 4 Step 4) and `skills/harvest/references/index-template.md`.

## Steps

1. Read `docs/notes/00-INDEX.md`, `docs/notes/contexts/`, and `docs/notes/mocs/`.
2. Recompute index content from current notes according to skill-defined behavior.
3. Show a concise diff-style preview (what will change).
4. Ask for confirmation before writing.
5. Apply updates only after confirmation.

## Rules

- Preserve existing links that are still valid.
- Do not invent contexts or MOCs that do not exist.
- If no index exists, initialize one from template and report that action.

Finish with a short summary of changed sections.
