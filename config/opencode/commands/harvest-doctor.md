---
description: "Audit Harvest second brain consistency and report fix candidates without writing by default."
---

Run a read-first health check for Harvest notes.

Use `skills/harvest/SKILL.md` and `skills/harvest/references/context-template.md` as the source of truth for validation criteria.

## Checks

1. Structure checks:
   - `docs/notes/00-INDEX.md`
   - `docs/notes/contexts/`
   - `docs/notes/mocs/`
2. Context integrity:
   - required frontmatter and section structure from the harvest context template
   - malformed or missing section anchors
3. Link integrity:
   - broken links from index/MOCs to context files
   - lesson links pointing to missing anchors
4. Consistency checks:
   - index counts vs actual files
   - referenced MOCs that do not exist

## Output

- Severity buckets: `high`, `medium`, `low`
- For each issue: file path, reason, and suggested fix
- Suggested next command:
  - `/harvest-reindex` for index drift
  - `/harvest-moc` for MOC repair
  - `/harvest-capture` after current work

Do not modify files unless the user explicitly asks for fixes after the report.
