---
description: Commit, push, and open a pull request
allowed_tools:
  - Bash(git checkout --branch:*)
  - Bash(git add:*)
  - Bash(git status:*)
  - Bash(git commit:*)
  - Bash(git push:*)
  - Bash(git remote:*)
  - Bash(git log:*)
  - Bash(gh pr create:*)
  - Read
---

Commit, push, and open a pull request.

## Rules

- Use conventional commit format
- Commit message must explain WHY from an end-user perspective, not WHAT was changed
- Be specific — no generic messages like "improved experience" or "updated config"
- Do NOT stage files that may contain secrets (.env, credentials, tokens, etc.)
- If there are merge conflicts, DO NOT fix them — notify me and stop
- Match the commit style of recent commits
- Follow the git-commit-co-author skill rules for attribution
- Do NOT add any other AI attribution footer (e.g. "Generated with ...")
- You MUST do all steps in a single message
- Respond with tool calls only — no surrounding narrative

## Steps

1. Create a new branch if currently on main
2. Stage relevant files and create commit
3. Push branch to remote
4. Create pull request using `gh pr create`
   - Check `.github/` for PR templates (e.g. `PULL_REQUEST_TEMPLATE.md` or `.github/pull_request_template.md`) — if found, follow that format
   - Analyze ALL commits on the branch (not just the latest) for the PR description
   - Generate a comprehensive summary and test plan checklist

## Context

### git status

!`git status --short`

### git diff

!`git diff HEAD`

### Recent commits

!`git log --oneline -10`

### Current branch

!`git branch --show-current`

<user-request>
$ARGUMENTS
</user-request>
