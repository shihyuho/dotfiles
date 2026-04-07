---
description: Commit and push
agent: build
model: opencode/minimax-m2.5-free
subtask: true
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

You MUST invoke the git-commit-co-author skill before running git commit.

Based on the above changes:

1. Create a single commit with an appropriate message.
2. Push the branch to origin

You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.

$ARGUMENTS
