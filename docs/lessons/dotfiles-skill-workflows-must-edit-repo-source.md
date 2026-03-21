---
id: dotfiles-skill-workflows-must-edit-repo-source
date: 2026-03-21
scope: project
tags: [dotfiles, skills, source-of-truth, symlinks, workflows]
source: retrospective
confidence: 0.3
related: []
---

# Dotfiles skill workflows must edit repo sources, not home-path symlink targets

## Context
While auditing the `dotfiles-manager` skill package, the alias update workflow and helper script were compared against the repo contracts in `AGENTS.md`, `install.sh`, and `uninstall.sh`.

## Mistake
The workflow updated `$HOME/.kubectl_aliases` directly even though that path is managed as a symlink to `external/kubectl_aliases` inside the repository.

## Lesson
- When a dotfiles path in `$HOME` is managed by `install.sh`, skill workflows and helper scripts must update the repo-side source file instead of the home-path symlink target.
- Audit skill docs and scripts together, because workflow text can reinforce the same incorrect mental model as the implementation.

## When to Apply
Apply this when writing or reviewing dotfiles skills, helper scripts, or maintenance workflows that touch managed files under `$HOME`, especially alias files, shell integration assets, and other symlinked resources.
