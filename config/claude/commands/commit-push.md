---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*), Bash(git symbolic-ref:*), AskUserQuestion
description: Commit and push
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true`
- Recent commits: !`git log --oneline -10`

## Your task

You MUST invoke the git-commit-co-author skill before running git commit.

Based on the above changes:

1. Create a single commit with an appropriate message.
2. Push the branch to origin. **Safety gate:** If the current branch equals the default branch, STOP before pushing and use the AskUserQuestion tool to get explicit confirmation that pushing directly to the default branch is intended. Commit first regardless — only the push step gates on confirmation.

When pushing without confirmation (non-default branch), do all steps in a single message. Do not use any other tools or send any other text besides these tool calls.
