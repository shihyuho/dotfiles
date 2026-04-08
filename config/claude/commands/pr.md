---
allowed-tools: Bash(git checkout --branch:*), Bash(git status:*), Bash(git push:*), Bash(gh pr create:*), Read
description: Open a PR for the current branch
---

## Context

- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Commits ahead of main: !`git log --oneline main..HEAD 2>/dev/null || echo "(none — may already be on main or main ref missing)"`

## Your task

Based on the above context:

1. If on main, abort and tell the user to switch to a feature branch first.
2. Push the branch to origin if not already pushed.
3. Create a pull request using `gh pr create`. If `.github/` contains a PR template, follow that format.

You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.
