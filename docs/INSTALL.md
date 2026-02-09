# AI Install Guide

This guide is for AI agents helping a user install and bootstrap this dotfiles repository.

> **🤖 AI AGENTS:**
> - **Verify each step** using the ✓ checkmarks before proceeding
> - **Report errors immediately** with full output - do not skip verification
> - **Ask user for install location** before cloning (Step 1)
> - **Remind user to edit secrets** after installation (Step 4)
> - **Success criteria**: All steps complete AND `make test` passes

## Success Criteria

Installation is complete when:
- ✓ Repository cloned or updated
- ✓ Symlinks created (`ls -la ~ | grep dotfiles` shows symlinks)
- ✓ Homebrew packages installed
- ✓ `.secrets` file exists with `600` permissions
- ✓ `make test` passes (exit code 0)
- ✓ User confirmed editing `.secrets`

---

## Step 1: Ask Install Location

Ask the user where to clone the repository:

**Question**: `Where should I clone the dotfiles repository?`

- **Default path**: `~/.config/dotfiles`
- **Alternative common path**: `~/dotfiles`

If the user has no preference, use the default.

Store the answer in `DOTFILES_DIR` for subsequent commands.

---

## Step 2: Clone or Update Repository

Execute this block (idempotent - safe to run multiple times):

```bash
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config/dotfiles}"

if [ -d "$DOTFILES_DIR/.git" ]; then
  echo "Repository exists. Updating..."
  git -C "$DOTFILES_DIR" pull --ff-only
else
  echo "Cloning repository..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone https://github.com/shihyuho/dotfiles.git "$DOTFILES_DIR"
fi
```

**Verify**:
```bash
test -d "$DOTFILES_DIR/.git" && echo "✓ Repository ready" || echo "✗ Clone failed"
```

**Expected output**: `✓ Repository ready`

**If verification fails**:
- Check network connectivity
- Verify GitHub is accessible: `ping github.com`
- Try manual clone with verbose output

---

## Step 3: Run Installation

Execute setup (creates symlinks + installs Homebrew packages):

```bash
cd "$DOTFILES_DIR"
make setup
```

**Verify symlinks created**:
```bash
ls -la ~ | grep -E "\->" | grep dotfiles | head -5
```

**Expected output**: Should show symlinks like:
```
.zshrc -> /Users/matt/.config/dotfiles/zsh/rc.zsh
.zshenv -> /Users/matt/.config/dotfiles/zsh/env.zsh
...
```

**If no symlinks appear**:
- Check `install.sh` ran without errors
- Manually run: `"$DOTFILES_DIR/install.sh"`
- Report any permission errors to user

---

## Step 4: Initialize Secrets File

Create secrets file (only if it doesn't exist):

```bash
if [ ! -f "$HOME/.secrets" ]; then
  cp "$DOTFILES_DIR/secrets.example" "$HOME/.secrets"
  chmod 600 "$HOME/.secrets"
  echo "✓ Created $HOME/.secrets"
else
  echo "✓ $HOME/.secrets already exists (skipping)"
fi
```

**Verify**:
```bash
ls -l "$HOME/.secrets" | grep -q "^-rw-------" && echo "✓ Permissions correct (600)" || echo "✗ Wrong permissions"
```

**Expected output**: `✓ Permissions correct (600)`

---

## Step 5: Shell Reload Instruction

**Important**: The next command (`exec zsh`) replaces the current shell process.

**For AI agents**:
- After running `exec zsh`, you will lose the current shell context
- Run `make test` in a **new bash command** after the shell restarts

**Execute**:
```bash
exec zsh
```

Then in a **new command**:
```bash
cd "$DOTFILES_DIR" && make test
```

**Verify**:
```bash
echo $?  # Should output: 0
```

**If tests fail**:
- Check specific error messages from `make test` output
- Verify syntax: `zsh -n ~/.zshrc`
- Measure startup: `for i in {1..3}; do /usr/bin/time -p zsh -i -c exit 2>&1 | grep real; done`
- Report failures to user with full output

---

## Step 6: Remind User to Edit Secrets

**Tell the user**:

```
⚠️  Action required: Edit ~/.secrets and set your API keys.

Required variables:
- GEMINI_API_KEY
- MCP_GITHUB_PERSONAL_ACCESS_TOKEN

Edit with: nano ~/.secrets (or your preferred editor)
```

**Do not proceed** to other tasks until user confirms they've edited or will edit later.

---

## Error Handling

| Error | Likely Cause | Solution |
|-------|-------------|----------|
| `git clone` fails | Network/authentication issue | Check `git config --global credential.helper`, try HTTPS vs SSH |
| `make setup` fails | Missing Homebrew | Install Homebrew first: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| `make test` fails (syntax) | Invalid shell syntax | Check specific file mentioned in error with `zsh -n <file>` |
| `make test` fails (startup speed) | Performance regression | Run `make measure-startup` for detailed analysis |
| Symlinks not created | Permission denied | Check write permissions in `$HOME`, may need manual symlink creation |

---

## Additional Resources

For detailed manual setup or troubleshooting:
- **Detailed setup flow**: [`SETUP.md`](SETUP.md)
- **Tool list and sources**: [`TOOLS.md`](TOOLS.md)
- **Architecture and rules**: [`../AGENTS.md`](../AGENTS.md)

---

## Agent Operational Rules

- **Read `AGENTS.md`** before making any modifications
- **Do not edit symlink targets** in `$HOME` - always edit source files in `$DOTFILES_DIR`
- **Do not commit** unless the user explicitly asks
- **Verify every step** before marking complete
- **Report errors with full output** - do not silently skip failures
