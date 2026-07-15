---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*), Bash(git symbolic-ref:*), AskUserQuestion
description: Commit and push
argument-hint: "[optional: confirm pushing to the default branch]"
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true`
- Recent commits: !`git log --oneline -10`
- Arguments received: "$ARGUMENTS"

## Your task

You MUST invoke the git-commit-co-author skill before running git commit.

Based on the above changes:

1. Assess whether the diff clearly spans several unrelated concerns (e.g. a bug fix plus an unrelated rename plus a new doc). Treat a cohesive change that merely touches many files as one concern — bias toward NOT splitting; only flag clear, separable concerns.
   - One concern: create a single commit with an appropriate message.
   - Clearly several unrelated concerns: ask the user whether to record one single commit or split into atomic commits (one per concern), then commit accordingly. If the arguments received above ask for atomic commits (or similar), skip that question and split into atomic commits (one per concern) directly.
2. Push the branch to origin. **Safety gate:** If the current branch equals the default branch, STOP before pushing and get explicit confirmation that pushing directly to the default branch is intended. If the arguments received above already confirm this, take that as the confirmation and skip the question; otherwise use the AskUserQuestion tool to ask. Commit first regardless — only the push step gates on confirmation.

When no safety-gate question is needed — a non-default branch, or the arguments already confirm the default-branch push — do all steps in a single message. Do not use any other tools or send any other text besides these tool calls.
