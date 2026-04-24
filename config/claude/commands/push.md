---
allowed-tools: Bash(git push:*), Bash(git status:*), Bash(git log:*), Bash(git branch:*), Bash(git symbolic-ref:*)
description: Push current branch to origin
---

## Context

- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Default branch: !`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "(unknown)"`
- Recent commits: !`git log --oneline -10`
- Unpushed commits: !`git log @{u}..HEAD --oneline 2>/dev/null || echo "(no upstream or nothing to push)"`

## Your task

Push the current branch to origin.

**Safety gate:** If the current branch equals the default branch shown above, STOP before pushing. Tell the user you're about to push directly to the default branch and ask for explicit confirmation. Only after they confirm, run `git push`. If the current branch is NOT the default branch, push immediately without asking.

When pushing without confirmation (non-default branch), do it in a single message. Do not use any other tools or send any other text besides the push.
