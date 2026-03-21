---
name: dotfiles-manager
description: "Use when modifying modular dotfiles repos with shell/tool modules, aliases, package manifests, install/uninstall symlink flows, startup-performance work, or dotfiles workflow docs."
---

# Dotfiles Manager

Manage this repository's modular dotfiles setup with safe, repeatable workflows.

## Dotfiles Trigger Scope

Use this skill for dotfiles-configuration tasks, including:

- Updating shell configs, tool modules, aliases, env/bootstrap scripts, and package manifests
- Managing symlink contracts and install/uninstall lifecycle safely
- Dotfiles-focused renames/refactors/cleanup and setup-document updates
- Startup performance tuning, troubleshooting, and verification/test runs
- Any dotfiles change where project rules in `AGENTS.md` should be enforced

If unsure whether a task is dotfiles-related, load this skill first and then route to the matching reference workflow.

## Quick Routing

- Add a new tool -> `references/add-tool.md`
- Manage Brew packages or `brew/Brewfile` -> `references/brew-workflow.md`
- Update external aliases -> `references/update-aliases.md`
- Optimize shell startup -> `references/optimize-startup.md`
- Remove unused tools -> `references/cleanup.md`
- Understand architecture/loading order -> `references/architecture.md`

## Mandatory First Steps

1. Read `AGENTS.md` in repo root for project rules.
2. Set the repo root:

```bash
DOTFILES_ROOT="<absolute-repo-path>"
```

3. Confirm this is the correct repo:

```bash
[[ -f "$DOTFILES_ROOT/AGENTS.md" ]] || echo "AGENTS.md not found"
```

4. Set remaining environment variables:

```bash
ZSH_DIR="$DOTFILES_ROOT/zsh"
BREW_DIR="$DOTFILES_ROOT/brew"
DOCS_DIR="$DOTFILES_ROOT/docs"
```

## Hard Safety Rules

- Never edit symlink targets in `$HOME` when the source file exists in repo; edit repo files instead.
- Never delete files under `zsh/core/` unless explicitly requested.
- Keep `install.sh` and `uninstall.sh` in sync for any managed path changes.
- Prefer conditional loading and lazy loading; avoid startup-time subprocesses.
- Never commit unless the user explicitly asks.

## Verification Standard

Run after every modification:

```bash
zsh -n ~/.zshrc
make test
```

Use `make measure-startup` when startup behavior, load order, or performance may have changed.

Prefer `make` targets as the public workflow entrypoints; use scripts under `.agents/skills/dotfiles-manager/scripts/` when you need the implementation detail directly.

## Built-in Utility Scripts

- `.agents/skills/dotfiles-manager/scripts/create-tool-config.sh <tool> <source-url> <purpose> [tools|dev]`: generate tool config skeleton with required metadata
- `.agents/skills/dotfiles-manager/scripts/install-brew-bundle.sh`: install packages from `brew/Brewfile`
- `.agents/skills/dotfiles-manager/scripts/test.sh`: syntax + startup + symlink checks
- `.agents/skills/dotfiles-manager/scripts/check-tool-status.sh <tool>`: tool install/config/load status
- `.agents/skills/dotfiles-manager/scripts/check-dependencies.sh <tool>`: safe removal checks
- `.agents/skills/dotfiles-manager/scripts/update-aliases.sh [kubectl|gitalias|all]`: refresh alias sources
- `.agents/skills/dotfiles-manager/scripts/measure-startup.sh`: zprof-based startup analysis

## Common Pitfalls

- Updating `install.sh` without matching `uninstall.sh` update.
- Updating a managed file via `$HOME/...` instead of the repo source.
- Adding startup cost in `zsh/core/` (especially command substitutions).
- Changing docs/scripts but skipping `make test`.
- Treating heavy dev tools as eager startup work instead of lazy-loading shims.
- Writing tool config without file header metadata.
