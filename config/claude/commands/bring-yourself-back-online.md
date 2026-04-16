---
description: Restore context from a previous session handoff
---

## Context

- Handoff file: !`cat .handoff.md 2>/dev/null || echo "NO_HANDOFF_FOUND"`
- Current branch: !`git branch --show-current`
- Working tree status: !`git status --short`
- Recent commits: !`git log --oneline -10`
- Planning files present: !`ls task_plan.md progress.md findings.md 2>/dev/null || echo "(none)"`

## Your task

Restore session context from the handoff file above.

1. If `NO_HANDOFF_FOUND`: tell the user there is no handoff to restore and offer to review git log and working tree status instead.
2. Otherwise:
   - Parse the **Timestamp** field from the handoff. If it is older than 24 hours, warn the user with the age (e.g. "This handoff is 3 days old") and ask whether to proceed or discard it — do NOT internalize stale context without confirmation
   - Internalize the handoff context
   - If planning files exist, read them too
   - Present a concise summary of where things left off and the next steps
   - Ask the user what they want to work on

Do not delete `.handoff.md` — the user decides when to clean up.

$ARGUMENTS
