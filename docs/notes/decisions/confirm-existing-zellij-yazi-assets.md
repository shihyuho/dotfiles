---
title: Confirm existing zellij and yazi assets
type: decision
status: final
tags:
  - decision
  - project/add-zellij-and-yazi-to-dotfiles
summary: "Reuse existing zellij/yazi assets and focus only on missing and pending integration items."
source_files:
  - "../../task_plan.md"
  - "../../findings.md"
source_date: 2026-02-13
---

# Decision: Confirm existing zellij and yazi assets

## Conclusion

Do not recreate zellij/yazi setup that already exists; continue work only on missing `config/yazi/theme.toml` and remaining integration tasks.

## Context and Rationale

Exploration showed that package entries, install linking, and zsh tool wrappers for both tools are already present. Rebuilding those pieces would add noise and increase drift risk without improving outcomes.

## Impact

- Scope is reduced to unresolved gaps.
- Follow-up implementation can focus on theme consistency and verification.
- Future contributors can run the same preflight check before adding tools.

## Source Pointers

- `../../task_plan.md`
- `../../findings.md`
