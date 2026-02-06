---
name: dotfiles-manager
description: Use when working in this modular dotfiles repository to add/remove tools, update external aliases, troubleshoot startup speed, or keep symlink-based configuration safe and consistent with AGENTS.md.
---

# Dotfiles Manager

Manage this repository's modular dotfiles setup with safe, repeatable workflows.

## Quick Routing

- Add a new tool -> `references/add-tool.md`
- Update external aliases -> `references/update-aliases.md`
- Optimize shell startup -> `references/optimize-startup.md`
- Remove unused tools -> `references/cleanup.md`
- Understand architecture/loading order -> `references/architecture.md`

## Mandatory First Steps

1. Read `AGENTS.md` in repo root for project rules.
2. Set environment variables:

```bash
DOTFILES_ROOT="<absolute-repo-path>"
ZSH_DIR="$DOTFILES_ROOT/zsh"
BREW_DIR="$DOTFILES_ROOT/brew"
DOCS_DIR="$DOTFILES_ROOT/docs"
```

3. Confirm this is the correct repo:

```bash
[[ -f "$DOTFILES_ROOT/AGENTS.md" ]] || echo "AGENTS.md not found"
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

Use `make measure-startup` when startup performance regresses.

## Built-in Utility Scripts

- `.agents/skills/dotfiles-manager/scripts/test.sh`: syntax + startup + symlink checks
- `.agents/skills/dotfiles-manager/scripts/check-tool-status.sh <tool>`: tool install/config/load status
- `.agents/skills/dotfiles-manager/scripts/check-dependencies.sh <tool>`: safe removal checks
- `.agents/skills/dotfiles-manager/scripts/update-aliases.sh [kubectl|gitalias|all]`: refresh alias sources
- `.agents/skills/dotfiles-manager/scripts/measure-startup.sh`: zprof-based startup analysis

## Common Pitfalls

- Updating `install.sh` without matching `uninstall.sh` update.
- Adding startup cost in `zsh/core/` (especially command substitutions).
- Changing docs/scripts but skipping `make test`.
- Writing tool config without file header metadata.
