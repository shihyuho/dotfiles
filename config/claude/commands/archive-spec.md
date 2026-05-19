---
allowed-tools: Bash(git mv:*), Bash(git status:*), Bash(git ls-files:*), Bash(mv:*), Bash(mkdir:*), Bash(rmdir:*), Bash(ls:*), Bash(test:*)
description: Move SPEC.md, tasks/*, and implementation-notes (from agent-skills /spec /plan and the kickoff skill) into docs/features/<feature-name>/ so multiple features can coexist without overwriting each other.
---

## Context

- Repo root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- Inside git work tree: !`git rev-parse --is-inside-work-tree 2>/dev/null || echo "false"`
- Existing artifacts at root:
  - SPEC.md: !`test -f SPEC.md && echo "yes" || echo "no"`
  - tasks/plan.md: !`test -f tasks/plan.md && echo "yes" || echo "no"`
  - tasks/todo.md: !`test -f tasks/todo.md && echo "yes" || echo "no"`
  - implementation-notes.*: !`ls implementation-notes.md implementation-notes.html 2>/dev/null || echo "(none)"`
- SPEC.md first heading (used to derive feature name): !`head -n 5 SPEC.md 2>/dev/null | grep -m1 '^#' || echo "(no SPEC.md)"`
- Existing feature directories: !`ls -1 docs/features/ 2>/dev/null || echo "(none)"`

## Your Task

Archive the working artifacts produced by `agent-skills`'s `/spec` and `/plan` commands (`SPEC.md`, `tasks/plan.md`, `tasks/todo.md`) — plus the `implementation-notes.{md,html}` file from the `kickoff` skill, if present — into a feature-scoped directory:

```
docs/features/<feature-name>/
  spec.md
  plan.md
  todo.md
  implementation-notes.md   # or .html — only if it exists at root
```

This prevents the next `/spec` run from overwriting the current feature's artifacts and lets multiple features coexist (matches the proposal in addyosmani/agent-skills#50 / PR #73).

### Steps

1. **Bail out early** if no artifacts exist at the root. Report "nothing to archive" and stop.

2. **Derive `<feature-name>`**:
   - Prefer the title in `SPEC.md`'s first heading (e.g. `# Spec: User Authentication` → `user-authentication`).
   - If the user passed `$ARGUMENTS`, use that verbatim (already kebab-cased).
   - Slug rule: lowercase, ASCII, words joined by `-`, strip `Spec:` / `Feature:` prefixes.
   - If the derived directory `docs/features/<feature-name>/` already exists, ask the user whether to merge, pick a new name, or abort. Do not overwrite silently.

3. **Move the files**, preserving history when possible:
   - If inside a git work tree, use `git mv` for each file that exists.
   - Otherwise use plain `mv`.
   - Mapping:
     - `SPEC.md`        → `docs/features/<feature-name>/spec.md`
     - `tasks/plan.md`  → `docs/features/<feature-name>/plan.md`
     - `tasks/todo.md`  → `docs/features/<feature-name>/todo.md`
     - `implementation-notes.md` / `implementation-notes.html` → `docs/features/<feature-name>/` (keep the filename and extension; move whichever exists)
   - `mkdir -p docs/features/<feature-name>/` first.

4. **Clean up the empty `tasks/` directory** if and only if it is now empty (`rmdir tasks/` — never `rm -rf`).

5. **Do not commit.** Leave the moves staged so the user can review with `git status` and craft their own commit message.

6. **Report** the final layout (the new files under `docs/features/<feature-name>/`) and any leftover files in `tasks/` that were not moved.

### Constraints

- Never delete `SPEC.md`, `tasks/plan.md`, `tasks/todo.md`, or `implementation-notes.{md,html}` without moving them first.
- Never overwrite an existing file in `docs/features/<feature-name>/` — stop and ask.
- Never run `rm -rf` on `tasks/`. Use `rmdir` so it fails loudly if there are unexpected files.
- Do not modify the file contents — this command only relocates them.
