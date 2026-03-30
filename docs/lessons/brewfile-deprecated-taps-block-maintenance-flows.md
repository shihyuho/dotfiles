---
id: brewfile-deprecated-taps-block-maintenance-flows
date: 2026-03-30
scope: project
tags: [brew, brewfile, maintenance, taps, update]
source: bug-fix
confidence: 0.5
related: [[update-targets-must-match-manager-semantics]]
---

# Deprecated Brewfile taps can block maintenance flows even when formulas or casks still work

## Context
While running `make update-all`, Homebrew update errors were fixed first, but `brew bundle --file=brew/Brewfile` still failed because the Brewfile declared a deprecated tap.

## Mistake
I treated the broken run as a generic Homebrew update problem instead of checking whether the repo's Brewfile still declared obsolete taps that `brew bundle` would try to re-add.

## Lesson
- When `make update-all` or `brew bundle` fails after `brew update` succeeds, inspect `brew/Brewfile` for deprecated or removed taps.
- Remove obsolete taps from the repo source of truth, not just from the local machine, or maintenance flows will reintroduce the same failure.
- A cask or font may remain installable without its historical tap, so validate the actual dependency before keeping old tap declarations.

## When to Apply
Apply this when debugging Homebrew maintenance failures in this repo, especially after tap-related warnings or when `brew bundle` keeps re-tapping repositories that no longer exist or are now empty.
