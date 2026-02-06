# Optimizing Shell Startup Speed

## Measure Current Speed

### Basic Test

```bash
# Run 5 times and compare
for i in {1..5}; do
  /usr/bin/time -p zsh -i -c exit 2>&1 | grep real
done
```

Target: under 0.5s (maximum 1s)

### Detailed Profiling

Use `zprof` to identify bottlenecks:

```zsh
# Add at the top of ~/.zshrc
zmodload zsh/zprof

# Add at the bottom
zprof
```

Run `zsh` to view per-function timing.

## Common Bottlenecks and Fixes

### 1) Subprocesses on startup

**Issue**: Commands like `$(brew --prefix)` run every shell startup.

Wrong:
```zsh
PATH="$(brew --prefix)/bin:$PATH"
```

Preferred:
```zsh
# Hardcode common paths
PATH="/opt/homebrew/bin:$PATH"  # Apple Silicon
```

### 2) Unconditional loading of large files

**Issue**: Large alias files (for example, kubectl aliases) are always loaded.

Wrong:
```zsh
source ~/.kubectl_aliases
```

Preferred:
```zsh
if command -v kubectl >/dev/null 2>&1; then
  source ~/.kubectl_aliases
fi

# Or lazy-load the file on demand
kalias() {
  source ~/.kubectl_aliases
  unset -f kalias
}
```

### 3) Heavy dev-tool initialization

**Issue**: nvm/pyenv/sdkman can add 50-200ms during startup.

Wrong:
```zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

Preferred (lazy loading):
```zsh
export NVM_DIR="$HOME/.nvm"

_nvm_load() {
  unset -f nvm node npm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

nvm()  { _nvm_load; nvm "$@"; }
node() { _nvm_load; node "$@"; }
npm()  { _nvm_load; npm "$@"; }
```

### 4) Rebuilding completion every time

**Issue**: `compinit` rebuilds completion cache too often.

Wrong:
```zsh
compinit
```

Preferred (smart cache):
```zsh
if [[ ! -s "$ZSH_COMPDUMP" || "$HOME/.zshrc" -nt "$ZSH_COMPDUMP" ]]; then
  compinit -d "$ZSH_COMPDUMP"
else
  compinit -C -d "$ZSH_COMPDUMP"
fi
```

### 5) Running external commands in prompt render

**Issue**: Prompt executes git commands every time it renders.

Wrong:
```zsh
PROMPT='$(git branch 2>/dev/null | grep "^\*" | cut -d " " -f2)'
```

Preferred (cache + TTL):
```zsh
typeset -g __GIT_SEG=""
typeset -g __GIT_LAST_TS=0

_git_segment_update() {
  local now=$EPOCHSECONDS
  [[ $(( now - __GIT_LAST_TS )) -lt 2 ]] && return
  __GIT_LAST_TS=$now
  __GIT_SEG="$(git branch 2>/dev/null | grep '^\*' | cut -d ' ' -f2)"
}

add-zsh-hook precmd _git_segment_update
PROMPT='${__GIT_SEG}'
```

## Optimization Checklist

After each change, verify:

- [ ] No `$(command)` executed during startup
- [ ] Large files are conditionally loaded or lazy-loaded
- [ ] Dev tools use lazy loading
- [ ] Completion cache is configured correctly
- [ ] Prompt uses cached data where possible
- [ ] Startup time is under 0.5s

## Performance Budget

| Item | Target | Recommendation |
|------|--------|----------------|
| PATH setup | < 5ms | Hardcode common paths |
| Completion init | < 50ms | Smart cache |
| History setup | < 5ms | Keep simple |
| Prompt setup | < 10ms | Cache git info |
| Syntax highlighting | < 20ms | Load last |
| Conditional tool load | < 10ms/tool | Use `command -v` |
| Lazy-load wrappers | < 5ms/tool | Function wrappers |

Overall target: under 150ms (core) + under 50ms (tools) = under 200ms
