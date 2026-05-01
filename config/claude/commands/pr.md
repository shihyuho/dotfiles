---
allowed-tools: Bash(git checkout --branch:*), Bash(git status:*), Bash(git push:*), Bash(git symbolic-ref:*), Bash(git log:*), Bash(git branch:*), Bash(gh pr create:*), Read, AskUserQuestion
description: Open a PR for the current branch
---

## Context

- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null`
- Commits ahead of default: !`git log --oneline origin/HEAD..HEAD 2>/dev/null`

## Your task

Based on the above context:

1. If the current branch equals the default branch, abort and tell the user to switch to a feature branch first.
2. Push the branch to origin if not already pushed. **Safety gate:** If for any reason the push target is the default branch, STOP and use the AskUserQuestion tool to get explicit confirmation first.
3. Create a pull request using `gh pr create`. If `.github/` contains a PR template, follow that format.

You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.
