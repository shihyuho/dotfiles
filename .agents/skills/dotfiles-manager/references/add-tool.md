# Complete Workflow for Adding a New Tool

## Prerequisites
- `$DOTFILES_ROOT` is set
- You have read `$DOTFILES_ROOT/AGENTS.md` to understand project architecture

## Step 1: Check Current Tool Status

```bash
command -v <TOOL_NAME> >/dev/null 2>&1 && echo "installed" || echo "not installed"

[[ -f "$ZSH_DIR/tools/<TOOL_NAME>.zsh" ]] && echo "config already exists"
```

## Step 2: Add to Brewfile

```bash
cd "$BREW_DIR"

# Edit Brewfile and add under an appropriate section
# Format:
# brew "<tool>"          # CLI tool
# cask "<tool>"          # GUI application

brew bundle --file="$BREW_DIR/Brewfile"
```

## Step 3: Create Configuration File

```bash
cat > "$ZSH_DIR/tools/<TOOL_NAME>.zsh" << 'EOF'
#!/usr/bin/env zsh
# ---
# Tool: <TOOL_NAME>
# Source: <GitHub URL or official website>
# Purpose: <short description>
# Updated: <YYYY-MM-DD>
# ---

# Configuration content
export <TOOL>_CONFIG="value"
alias <alias>='<command>'
EOF
```

**Configuration file principles:**
- Header metadata is required (source, purpose, update date)
- Keep file length under 100 lines
- If content grows too large, consider lazy loading

## Step 4: Register Loading Logic

Edit `$ZSH_DIR/rc.zsh` and add conditional loading:

```zsh
_load_tool_if_exists <TOOL_NAME> "${DOTFILES_ROOT}/zsh/tools/<TOOL_NAME>.zsh"
```

**Loading strategy:**
- **Frequently used tools**: conditional loading (load when tool exists)
- **Large configurations**: lazy loading (function wrapper)
- **Development tools**: lazy loading (nvm/pyenv style)

## Step 5: Update Documentation

Edit `$DOCS_DIR/TOOLS.md` and add a tool entry:

```markdown
## <Category>
- **<TOOL_NAME>**: <short description>
  - Source: <URL>
  - Config: `zsh/tools/<TOOL_NAME>.zsh`
  - Installation: `brew/Brewfile`
```

## Step 6: Test and Verify

```bash
# 1. Syntax check
zsh -n ~/.zshrc

# 2. Startup speed test (5 iterations)
for i in {1..5}; do
  /usr/bin/time -p zsh -i -c exit 2>&1 | grep real
done

# 3. Functional test
zsh -i -c "<TOOL_NAME> --version"
```

Target startup time: under 0.5s (maximum 1s)

## Common Scenarios

### Scenario 1: Simple CLI tool (for example, bat)
```bash
# Brewfile
brew "bat"

# zsh/tools/bat.zsh
alias cat='bat --paging=never'
export BAT_THEME="Solarized (dark)"

# zsh/rc.zsh
_load_tool_if_exists bat "${DOTFILES_ROOT}/zsh/tools/bat.zsh"
```

### Scenario 2: Tool that requires initialization (for example, zoxide)
```bash
# zsh/tools/zoxide.zsh
eval "$(zoxide init zsh --cmd z)"
```

### Scenario 3: Lazy-loaded tool (for example, nvm)
```bash
# zsh/tools/dev/nvm.zsh
export NVM_DIR="$HOME/.nvm"

_nvm_load() {
  unset -f nvm node npm npx
  [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
}

nvm() { _nvm_load; nvm "$@"; }
node() { _nvm_load; node "$@"; }
```
