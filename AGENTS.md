# Dotfiles Agent Guide

## Purpose

This repository manages modular dotfiles with three standing goals:
- keep interactive shell startup under `0.5s`
- keep symlink management safe and reversible
- treat repo files as the source of truth

## Core Contracts

- Edit files in this repo, not under `~`.
- If the user installs or removes a package, mirror it in `brew/Brewfile` (or the relevant repo config) so the repo stays the source of truth.
- Conversely, when the user adds or removes a package in `brew/Brewfile`, run the matching `brew install`/`brew uninstall` so the system matches the repo.
- If managed paths change, update `install.sh` and `uninstall.sh` together.
- If package/tool maintenance flows change, update the relevant `make` entrypoints and workflow docs together, not just the underlying scripts.
- Don't add a `version` field to `.claude-plugin/marketplace.json` or any plugin's `.claude-plugin/plugin.json` — Claude plugins use commit-SHA versioning (every commit is a new version); a pinned version freezes installed users on a stale snapshot.
- Keep heavy tool-loading behind repo shims and lazy loading, not eager startup init.
- Never commit untested changes.
- Never commit `.secrets`, credentials, or other secret material.

## Routing

Prefer `make` targets as the public entrypoint; treat scripts as implementation details unless repo docs say otherwise.

- Tool config -> follow repo patterns in `zsh/tools/` and `zsh/tools/dev/`.
- External aliases -> `make update-aliases`.
- Brew package changes -> `make brew`.
- Dependency check before removal -> `make check-deps TOOL=<name>`.

## Safety Constraints

- Do not edit symlink targets in `$HOME` when the repo source exists.
- Do not delete files under `zsh/core/` unless explicitly requested.
- Keep `secrets.example` aligned with required secret names.

## Verification

- Run verification that matches the change before commit.
- Default: `zsh -n ~/.zshrc` and `make test`.
- Startup/load-order/performance changes: also run `make measure-startup`; keep interactive shell startup under `0.5s`.
- JSON config: ensure it declares a `"$schema"`, then run `make test-json` (also covered by `make test`).
