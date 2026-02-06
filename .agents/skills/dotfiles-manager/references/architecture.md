# Dotfiles Architecture Principles (Generic)

Execution rule: use script entrypoints under `.agents/skills/dotfiles-manager/scripts/` for runnable checks.

## Design Goals
1. **Performance**: Shell startup time under 0.5s (every run)
2. **Modularity**: Configuration is grouped by responsibility for easier maintenance
3. **Portability**: Easy to sync across machines
4. **Extensibility**: Adding tools should not break existing setup

## Directory Structure Convention

```
dotfiles/
├── AGENTS.md            # AI agent guide (project-specific)
├── zsh/                 # Zsh configuration
│   ├── rc.zsh           # Main entry point (-> ~/.zshrc)
│   ├── env.zsh          # Environment variables (-> ~/.zshenv)
│   ├── core/            # Core config (always loaded, numeric order)
│   ├── tools/           # Tool config (conditional loading)
│   └── aliases/         # Alias categories
├── git/                 # Git configuration
├── brew/Brewfile        # Homebrew configuration
└── docs/                # Documentation
```

## Loading Strategy

### Core Configuration (`zsh/core/`)
- Loaded in numeric filename order (`00`, `10`, `20`, ...)
- Total startup cost should stay under 100ms
- Includes PATH, completion, history, and prompt

### Tool Configuration (`zsh/tools/`)
- Conditional loading (only if tool exists)
- Detect via `command -v <tool>`

### Development Tools (`zsh/tools/dev/`)
- Lazy loading (function wrapper with deferred init)
- Usually saves 50-200ms startup time

## Performance Optimization

### Forbidden
- Running subprocesses on startup, for example `$(brew --prefix)`
- Unconditional loading of very large files
- Repeatedly setting the same environment variables

### Recommended
- Hardcode common paths
- Use cache where possible
- Prefer conditional loading plus lazy loading

## Test Standard

```bash
bash .agents/skills/dotfiles-manager/scripts/test.sh
```

Target: under 0.5s
