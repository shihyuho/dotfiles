---
id: worktree-test-symlink-checks-require-primary-root
date: 2026-03-25
scope: project
tags: [dotfiles, worktree, testing, symlink, verification]
source: retrospective
confidence: 0.3
related: ["[[dotfiles-skill-workflows-must-edit-repo-source]]"]
---

# Worktree test symlink checks require the primary repo root

## Context
While preparing Yazi config changes in a git worktree, `make test` passed syntax and startup checks but failed the symlink verification step.

## Mistake
I assumed the repo test suite would behave the same in a worktree as it does in the main workspace.

## Lesson
- In this repo, `make test` verifies that managed files in `$HOME` point at the current `DOTFILES_ROOT`, so a worktree fails if your live symlinks still target the primary checkout.
- For changes that must pass the full repo verification, prefer working in the primary checkout or be ready to temporarily repoint managed symlinks before testing.

## When to Apply
Apply this when planning or verifying dotfiles changes from a `git worktree`, especially before relying on `make test` as a clean baseline check.
