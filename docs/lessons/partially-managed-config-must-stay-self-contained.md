---
id: partially-managed-config-must-stay-self-contained
date: 2026-03-30
scope: project
tags: [dotfiles, config, source-of-truth, portability, claude]
source: retrospective
confidence: 0.3
related: [[dotfiles-skill-workflows-must-edit-repo-source]]
---

# Partially managed config must stay self-contained until dependencies are repo-managed

## Context
While bringing `~/.claude/settings.json` under dotfiles management, the first draft copied the existing local file into `config/claude/settings.json`.

## Mistake
The copied config still depended on unmanaged `~/.claude/hooks/*` files and machine-specific absolute paths under `/Users/matt`, so the repo version was not a portable source of truth.

## Lesson
- If a dotfiles repo starts managing only one config file from a larger tool directory, that managed file must remain self-contained.
- Do not commit references to unmanaged helper files, hook directories, or machine-specific absolute paths until those dependencies are also repo-managed.

## When to Apply
Apply this when incrementally bringing tool configs into a dotfiles repo, especially when the first managed file comes from a larger home-directory tree that still has local-only helpers or runtime assets.
