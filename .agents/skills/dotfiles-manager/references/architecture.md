# Dotfiles Architecture and Routing

Execution rule: use `make` targets for standard workflows and scripts under `.agents/skills/dotfiles-manager/scripts/` for direct helpers.

## Repo-Specific Layout

```text
dotfiles/
|- AGENTS.md
|- install.sh / uninstall.sh
|- brew/Brewfile
|- zsh/
|  |- rc.zsh
|  |- env.zsh
|  |- core/
|  |- tools/
|  `- aliases/
|- external/
|- docs/
`- .agents/skills/dotfiles-manager/
```

## Source-of-Truth Rules

- Edit repo files, not managed paths under `$HOME`.
- If `install.sh` creates a symlink, the repo-side source remains the thing to edit.
- If managed paths change, update `install.sh` and `uninstall.sh` together.

## Loading Order

`zsh/rc.zsh` loads in this order:

1. `zsh/env.zsh`
2. every file in `zsh/core/` in numeric order
3. regular tools via `_load_tool_if_exists()`
4. dev-tool shims via direct `source`
5. aliases
6. optional `$HOME/.secrets`

## Tool Patterns

- Regular tools: keep config in `zsh/tools/<tool>.zsh` and load with `_load_tool_if_exists()` from `zsh/rc.zsh`.
- Heavy dev tools: keep a lightweight shim in `zsh/tools/dev/<tool>.zsh`; `zsh/rc.zsh` sources the shim, and the shim lazy-loads the expensive init on first use.
- Alias assets managed from upstream should live in the repo when they are installed via symlink.

The `_load_tool_if_exists()` helper is defined in `zsh/rc.zsh`.

## Verification Routing

- Default verification after edits: `zsh -n ~/.zshrc` and `make test`
- Startup or load-order changes: also run `make measure-startup`
- Use direct scripts only when debugging workflow internals or when a specific helper is the task entrypoint

## Quick Task Routing

- New tool or tool config: `references/add-tool.md`
- Brew package changes: `references/brew-workflow.md`
- External alias refresh: `references/update-aliases.md`
- Startup tuning: `references/optimize-startup.md`
- Safe tool removal: `references/cleanup.md`
