---
description: "Rebuild Harvest 00-INDEX.md from contexts and MOCs with a preview-before-write safety step."
---

Recompute and repair Harvest index metadata from existing notes.

## Steps

1. Read `docs/notes/00-INDEX.md`, `docs/notes/contexts/`, and `docs/notes/mocs/`.
2. Recalculate index sections using `references/INDEX_TEMPLATE.md` structure:
   - Stats
   - Recent Updates (top 5)
   - Topics (MOCs)
   - Key Decisions
   - Open Questions
   - Recent Lessons
3. Show a concise diff-style preview (what will change).
4. Ask for confirmation before writing.
5. Apply updates only after confirmation.

## Rules

- Preserve existing links that are still valid.
- Do not invent contexts or MOCs that do not exist.
- If no index exists, initialize one from template and report that action.

Finish with a short summary of changed sections.
