---
description: Create a git branch
agent: build
model: opencode/nemotron-3-ultra-free
subtask: true
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Create and switch to a new branch. If `$ARGUMENTS` specifies a branch name, use that. Otherwise derive a descriptive name from the diff (e.g. `feat/add-handoff-commands`); if there is no diff to derive from, stop and ask the user for a branch name.

You have the capability to call multiple tools in a single response. Do this in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.

$ARGUMENTS
