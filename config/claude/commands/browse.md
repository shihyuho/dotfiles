---
allowed-tools: Bash(gh browse:*), Bash(git branch:*), Bash(git ls-remote:*)
description: Open the repo in the browser with gh browse, on the current branch when it's on the remote
---

## Context

- Current branch: !`git branch --show-current`

## Your task

Open the repository in the browser with `gh browse`. Run only the calls below and send no other text.

- If `$ARGUMENTS` is given, pass it straight through to `gh browse`.
- Otherwise, if the current branch is non-empty and `git ls-remote --exit-code --heads origin <branch>` succeeds, run `gh browse --branch <branch>`; else run `gh browse`.

$ARGUMENTS
