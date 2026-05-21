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
- Adding or modifying any JSON config file
- Docs that define dotfiles maintenance workflows

## Hard Landmines

- Prefer `make` targets as the public entrypoint; treat scripts as implementation details unless the repo docs say otherwise
- Tool-loading changes should keep heavy init behind repo shims and lazy loading, not eager startup init

## Verification Matrix

- Default: `zsh -n ~/.zshrc` and `make test`
- Startup/load-order/performance changes: also run `make measure-startup`
- Added or edited a JSON file: ensure it declares a `"$schema"`, then run `make test-json` (also covered by `make test`)

## Routing

- Add or change tool config -> follow repo patterns in `zsh/tools/` and `zsh/tools/dev/`
- Update external aliases -> use `make update-aliases` or the matching helper
- Brew package changes -> use `make brew`
- Dependency check before removal -> use `make check-deps TOOL=<name>`
- Startup/load-order/performance work -> use `make measure-startup` and `docs/performance/startup.md`
- Add or change a JSON config -> keep its `"$schema"` set and validate with `make test-json` (`scripts/validate-json-schemas.sh`)
- Deeper implementation details -> read repo docs or script help, not this skill
