---
allowed-tools: Bash(git checkout --branch:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(git symbolic-ref:*), Bash(gh pr create:*), Read, AskUserQuestion
description: Commit, push, and open a PR
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null`

## Your task

You MUST invoke the git-commit-co-author skill before running git commit.

Based on the above changes:

1. Create a new branch if on the default branch.
2. Create a single commit with an appropriate message.
3. Push the branch to origin. **Safety gate:** If the push target is the default branch (step 1 was skipped for any reason), STOP and use the AskUserQuestion tool to get explicit confirmation first.
4. Create a pull request using `gh pr create`. If `.github/` contains a PR template, follow that format.

You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.
