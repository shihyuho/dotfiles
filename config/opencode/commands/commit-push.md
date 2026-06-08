---
description: Commit and push
agent: build
model: opencode/nemotron-3-ultra-free
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

1. Assess whether the diff clearly spans several unrelated concerns (e.g. a bug fix plus an unrelated rename plus a new doc). Treat a cohesive change that merely touches many files as one concern — bias toward NOT splitting; only flag clear, separable concerns.
   - One concern: create a single commit with an appropriate message.
   - Clearly several unrelated concerns: ask the user whether to record one single commit or split into atomic commits (one per concern), then commit accordingly.
2. Push the branch to origin. **Safety gate:** If the current branch equals the default branch, STOP before pushing and ask the user for explicit confirmation that pushing directly to the default branch is intended. Commit first regardless — only the push step gates on confirmation.

When recording a single commit and pushing without confirmation (non-default branch), do all steps in a single message. Do not use any other tools or send any other text besides these tool calls.

$ARGUMENTS
