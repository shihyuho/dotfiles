# Shell Startup Performance

Use this guide when shell startup regresses, load order changes, or a dotfiles change may affect interactive shell latency.

## Guardrails

- Keep interactive shell startup under `0.5s`
- Edit repo sources, not managed paths under `$HOME`
- Verify with `make test`; profile with `make measure-startup`

## Start Here

Run the normal verification first:

```bash
make test
```

If the change affects startup behavior, load order, or shell responsiveness, run detailed profiling:

```bash
make measure-startup
```

## Repo Hotspots

- `zsh/rc.zsh`: top-level load order and tool registration
- `zsh/core/`: always-loaded startup code
- `zsh/tools/`: regular tool config behind conditional loading
- `zsh/tools/dev/`: lazy-loading shims for heavy dev tools

## Common Problem Patterns

### Startup subprocesses

Avoid running commands like `$(brew --prefix)` during shell startup. Prefer hardcoded common paths, cached values, or deferred initialization.

### Large files loaded unconditionally

Large alias or helper files should be conditionally loaded or lazy-loaded, especially when they depend on tools that may not be installed.

### Heavy dev-tool initialization

Tools like `nvm`, `pyenv`, and `sdkman` should use lightweight repo shims in `zsh/tools/dev/`, with the expensive init deferred until first use.

### Completion and prompt work

Avoid rebuilding completion state or running external commands on every prompt render. Prefer caching and time-bounded refreshes.

## Fix Principles

- Prefer conditional loading over unconditional `source`
- Use lazy wrappers for expensive tool initialization
- Cache values used during prompt rendering
- Keep always-loaded `zsh/core/` files minimal

## Verify After Changes

```bash
zsh -n ~/.zshrc
make test
```

If the change touched startup behavior, also run:

```bash
make measure-startup
```
