# OpenCode oh-my-opencode-slim Link Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Manage `oh-my-opencode-slim` as a repo-backed directory link under `~/.config/opencode/`.

**Architecture:** Add a new source directory at `config/opencode/oh-my-opencode-slim/` so the repo becomes the source of truth, then mirror the managed path in both `install.sh` and `uninstall.sh`. Verify the change with the repo's required dotfiles checks after the filesystem mapping is in place.

**Tech Stack:** Shell scripts (`install.sh`, `uninstall.sh`), dotfiles symlink management, OpenCode config layout

---

### Task 1: Add the managed source directory

**Files:**
- Create: `config/opencode/oh-my-opencode-slim/.gitkeep`

**Step 1: Create the source directory placeholder**

Create `config/opencode/oh-my-opencode-slim/.gitkeep` so git tracks the new managed directory.

**Step 2: Verify the directory exists**

Run: `ls -la config/opencode/oh-my-opencode-slim`
Expected: directory exists and contains `.gitkeep`

### Task 2: Add install/uninstall contract entries

**Files:**
- Modify: `install.sh`
- Modify: `uninstall.sh`

**Step 1: Update install script**

Add:

```zsh
link_file "$DOTFILES_ROOT/config/opencode/oh-my-opencode-slim" "$HOME/.config/opencode/oh-my-opencode-slim"
```

Place it next to the existing OpenCode directory links.

**Step 2: Update uninstall script**

Add:

```zsh
unlink_file "$DOTFILES_ROOT/config/opencode/oh-my-opencode-slim" "$HOME/.config/opencode/oh-my-opencode-slim"
```

Place it next to the existing OpenCode unlink entries.

**Step 3: Verify the contract is mirrored**

Run: `git diff -- install.sh uninstall.sh`
Expected: both scripts contain matching `oh-my-opencode-slim` entries

### Task 3: Run required verification

**Files:**
- Verify: `install.sh`
- Verify: `uninstall.sh`

**Step 1: Syntax check shell startup**

Run: `zsh -n ~/.zshrc`
Expected: exit 0

**Step 2: Run repo verification suite**

Run: `make test`
Expected: required dotfiles checks complete successfully

**Step 3: Review resulting diff**

Run: `git status --short`
Expected: only planned files are changed
