---
allowed-tools: Bash(git checkout --branch:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(git symbolic-ref:*), Bash(gh pr create:*), Read, AskUserQuestion
description: Commit, push, and open a PR
argument-hint: "[optional: confirm pushing to the default branch]"
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Default branch: !`git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true`
- Arguments received: "$ARGUMENTS"

## Your task

You MUST invoke the git-commit-co-author skill before running git commit.

Based on the above changes:

1. Create a new branch if on the default branch.
2. Assess whether the diff clearly spans several unrelated concerns (e.g. a bug fix plus an unrelated rename plus a new doc). Treat a cohesive change that merely touches many files as one concern — bias toward NOT splitting; only flag clear, separable concerns.
   - One concern: create a single commit with an appropriate message.
   - Clearly several unrelated concerns: ask the user whether to record one single commit or split into atomic commits (one per concern), then commit accordingly. If the arguments received above ask for atomic commits (or similar), skip that question and split into atomic commits (one per concern) directly.
3. Push the branch to origin. **Safety gate:** If the push target is the default branch (step 1 was skipped for any reason), STOP and get explicit confirmation first. If the arguments received above already confirm pushing to the default branch, take that as the confirmation and skip the question; otherwise use the AskUserQuestion tool to ask.
4. Create a pull request using `gh pr create`. If `.github/` contains a PR template, follow that format.

When no safety-gate question is needed — step 1 created a new branch, or the arguments already confirm the default-branch push — you have the capability to call multiple tools in a single response and SHOULD do all of the above in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.
