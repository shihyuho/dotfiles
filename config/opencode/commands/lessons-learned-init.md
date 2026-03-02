---
description: "Initialize lessons-learned setup"
---

Run setup for project instruction files.

## Required Flow

1. **Detect project instruction files**
   - Check `AGENTS.md` and `CLAUDE.md` at the project root.
   - Treat every existing file as a target file.
   - If neither file exists, ask which file to create, create it at project
     root, and treat it as target.

2. **Enforce canonical lessons block**
   - For each target file, check whether equivalent mandatory wording already
     exists.
   - If equivalent wording exists, do not add another lessons block.
   - If equivalent wording does not exist, add this canonical block:

   ```markdown
   ## Lessons Learned

   **MUST** use the `lessons-learned` skill before any execution
   ```

3. **Avoid duplication**
   - If multiple equivalent mandatory blocks exist, keep one canonical copy and
     remove duplicates.

Execute only this flow for this invocation. Do not run other actions unless the
user explicitly asks.
