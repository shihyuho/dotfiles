# Dotfiles Agent Guide

**Owner**: ShihYu Ho
**Repository**: https://github.com/shihyuho/dotfiles  
**Last Updated**: 2026-02-06

## Project Overview

This is a modular dotfiles management system designed with the following goals:
- ⚡ Startup speed < 0.5s (max 1s)
- 📁 Clear modular structure
- 🔗 Symlink mode (changes take effect immediately)
- 🤖 AI-friendly (easy for AI to help maintain)

## Architecture Principles

### Directory Structure

```
dotfiles/
├── AGENTS.md                   # This file: AI agent guide
├── README.md                   # User documentation
├── install.sh                  # Symlink installation script
├── uninstall.sh                # Symlink uninstallation script
│
├── .agents/                    # AI collaboration tools (project-level)
│   └── skills/
│       └── dotfiles-manager/   # Dedicated skill
│
├── zsh/                        # Zsh configuration modules
│   ├── rc.zsh                  # Main entry point (→ ~/.zshrc)
│   ├── env.zsh                 # Environment variables (→ ~/.zshenv)
│   ├── core/                   # Core configs (always loaded, numeric order)
│   │   ├── 00-path.zsh
│   │   ├── 10-completion.zsh
│   │   ├── 20-history.zsh
│   │   ├── 30-prompt.zsh
│   │   └── 90-syntax-highlighting.zsh
│   ├── tools/                  # Tool configs (conditional loading)
│   │   ├── kubectl.zsh
│   │   ├── docker.zsh
│   │   ├── fzf.zsh
│   │   ├── zoxide.zsh
│   │   ├── lazygit.zsh
│   │   ├── ghq.zsh
│   │   └── dev/                # Dev tools (lazy loading)
│   │       ├── nvm.zsh
│   │       ├── pyenv.zsh
│   │       ├── sdkman.zsh
│   │       └── go.zsh
│   └── aliases/                # Categorized aliases
│       ├── common.zsh
│       └── navigation.zsh
│
├── git/                        # Git configuration
│   ├── config                  # symlink → ~/.gitconfig
│   ├── ignore                  # symlink → ~/.gitignore
│   ├── attributes              # symlink → ~/.gitattributes
│   └── aliases/
│       └── gitalias            # Optional: 1780+ git aliases
│
├── brew/                       # Homebrew configuration
│   └── Brewfile                # Package list
│
├── external/                   # External source assets (managed)
│   ├── kubectl_aliases         # symlink → ~/.kubectl_aliases
│   └── kube-ps1.sh             # symlink → ~/.kube-ps1.sh
│
├── misc/                       # Other configs
│   ├── tmux.conf               # symlink → ~/.tmux.conf
│   ├── vimrc                   # symlink → ~/.vimrc
│   ├── vim/                    # Vim runtime assets (autoload/colors/syntax)
│   ├── editorconfig            # symlink → ~/.editorconfig
│   ├── wgetrc                  # symlink → ~/.wgetrc
│   └── curlrc                  # symlink → ~/.curlrc
│
└── docs/                       # Documentation
    ├── TOOLS.md                # Tool list and sources
    └── SETUP.md                # Installation guide
```

### Loading Rules

#### 1. Core Configuration (zsh/core/*.zsh)
- **Loading method**: Numeric filename order (00, 10, 20...)
- **Timing**: Always loaded on shell startup
- **Performance requirement**: Total time < 100ms
- **Content**: PATH, completion, history, prompt, etc.

**Naming convention**:
- `00-path.zsh`: Loaded first (PATH setup)
- `10-completion.zsh`: Completion system
- `20-history.zsh`: History management
- `30-prompt.zsh`: Prompt configuration
- `90-syntax-highlighting.zsh`: Loaded last (syntax highlighting)

#### 2. Tool Configuration (zsh/tools/*.zsh)
- **Loading method**: Conditional loading (only when tool exists)
- **Check method**: `command -v <tool> >/dev/null 2>&1`
- **Usage**: kubectl, docker, fzf, zoxide, etc.

**Example**:
```zsh
# zsh/rc.zsh
_load_tool_if_exists kubectl "${DOTFILES_ROOT}/zsh/tools/kubectl.zsh"
```

#### 3. Development Tools (zsh/tools/dev/*.zsh)
- **Loading method**: Lazy loading (function wrapper deferred loading)
- **Reason**: nvm, pyenv, sdkman initialization takes 50-200ms
- **Usage**: Infrequently used but essential tools

**Implementation pattern**:
```zsh
# Lazy loading pattern
export TOOL_DIR="$HOME/.tool"

_tool_load() {
  unset -f tool
  # Actual initialization (expensive operation)
  eval "$(tool init)"
}

tool() { _tool_load; tool "$@"; }
```

### Performance Optimization Principles

#### ❌ Forbidden
- Executing unconditional subprocesses on startup for common paths (for example always running `$(brew --prefix)`)
- Unconditionally loading large files (> 100 lines and non-essential)
- Repeatedly setting environment variables or PATH
- Rebuilding cache on every shell startup (should check file timestamps)

#### ✅ Recommended
- Use hardcoded fast paths for common cases (e.g., `/opt/homebrew`, `/usr/local`) with guarded fallback detection for non-standard environments
- Use caching mechanisms (completion cache, git info cache)
- Conditional loading + lazy loading
- Use zsh built-in functions instead of external commands

#### Caching Strategy
```zsh
# Example: Rebuild cache only when needed
if [[ ! -s "$CACHE_FILE" || "$SOURCE_FILE" -nt "$CACHE_FILE" ]]; then
  # Rebuild cache
else
  # Use cache
fi
```

## Modification Rules

### Installation Method

This project uses **symlink mode** (`install.sh`). Files are symlinked from `~/dotfiles/` to `~`, so changes take effect immediately without re-installation.

**When adding new config files that need to be symlinked to `~`**:
- Update `install.sh` by adding a new `link_file` call
- Update `uninstall.sh` by adding the matching `unlink_file` call
- The symlink list is explicit - check existing calls in both scripts for reference

**Sync rule for install/uninstall scripts**:
- Any change to managed paths in `install.sh` MUST be mirrored in `uninstall.sh`
- Any change to managed paths in `uninstall.sh` MUST be mirrored in `install.sh`
- Treat both scripts as a paired contract; do not update only one side

**Example**:
```bash
# Add to install.sh
link_file "$DOTFILES_ROOT/new/config.conf" "$HOME/.config.conf"
```

### Documentation Language Policy

- All generated or updated documentation files must be written in English.

---

### Adding Tool Configuration

**Complete workflow**:

1. **Add to Brewfile**
   ```bash
   # Edit brew/Brewfile
   brew "<tool-name>"  # CLI tool
   # or
   cask "<app-name>"   # GUI application
   
   # Install
   brew bundle --file=~/dotfiles/brew/Brewfile
   ```

2. **Create configuration file**
   ```bash
   # Create file at zsh/tools/<tool>.zsh
   # Must include file header metadata:
   # ---
   # Tool: <tool name>
   # Source: <GitHub URL or official website>
   # Purpose: <purpose description>
   # Updated: <YYYY-MM-DD>
   # ---
   ```

3. **Register loading logic**
   ```zsh
   # Add to zsh/rc.zsh
   _load_tool_if_exists <tool> "${DOTFILES_ROOT}/zsh/tools/<tool>.zsh"
   ```

4. **Update documentation**
   - Add tool description to `docs/TOOLS.md`
   - Record source, purpose, configuration file location

5. **Test and verify**
   ```bash
   # Syntax check
   zsh -n ~/.zshrc
   
   # Startup speed test
   for i in {1..5}; do /usr/bin/time -p zsh -i -c exit 2>&1 | grep real; done
   
   # Functionality test
   zsh -i -c "<tool> --version"
   ```

### Adding Aliases

- Common aliases → `zsh/aliases/common.zsh`
- Navigation aliases → `zsh/aliases/navigation.zsh`
- Tool-specific → `zsh/tools/<tool>.zsh`

### Modifying PATH

- **Only modify PATH in these locations**:
  - `zsh/env.zsh`: Early essential PATH (Homebrew, ~/bin)
  - `zsh/core/00-path.zsh`: Secondary PATH (GNU tools, Krew)
- **Avoid duplicating settings across multiple files**

### Updating External Source Files

Example: Updating kubectl aliases

```bash
cd ~/dotfiles

# Update managed external alias assets
make update-aliases TARGET=kubectl

# Files are managed under external/
ls -l external/kubectl_aliases

# Commit changes
git add external/kubectl_aliases
git commit -m "Update kubectl aliases"
```

### Cleaning Up Unused Tools

1. **Confirm not in use**: Ask user or check last usage time
2. **Check dependencies**: `brew uses --installed <tool>`
3. **Remove from Brewfile**: Edit `brew/Brewfile`
4. **Remove configuration**: Delete `zsh/tools/<tool>.zsh` and loading logic in `zsh/rc.zsh`
5. **Update documentation**: Remove or mark as removed in `docs/TOOLS.md`
6. **Commit changes**: Record cleanup reason

## Testing and Verification

### Required Tests

Must run after every modification:

1. **Syntax check**
   ```bash
   zsh -n ~/.zshrc
   ```

2. **Startup speed test**
   ```bash
   # Test 5 times and average
   for i in {1..5}; do 
     /usr/bin/time -p zsh -i -c exit 2>&1 | grep real
   done
   # Target: < 0.5s, max 1s
   ```

3. **Functionality test**
   ```bash
   # Test actual loading
   zsh -i -c exit
   
   # Test tool availability
   zsh -i -c "<tool> --version"
   ```

4. **Symlink verification**
   ```bash
   ls -la ~ | grep "dotfiles"
   ```

### Performance Analysis

For deep performance bottleneck analysis:

```zsh
# Add to top of ~/.zshrc
zmodload zsh/zprof

# Add to bottom
zprof
```

Running `zsh -i -c exit` will show timing for each function.

## Common Tasks

### Adding New Homebrew Tool

```bash
# 1. Edit Brewfile
echo 'brew "<tool>"' >> ~/dotfiles/brew/Brewfile

# 2. Install
make brew

# 3. Check status
make check-tool TOOL=<tool>

# 4. Create config if needed: zsh/tools/<tool>.zsh
# 5. Update docs/TOOLS.md
# 6. Test
make test
```

### Installing on New Machine

```bash
# 1. Clone repository
git clone https://github.com/shihyuho/dotfiles.git ~/dotfiles

# 2. Complete setup
cd ~/dotfiles
make setup

# Or step by step:
make install  # Create symlinks
make brew     # Install Homebrew packages

# 3. Install nvm, pyenv, sdkman, etc. (if needed)
# See docs/SETUP.md for details

# 4. Verify installation
make test
```

### Updating Configuration

Since using symlink mode, directly edit files in dotfiles repo - no additional sync steps needed.

```bash
# Edit configuration
vim ~/dotfiles/zsh/core/30-prompt.zsh

# Reload (or open new shell)
exec zsh

# Commit changes
cd ~/dotfiles
git add zsh/core/30-prompt.zsh
git commit -m "Update prompt configuration"
git push
```

## Safety Rules

### ❌ Never

- Delete any files under `zsh/core/` (unless fully understanding their purpose)
- Directly modify symlink targets (like `~/.zshrc`) instead of original files
- Commit `.secrets` files to version control
- Commit changes without testing
- Randomly adjust filenames without understanding loading order

### ✅ Must Follow

- Test startup speed after every modification
- External sources must include URL and update date
- New config files must include file header metadata
- Keep each module file < 100 lines (if exceeds, consider splitting)
- Store sensitive info (API keys, tokens) in `~/.secrets` (not version controlled)
- Any added/removed/renamed sensitive environment variable must be updated in `~/.secrets`
- Keep `secrets.example` in sync with the required sensitive variable list
- Before creating any git commit, review `AGENTS.md` and `README.md` and update them when the current session changed workflows, structure, or operational rules

## Tool List

### Essential Tools (Frequently Used)

- **Kubernetes**: kubectl, k9s, helm, kustomize
- **Container**: Docker
- **Git**: git, lazygit, gh, ghq
- **Shell Enhancement**: fzf, zoxide, exa, ripgrep
- **Development Languages**: Go, Node.js (nvm), Java (sdkman)

### Backup Tools (Kept but Rarely Used)

- **Python**: pyenv (backup, might need in future)
- **Git Aliases**: `git/aliases/gitalias` (symlinked to `~/.gitalias`)

### Removed Tools

- OrbStack, Colima (switched to Docker Desktop)
- Font tools (sfnt2woff etc., no longer doing related work)

See `docs/TOOLS.md` for detailed list.

## Configuration File Format Standard

Every configuration file must include:

```zsh
#!/usr/bin/env zsh
# ---
# Tool: <tool name>
# Source: <source URL>
# Purpose: <purpose description>
# Updated: <YYYY-MM-DD>
# [Optional] Lazy Loading: Yes/No
# [Optional] Notes: <additional notes>
# ---

# Actual configuration content
```

## Troubleshooting

### Startup Speed Slowing Down

1. Use `zprof` to analyze bottlenecks
2. Check for `$(command)` executing on every startup
3. Consider converting expensive tools to lazy loading
4. Check if caching mechanism is working properly

### Configuration Not Taking Effect

1. Check symlink: `ls -la ~/.zshrc`
2. Check conditional loading logic (is tool in PATH)
3. Manual test: `source ~/dotfiles/zsh/tools/<tool>.zsh`
4. Check syntax errors: `zsh -n ~/.zshrc`

### Conflicts or Duplicate Definitions

1. Use `type <command>` to see definition source
2. Check if same alias/function is defined in multiple files
3. Verify loading order is correct

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-06 | 2.0 | Refactored to modular architecture, symlink mode, AI-friendly design |
| 2023-02-14 | 1.0 | Initial version (single .zshrc configuration) |

## Related Resources

- **dotfiles-manager skill**: .agents/skills/dotfiles-manager/ (project-level)
- **Tool List**: docs/TOOLS.md
- **Installation Guide**: docs/SETUP.md

---

**Note for AI Agents**: 
- Read this entire document before making modifications
- Execute all tests from the Testing section after every modification
- Ask user when uncertain instead of guessing
- Record all important changes
