---
description: "Aggregate harvest review reports into one optimization roadmap file."
---

Invoke the `harvest:harvest` skill and follow it exactly as presented.

Treat this command as an optimize entrypoint.

If the user provides report directories, treat them as additional review input roots.

Use `skills/harvest/SKILL.md` as the single source of truth, specifically:

- `## Deterministic Workflow (Required)`
- `## Review Rollup Mode (Required)`
- `## Verification Checklist`

Write one rollup file under `docs/notes/harvest-quality/rollups/` using the rollup template contract.

Do not redefine rollup criteria, scoring aggregation, or roadmap schema in this command.
