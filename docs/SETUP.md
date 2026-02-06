# Dotfiles Setup Guide (User-Oriented)

This guide is for users running a manual setup.
If you are an AI agent, use [`INSTALL.md`](INSTALL.md) as the primary playbook.

## Quick Start

### 1. Choose install directory

Default:

```bash
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.config/dotfiles}"
```

### 2. Clone repository

```bash
git clone https://github.com/shihyuho/dotfiles.git "$DOTFILES_DIR"
cd "$DOTFILES_DIR"
```

### 3. Install

Recommended (full setup):

```bash
make setup
```

Or step by step:

```bash
make install  # Create symlinks
make brew     # Install Homebrew packages
```

### 4. Create local secrets

```bash
cp "$DOTFILES_DIR/secrets.example" ~/.secrets
chmod 600 ~/.secrets
```

Then edit `~/.secrets` and set required values:

- `GEMINI_API_KEY`
- `MCP_GITHUB_PERSONAL_ACCESS_TOKEN`

### 5. Reload shell

```bash
exec zsh
```

## Optional Setup

### nvm (Node.js)

```bash
# nvm is installed via Homebrew and initializes on demand (lazy loading)
nvm install --lts
nvm use --lts
```

### pyenv (Python)

```bash
# pyenv is installed via Homebrew
pyenv install 3.12
pyenv global 3.12
```

### SDKMAN (Java/JVM tools)

```bash
curl -s "https://get.sdkman.io" | bash
# Use after restarting your shell
sdk list java
sdk install java
```

## Verify Installation

```bash
make test
kubectl version --client
gh --version
```

Expected verification result:

- Syntax check passes
- Startup speed passes with every run `< 0.5s`
- Managed symlinks are correct

## Troubleshooting

### Symlink not applied

```bash
ls -la ~/.zshrc
# Expected: .zshrc -> /path/to/dotfiles/zsh/rc.zsh
```

If it is not a symlink, run:

```bash
make install
```

### Tool not found

```bash
echo "$PATH"
which brew
brew doctor
```

### Slow startup

```bash
make measure-startup
```

## More Information

- AI install playbook: [`INSTALL.md`](INSTALL.md)
- Tool list: [`TOOLS.md`](TOOLS.md)
- Project rules: [`../AGENTS.md`](../AGENTS.md)
- GitHub: https://github.com/shihyuho/dotfiles
