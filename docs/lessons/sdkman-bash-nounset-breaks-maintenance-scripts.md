---
id: sdkman-bash-nounset-breaks-maintenance-scripts
date: 2026-03-30
scope: project
tags: [sdkman, bash, maintenance, shell, nounset]
source: bug-fix
confidence: 0.5
related: [[update-targets-must-match-manager-semantics]]
---

# SDKMAN scripts are not safe to source or invoke under bash nounset mode

## Context
After the Homebrew portion of `make update-all` passed, the SDKMAN refresh step failed inside `sdkman-init.sh` and `sdkman-main.sh` because the maintenance helper script used `set -u`.

## Mistake
I assumed SDKMAN's shell scripts were compatible with strict `bash` nounset semantics, but they dereference unset positional and shell-version variables during initialization and command dispatch.

## Lesson
- When a repo maintenance script runs with `set -u`, disable `nounset` temporarily around `source "$SDKMAN_DIR/bin/sdkman-init.sh"` and the immediate `sdk ...` invocation.
- Re-enable `set -u` immediately after the SDKMAN call so the rest of the helper script keeps strict-shell protections.
- Treat third-party shell bootstrap scripts as compatibility boundaries; do not assume they are strict-mode safe.

## When to Apply
Apply this when integrating SDKMAN commands into Bash automation for this repo, especially maintenance helpers or CI-like flows that use `set -euo pipefail`.
