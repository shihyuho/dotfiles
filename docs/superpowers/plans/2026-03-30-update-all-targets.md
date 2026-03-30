# Update-all Targets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `update-*` maintenance targets for brew, aliases, nvm, pyenv, and sdkman, plus an `update-all` aggregator that best-effort skips unavailable managers.

**Architecture:** Keep `make` as the public entrypoint and move branching logic into a single `scripts/update-packages.sh` helper. Reuse existing repo-managed flows (`brew/Brewfile`, `scripts/update-aliases.sh`) and only add manager-specific update commands where the repo already integrates those tools.

**Tech Stack:** Makefile, Bash, Homebrew, SDKMAN, zsh verification

---

### Task 1: Add maintenance update script and targets

**Files:**
- Create: `scripts/update-packages.sh`
- Modify: `Makefile`

- [ ] Add per-target and aggregate update entrypoints in `Makefile`.
- [ ] Implement a Bash helper that supports `brew`, `aliases`, `nvm`, `pyenv`, `sdkman`, and `all`.
- [ ] Make missing optional managers emit warnings and continue during `all`.

### Task 2: Document the new maintenance commands

**Files:**
- Modify: `README.md`

- [ ] Add `update-*` / `update-all` examples to the maintenance section.
- [ ] Keep wording aligned with the repo's existing `make`-first public interface.

### Task 3: Verify commands and repo health

**Files:**
- Modify: `progress.md`

- [ ] Run `make help` and confirm the new targets appear.
- [ ] Run selected update targets in a safe best-effort mode to confirm dispatch/skip behavior.
- [ ] Run `zsh -n ~/.zshrc` and `make test`.
- [ ] Record verification results in `progress.md`.
