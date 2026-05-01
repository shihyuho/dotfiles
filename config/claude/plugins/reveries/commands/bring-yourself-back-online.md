---
description: Restore context from a previous session handoff
---

## Context

- Handoff file: !`cat .handoff.md 2>/dev/null`
- Current branch: !`git branch --show-current`
- Working tree status: !`git status --short`
- Recent commits: !`git log --oneline -10`
- Planning files present: !`ls task_plan.md progress.md findings.md 2>/dev/null`
- Current time (UTC): !`date -u +%Y-%m-%dT%H:%M:%SZ`

## Your task

Restore session context from the handoff file above.

1. If the handoff file is empty or missing: tell the user there is no handoff to restore and offer to review git log and working tree status instead.
2. Otherwise:
   - Compare the **Branch** field from the handoff with "Current branch" from Context. If they differ, warn the user clearly (e.g. "Handoff was saved on `feat/x` but you're now on `main`") and ask whether to proceed or abort — do NOT internalize cross-branch context without confirmation
   - Parse the **Timestamp** field from the handoff. Compare it to "Current time (UTC)" from Context. If the handoff is older than 24 hours, warn the user with the age (e.g. "This handoff is 3 days old") and ask whether to proceed or discard it — do NOT internalize stale context without confirmation
   - Internalize the handoff context
   - If planning files exist, read them too
   - Present a concise summary of where things left off and the next steps
   - Ask the user what they want to work on

Do not delete `.handoff.md` — the user decides when to clean up.

$ARGUMENTS
