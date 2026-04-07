---
description: Commit, push, and open a PR
agent: build
model: opencode/minimax-m2.5-free
subtask: true
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`

## Your task

Invoke the git-commit-co-author skill.

Based on the above changes:

1. Create a new branch if on main
2. Create a single commit with an appropriate message.
3. Push the branch to origin
4. Create a pull request using `gh pr create`. If `.github/` contains a PR template, follow that format.

You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.

$ARGUMENTS
