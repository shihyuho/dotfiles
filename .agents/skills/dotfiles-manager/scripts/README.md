# Utility Scripts

Executable scripts for common dotfiles operations.

## Scripts

### test.sh
Tests dotfiles configuration.

**Usage**: `./scripts/test.sh`

**What it does**:
1. Syntax check: `zsh -n ~/.zshrc`
2. Startup speed test (5 iterations)
3. Symlink verification

**When to use**: After any configuration changes.

---

### update-aliases.sh
Updates external alias files from GitHub sources.

**Usage**: `./scripts/update-aliases.sh [kubectl|gitalias|all]`

**What it does**:
- `kubectl`: Updates kubectl-aliases from ahmetb/kubectl-aliases
- `gitalias`: Updates .gitalias from GitAlias/gitalias
- `all`: Updates both

**When to use**: Periodically to get latest aliases.

---

### check-tool-status.sh
Checks if a tool is properly installed and configured.

**Usage**: `./scripts/check-tool-status.sh <tool-name>`

**What it checks**:
1. In Brewfile?
2. Installed in PATH?
3. Config file exists?
4. Loaded in rc.zsh?

**When to use**: 
- Before adding a new tool
- Troubleshooting why a tool isn't working
- Verifying installation

---

### measure-startup.sh
Detailed startup speed analysis with zprof.

**Usage**: `./scripts/measure-startup.sh`

**What it does**:
- Temporarily enables zprof
- Shows function-level timing
- Displays performance guidelines

**When to use**: When startup speed exceeds 0.5s.

---

### check-dependencies.sh
Checks dependencies before removing a tool.

**Usage**: `./scripts/check-dependencies.sh <tool-name>`

**What it checks**:
1. Homebrew dependencies
2. Dotfile references
3. In Brewfile?
4. Is it required by other packages?

**When to use**: Before removing any tool.

---

## Common Workflows

### Adding a New Tool
```bash
# 1. Add to Brewfile
echo 'brew "tool-name"' >> brew/Brewfile

# 2. Install
brew bundle --file=brew/Brewfile

# 3. Check status
./scripts/check-tool-status.sh tool-name

# 4. Create config if needed
# vim zsh/tools/tool-name.zsh

# 5. Test
./scripts/test.sh
```

### Removing a Tool
```bash
# 1. Check dependencies
./scripts/check-dependencies.sh tool-name

# 2. If safe, remove from Brewfile
# vim brew/Brewfile

# 3. Remove config files
# rm zsh/tools/tool-name.zsh

# 4. Test
./scripts/test.sh
```

### Performance Optimization
```bash
# 1. Measure current performance
./scripts/measure-startup.sh

# 2. Identify bottlenecks (> 50ms)

# 3. Apply optimizations

# 4. Verify improvement
./scripts/test.sh
```

## Environment Variables

All scripts auto-detect `DOTFILES_ROOT`:
```bash
DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
```

Override if needed:
```bash
DOTFILES_ROOT=~/dotfiles ./scripts/test.sh
```

## Design Principles

- **Fail fast**: `set -e` in all scripts
- **Clear output**: Emojis + structured sections
- **Auto-detect**: No hardcoded paths
- **Guidance**: "Next steps" suggestions
- **Safety**: Always check before destructive operations
