---
description: Create a git commit
allowed_tools:
  - Bash(git add:*)
  - Bash(git status:*)
  - Bash(git commit:*)
  - Bash(git remote:*)
  - Bash(git log:*)
---

Create a git commit for the current changes.

## Rules

- Use conventional commit format
- Commit message must explain WHY from an end-user perspective, not WHAT was changed
- Be specific — no generic messages like "improved experience" or "updated config"
- Do NOT stage files that may contain secrets (.env, credentials, tokens, etc.)
- If there are merge conflicts, DO NOT fix them — notify me and stop
- Match the commit style of recent commits
- Follow the git-commit-co-author skill rules for attribution
- Do NOT add any other AI attribution footer (e.g. "Generated with ...")
- Respond with tool calls only — no surrounding narrative

## Context

### git status

!`git status --short`

### git diff (unstaged)

!`git diff`

### git diff (staged)

!`git diff --cached`

### Recent commits

!`git log --oneline -10`

### Current branch

!`git branch --show-current`

<user-request>
$ARGUMENTS
</user-request>
