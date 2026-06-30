---
allowed-tools: Bash(git status:*), Bash(git checkout:*), Bash(git switch:*), Bash(git branch:*), Bash(git diff:*), Bash(git log:*), Bash(gh issue view:*), Bash(gh issue develop:*)
description: Create a git branch
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Create and switch to a new branch.

**Issue-linked branch (preferred when an issue is in play).** If `$ARGUMENTS` is an issue number/URL, or the current conversation is clearly working on a specific GitHub issue, create the branch with `gh issue develop <issue> --name <name> --checkout` so the branch is linked to that issue. Derive `<name>` from the issue's title/content — read it with `gh issue view <issue> --json number,title,body` if you don't already have it — e.g. issue #42 "Add handoff commands" → `feat/42-add-handoff-commands`. If `$ARGUMENTS` also gives an explicit branch name, use that as `<name>` but still link via `gh issue develop`.

**Plain branch (no issue).** If `$ARGUMENTS` specifies a branch name, use that. Otherwise derive a descriptive name from the diff (e.g. `feat/add-handoff-commands`); if there is no diff to derive from, stop and ask the user for a branch name. Create and switch with `git switch -c <name>`.

You have the capability to call multiple tools in a single response. Do this in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.

$ARGUMENTS
