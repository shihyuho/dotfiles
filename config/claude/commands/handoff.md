---
description: Save session context before /clear or /compact
---

## Context

- Current branch: !`git branch --show-current`
- Working tree status: !`git status --short`
- Recent commits: !`git log --oneline -5`
- Planning files present: !`ls task_plan.md progress.md findings.md 2>/dev/null || echo "(none)"`

## Your task

Write a `.handoff.md` file in the project root that captures the current session's working context so a fresh session can continue seamlessly.

Use this structure:

```markdown
# Session Handoff

**Timestamp:** <ISO 8601>
**Branch:** <current branch>

## What We Were Working On
<1-3 sentence summary>

## Key Decisions
- <decision and rationale — only non-obvious ones>

## Current State
- <what's done, in progress, or blocked>

## Next Steps
1. <ordered by priority>

## Important Context
<gotchas, constraints, or anything a fresh session needs to know — omit if empty>
```

Rules:
- Be concise — this is a briefing, not a transcript
- Focus on what a cold-start session needs to pick up the work
- If planning files (task_plan.md, progress.md, findings.md) exist, do NOT duplicate their content — just note their presence in the handoff. They will be read separately on restore. Only record context that lives outside those files: conversation-level decisions, verbal constraints, things not yet written down
- Overwrite any previous `.handoff.md`
- After writing, print the full content of `.handoff.md` so the user can verify before clearing

$ARGUMENTS
