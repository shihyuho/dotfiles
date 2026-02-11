---
description: "Initialize Harvest second brain storage in docs/notes without creating a new context entry."
disable-model-invocation: true
---

Invoke the `harvest` skill and execute only the initialization part of the workflow.

Required actions:
1. Ensure `docs/notes/` structure exists (`contexts/`, `mocs/`, `00-INDEX.md`).
2. If `obsidian-bases` is available, create `docs/notes/contexts.base`.
3. Check `AGENTS.md` then `CLAUDE.md`; if lessons section is missing, ask before appending.

Stop after initialization.

Do not create or merge any `contexts/<context_id>-<topic>.md` file in this command.
