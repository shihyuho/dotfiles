---
name: dotfiles-manager
description: Use when changing dotfiles config, managed symlink flows, shell startup behavior, or dotfiles workflow docs in this repository.
---

# Dotfiles Manager

Use this skill as a routing and landmine layer, not as a handbook.

## When to Use

- Shell config, aliases, env/bootstrap, or tool-loading changes
- Managed path changes tied to `install.sh` and `uninstall.sh`
- Startup-performance or load-order changes
- Docs that define dotfiles maintenance workflows

## Hard Landmines

- Edit repo sources, not managed files under `$HOME`
- If a managed path changes, update `install.sh` and `uninstall.sh` together
- Heavy dev tools use repo shims plus lazy loading, not eager startup init
- Startup-related changes must keep interactive shell startup under `0.5s`

## Verification Matrix

- Default: `zsh -n ~/.zshrc` and `make test`
- Startup/load-order/performance changes: also run `make measure-startup`

## Routing

- Add or change tool config -> follow repo patterns in `zsh/tools/` and `zsh/tools/dev/`
- Update external aliases -> use `make update-aliases` or the matching helper
- Brew package changes -> use `make brew`
- Dependency check before removal -> use `make check-deps TOOL=<name>`
- Startup/load-order/performance work -> use `make measure-startup` and `docs/performance/startup.md`
- Deeper implementation details -> read repo docs or script help, not this skill
