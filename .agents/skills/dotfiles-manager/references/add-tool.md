# Complete Workflow for Adding a New Tool

## Prerequisites
- `$DOTFILES_ROOT` is set
- You have read `$DOTFILES_ROOT/AGENTS.md` to understand project architecture

Execution rule: use `make` targets for standard terminal workflows; use scripts under `.agents/skills/dotfiles-manager/scripts/` when you need a helper directly.
Code snippets below are file-content examples unless they explicitly call a script.

## Step 1: Check Current Tool Status

```bash
bash .agents/skills/dotfiles-manager/scripts/check-tool-status.sh <TOOL_NAME>
```

## Step 2: Add to Brewfile

```bash
# Edit Brewfile and add under an appropriate section:
# brew "<tool>"   # CLI tool
# cask "<tool>"   # GUI application

make brew
```

## Step 3: Create Configuration File

```bash
bash .agents/skills/dotfiles-manager/scripts/create-tool-config.sh \
  <TOOL_NAME> \
  <SOURCE_URL> \
  "<short description>" \
  tools
```

Then edit the created file and add actual configuration content.

**Configuration file principles:**
- Header metadata is required (source, purpose, update date)
- Keep file length under 100 lines
- For heavy dev tools, make this file a lazy-loading shim rather than eager init code

## Step 4: Register Loading Logic

Edit `$ZSH_DIR/rc.zsh` and register the new config using the matching pattern:

```zsh
# Regular tools
_load_tool_if_exists <TOOL_NAME> "${DOTFILES_ROOT}/zsh/tools/<TOOL_NAME>.zsh"

# Heavy dev tools
source "${DOTFILES_ROOT}/zsh/tools/dev/<TOOL_NAME>.zsh"
```

**Loading strategy:**
- **Frequently used tools**: conditional loading (load when tool exists)
- **Large configurations**: lazy loading (function wrapper)
- **Development tools**: source a lightweight repo shim that lazy-loads the real tool on first use (nvm/pyenv style)

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
zsh -n ~/.zshrc
make test
bash .agents/skills/dotfiles-manager/scripts/check-tool-status.sh <TOOL_NAME>

# Optional functional check
zsh -i -c "<TOOL_NAME> --version"
```

Target startup time: every run must be under 0.5s

## Common Scenarios

### Scenario 1: Simple CLI tool (for example, bat)
```zsh
# Brewfile
brew "bat"

# zsh/tools/bat.zsh
alias cat='bat --paging=never'
export BAT_THEME="Solarized (dark)"

# zsh/rc.zsh
_load_tool_if_exists bat "${DOTFILES_ROOT}/zsh/tools/bat.zsh"
```

### Scenario 2: Tool that requires initialization (for example, zoxide)
```zsh
# zsh/tools/zoxide.zsh
eval "$(zoxide init zsh --cmd z)"
```

### Scenario 3: Lazy-loaded tool (for example, nvm)
```zsh
# zsh/tools/dev/nvm.zsh
export NVM_DIR="$HOME/.nvm"

_nvm_load() {
  unset -f nvm node npm npx
  [ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$BREW_PREFIX/opt/nvm/nvm.sh"
}

nvm() { _nvm_load; nvm "$@"; }
node() { _nvm_load; node "$@"; }
```

And in `zsh/rc.zsh`:

```zsh
source "${DOTFILES_ROOT}/zsh/tools/dev/nvm.zsh"
```
