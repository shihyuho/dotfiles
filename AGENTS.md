# Dotfiles Agent Guide

## Purpose

This repository manages modular dotfiles with three standing goals:
- keep interactive shell startup under `0.5s`
- keep symlink management safe and reversible
- treat repo files as the source of truth

## Required Routing

- Use the `dotfiles-manager` skill before changing dotfiles config, install/uninstall flows, or docs that define dotfiles workflows.
- Keep this file minimal. Move task-specific workflows and directory tours into skills or repo docs, not `AGENTS.md`.

## Core Contracts

- Edit files in this repo, not under `~`.
- If managed paths change, update `install.sh` and `uninstall.sh` together.
- Prefer conditional loading, lazy loading, caching, and minimal startup-time subprocesses.
- Never commit untested changes.
- Never commit `.secrets`, credentials, or other secret material.

## Safety Constraints

- Do not edit symlink targets in `$HOME` when the repo source exists.
- Do not delete files under `zsh/core/` unless explicitly requested.
- Keep module files focused; split them before they become hard to reason about.
- Keep `secrets.example` aligned with required secret names.

## Verification

- Run verification that matches the change before commit.
- For dotfiles/config changes, follow the `dotfiles-manager` verification flow: `zsh -n ~/.zshrc` and `make test`.
- If startup behavior changes or regresses, also run `make measure-startup` and keep every measured startup under `0.5s`.
