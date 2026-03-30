---
id: update-targets-must-match-manager-semantics
date: 2026-03-30
scope: project
tags: [dotfiles, maintenance, make, package-managers, semantics]
source: user-correction
confidence: 0.7
related: [[dotfiles-skill-workflows-must-edit-repo-source]]
---

# Update targets must match each manager's actual maintenance semantics

## Context
While adding `update-*` make targets for this dotfiles repo, I initially mapped version-manager targets to commands that upgraded the manager binary or listed remote versions.

## Mistake
I assumed each manager should expose a symmetric `update-*` target even when the underlying tool did not have a matching maintenance command. This led to misleading targets like `update-sdkman` using `sdk selfupdate`, and `update-nvm` being approximated with `nvm ls-remote`.

## Lesson
- For maintenance targets, name and behavior must follow the tool's real semantics, not an invented cross-tool symmetry.
- If a manager has a true metadata refresh command (for example `sdk update`), use it.
- If a manager has no equivalent maintenance command and the closest option is really a listing or a binary upgrade, prefer removing the target over shipping a misleading one.

## When to Apply
Apply this when adding or reviewing repo-level `make` targets that wrap heterogeneous package/version managers, especially when trying to normalize commands like update, refresh, or install across tools with different CLIs.
