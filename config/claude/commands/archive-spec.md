---
allowed-tools: Bash(git mv:*), Bash(git status:*), Bash(git ls-files:*), Bash(mv:*), Bash(mkdir:*), Bash(rmdir:*), Bash(ls:*), Bash(test:*), Read, Edit, Grep
description: Move SPEC.md, tasks/*, and implementation-notes (from agent-skills /spec /plan and the kickoff skill) into docs/features/<feature-name>/ so multiple features can coexist without overwriting each other, rewriting cross-references between the moved files to their new paths.
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

4. **Rewrite cross-references between the moved files.** After the move the files are renamed and co-located, so any link from one moved file to another now points at a stale path. Scan the *content* of each file you just moved and update only the references that target another file in this moved set:
   - Every moved file now lives side by side in `docs/features/<feature-name>/`, so each surviving cross-reference becomes a bare sibling filename. Resolve any `./` / `../` prefix before matching, then map the old reference to the new one:
     - `SPEC.md`                                   → `spec.md`
     - `tasks/plan.md` (or bare `plan.md`)         → `plan.md`
     - `tasks/todo.md` (or bare `todo.md`)         → `todo.md`
     - `implementation-notes.md` / `.html`         → same filename
   - Cover Markdown link targets `[text](path)`, inline-code paths `` `path` ``, and — if `implementation-notes.html` was moved — HTML `href="path"`.
   - Mind the case change: `SPEC.md` → `spec.md`. Only rewrite the path inside a link/reference; do not touch human-readable link text or prose unless it is itself a path.
   - Rewrite references **only** among the files this command moved. Leave every other line untouched, and never edit files outside the moved set.

5. **Clean up the empty `tasks/` directory** if and only if it is now empty (`rmdir tasks/` — never `rm -rf`).

6. **Do not commit.** Leave the moves staged so the user can review with `git status` and craft their own commit message.

7. **Report** the final layout (the new files under `docs/features/<feature-name>/`), any cross-references that were rewritten, and any leftover files in `tasks/` that were not moved.

### Constraints

- Never delete `SPEC.md`, `tasks/plan.md`, `tasks/todo.md`, or `implementation-notes.{md,html}` without moving them first.
- Never overwrite an existing file in `docs/features/<feature-name>/` — stop and ask.
- Never run `rm -rf` on `tasks/`. Use `rmdir` so it fails loudly if there are unexpected files.
- Do not modify file contents beyond the step 4 cross-reference rewrite — no rewording, reformatting, or other edits.
