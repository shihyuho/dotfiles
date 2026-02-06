# Dotfiles Manager Skill

## Overview
Manage modular dotfiles configuration system. Supports adding tools, updating aliases, optimizing startup speed, and more.

## Applicable Conditions
This skill applies to dotfiles repositories with the following structure:
- Modular zsh configuration (`zsh/core/`, `zsh/tools/`)
- Brewfile for package management
- Symlink installation mode
- Contains `AGENTS.md` file

## When to Use
- Adding new tool configurations
- Updating external alias files (kubectl-aliases, gitalias, etc.)
- Optimizing shell startup speed
- Cleaning up unused tools

## Step 1: Locate Dotfiles Directory

Execute the following steps to find dotfiles location:

1. **Check current directory**:
   ```bash
   [[ -f AGENTS.md ]] && echo "Current directory is dotfiles"
   ```

2. **Common locations**:
   ```bash
   for dir in ~/dotfiles ~/.dotfiles ~/code/*/dotfiles ~/code/*/*/dotfiles; do
     [[ -f "$dir/AGENTS.md" ]] && echo "Found: $dir" && break
   done
   ```

3. **Ask user**: If not found, ask user for dotfiles location.

4. **Set variable**:
   ```bash
   DOTFILES_ROOT="<found path>"
   ```

## Core Operations

### 1. Add New Tool
**Reference**: `references/add-tool.md`

**Brief steps**:
1. Locate dotfiles directory (see above)
2. Read `references/add-tool.md` for complete workflow
3. Execute: Brewfile → Config file → Load logic → Test
4. Update documentation

### 2. Update External Alias Files
**Reference**: `references/update-aliases.md`

**Brief steps**:
1. Identify alias file source (kubectl-aliases, gitalias, etc.)
2. Read `references/update-aliases.md` for complete workflow
3. Download update and add metadata
4. Test loading

### 3. Optimize Startup Speed
**Reference**: `references/optimize-startup.md`

**Brief steps**:
1. Measure current startup speed
2. Read `references/optimize-startup.md` for analysis methods
3. Identify bottlenecks and optimize
4. Verify improvements

### 4. Clean Up Unused Tools
**Reference**: `references/cleanup.md`

**Brief steps**:
1. Identify candidate tools
2. Read `references/cleanup.md` for safe workflow
3. Check dependencies
4. Execute cleanup and update documentation

## Architecture Understanding

**Must read before first use**:
- Read `$DOTFILES_ROOT/AGENTS.md` (project-specific architecture)
- Read `references/architecture.md` (general architecture principles)

## Safety Rules
- ❌ Do not delete files under `zsh/core/`
- ❌ Do not modify symlink targets (`~/.zshrc`, etc.)
- ❌ Do not hardcode paths in references
- ✅ Must test startup speed after every modification
- ✅ Use `$DOTFILES_ROOT` variable for path references

## Verification Checklist
Execute after each operation:
- [ ] Startup speed test (`zsh -i -c exit`)
- [ ] Syntax check (`zsh -n ~/.zshrc`)
- [ ] Actual functionality test
- [ ] Documentation updated

## Environment Variable Conventions
Before executing any operation, set the following variables:
```bash
DOTFILES_ROOT="<dotfiles absolute path>"
ZSH_DIR="$DOTFILES_ROOT/zsh"
BREW_DIR="$DOTFILES_ROOT/brew"
DOCS_DIR="$DOTFILES_ROOT/docs"
```
