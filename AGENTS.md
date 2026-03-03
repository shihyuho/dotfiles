# Dotfiles Agent Guide

## Purpose

This repository is a modular dotfiles system for fast startup, safe symlink management, and predictable AI-assisted maintenance.

Primary targets:
- Shell startup stays under 0.5s on every run.
- Configuration stays modular and easy to reason about.
- Repo files are always the source of truth (never edit symlink targets in `$HOME`).

## Core Rules

1. Edit files in this repo, not files under `~`.
2. Treat `install.sh` and `uninstall.sh` as one contract.
3. Keep startup cost low: prefer conditional loading, lazy loading, and caching.
4. Never commit untested changes.
5. Never commit secrets (`~/.secrets` is out of git).

## Lessons Learned

**MUST** use the `lessons-learned` skill before any execution

## Repository Map (High Level)

```text
dotfiles/
├── AGENTS.md
├── README.md
├── install.sh
├── uninstall.sh
├── zsh/
│   ├── rc.zsh
│   ├── env.zsh
│   ├── core/
│   ├── tools/
│   └── aliases/
├── git/
├── brew/
├── external/
├── manual/
├── misc/
└── docs/
```

## Zsh Loading Contract

### Core modules (`zsh/core/*.zsh`)
- Loaded in numeric filename order.
- Always loaded at startup.
- Keep startup overhead minimal.

Suggested order:
- `00-path.zsh`
- `10-completion.zsh`
- `20-history.zsh`
- `30-prompt.zsh`
- `90-syntax-highlighting.zsh`

### Tool modules (`zsh/tools/*.zsh`)
- Load only when the tool exists:

```zsh
command -v <tool> >/dev/null 2>&1
```

### Dev modules (`zsh/tools/dev/*.zsh`)
- Use lazy loading wrappers for slower initializers (for example nvm/pyenv/sdkman).

## Change Workflows

### Add a new tool

1. Add package to `brew/Brewfile`.
2. Create `zsh/tools/<tool>.zsh` (or `zsh/tools/dev/<tool>.zsh` if lazy-loaded).
3. Register loading in `zsh/rc.zsh`.
4. Update `docs/TOOLS.md`.
5. Run verification commands.

All new tool config files must include metadata header:

```zsh
#!/usr/bin/env zsh
# ---
# Tool: <tool name>
# Source: <URL>
# Purpose: <purpose>
# Updated: <YYYY-MM-DD>
# ---
```

### Remove a tool

1. Confirm it is not needed.
2. Check dependencies: `brew uses --installed <tool>`.
3. Remove from `brew/Brewfile` and related zsh config.
4. Remove or update docs (`docs/TOOLS.md`).
5. Run verification commands.

### Manage symlinked paths

If you add/remove managed paths:
- Update `install.sh` (`link_file ...`).
- Mirror the same change in `uninstall.sh` (`unlink_file ...`).

Never update only one side.

### PATH changes

Only update PATH in:
- `zsh/env.zsh` (early essentials)
- `zsh/core/00-path.zsh` (secondary path additions)

### External managed assets

Example alias update:

```bash
make update-aliases TARGET=kubectl
```

## Verification Requirements

Run after every modification:

```bash
zsh -n ~/.zshrc
for i in {1..5}; do /usr/bin/time -p zsh -i -c exit 2>&1 | grep real; done
zsh -i -c exit
ls -la ~ | grep "dotfiles"
make test-keybindings
```

Expected:
- Syntax check passes.
- Every startup run is under 0.5s.
- Symlinks are valid.
- Keybinding tests pass.

For full suite and convenience, you can also run:

```bash
make test
```

For startup bottlenecks:

```bash
make measure-startup
```

## CI Workflow Rules

All GitHub Actions workflows must:
- Test both `macos-latest` and `ubuntu-latest`.
- Include `workflow_dispatch`.
- Use matrix strategy (`fail-fast: false`).
- Include OS-specific setup steps when needed.

Reference workflows:
- `.github/workflows/verify.yml`
- `.github/workflows/test-keybindings.yml`

## Safety Constraints

Never:
- Delete files under `zsh/core/` unless explicitly requested.
- Modify symlink targets under `$HOME` when repo sources exist.
- Commit `.secrets` or credentials.
- Change loading order without understanding impact.
- Skip verification before committing.

Must:
- Keep module files focused (split if they grow too large).
- Keep startup-time subprocess use minimal.
- Keep `secrets.example` aligned with required sensitive variables.
- Update `AGENTS.md` and `README.md` when workflows/structure/rules change.

## Documentation Policy

All generated or updated documentation files must be written in English.

## Related Docs

- `README.md`
- `docs/INSTALL.md`
- `docs/SETUP.md`
- `docs/TOOLS.md`
- `docs/CI_TESTING.md`
- `.agents/skills/dotfiles-manager/SKILL.md`
