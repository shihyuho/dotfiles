---
title: Preflight audit before dotfiles tool addition
type: knowledge
status: active
tags:
  - knowledge
  - project/add-zellij-and-yazi-to-dotfiles
summary: "Run a fast preflight audit to avoid duplicate implementation when adding tools."
source_files:
  - "../../findings.md"
  - "../../task_plan.md"
  - "../../progress.md"
source_date: 2026-02-13
---

# Knowledge: Preflight audit before dotfiles tool addition

## Insight

Before implementing any new tool in dotfiles, verify whether core assets already exist across package list, install scripts, shell wiring, and config directories.

## How to Apply

1. Check package presence in `brew/Brewfile`.
2. Check symlink handling in `install.sh` and `uninstall.sh`.
3. Check shell integration in `zsh/tools/` and registration in `zsh/rc.zsh`.
4. Check config artifacts under `config/<tool>/`.
5. Only implement what is missing, then run required verification.

## Caveats

- A file existing does not guarantee it matches current standards; still validate content quality.
- Avoid broad refactors while closing a single missing item.

## Source Pointers

- `../../findings.md`
- `../../task_plan.md`
- `../../progress.md`
