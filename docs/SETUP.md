# Dotfiles Setup Guide

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/shihyuho/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Run installation

```bash
make install
```

This creates symlinks such as:
- `~/.zshrc` -> `dotfiles/zsh/rc.zsh`
- `~/.zshenv` -> `dotfiles/zsh/env.zsh`
- `~/.gitconfig` -> `dotfiles/git/config`
- `~/.gitalias` -> `dotfiles/git/aliases/gitalias`
- `~/.kubectl_aliases` -> `dotfiles/external/kubectl_aliases`
- `~/.kube-ps1.sh` -> `dotfiles/external/kube-ps1.sh`
- and other configuration files

### 3. Install Homebrew packages

```bash
make brew
```

### 4. Create your local secrets file

```bash
cp ~/dotfiles/secrets.example ~/.secrets
chmod 600 ~/.secrets
```

Then edit `~/.secrets` and set required variables:

- `GEMINI_API_KEY`
- `MCP_GITHUB_PERSONAL_ACCESS_TOKEN`

### 5. Restart your shell

```bash
exec zsh
```

## Optional Setup

### nvm (Node.js)

```bash
# nvm is installed via Homebrew
# It initializes on demand (lazy loading)
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

## Sync on a New Machine

Because this repo uses symlink mode, you only need to:

1. Clone the repository
2. Run `make install`
3. Install Homebrew packages with `make brew`

Changes are reflected immediately, with no manual sync step.

## Verify Installation

```bash
# Run full verification
make test

# Or run startup speed test directly
for i in {1..5}; do /usr/bin/time -p zsh -i -c exit 2>&1 | grep real; done

# Verify tools are available
kubectl version --client
gh --version
```

## Troubleshooting

### Symlink not applied

```bash
ls -la ~/.zshrc
# Expected: .zshrc -> /path/to/dotfiles/zsh/rc.zsh
```

If it is not a symlink, run `make install` again.

### Tool not found

Check PATH:

```bash
echo $PATH
```

Confirm Homebrew is set up correctly:

```bash
which brew
brew doctor
```

### Slow startup

Use `zprof` for analysis:

```zsh
# Add at the top of ~/.zshrc
zmodload zsh/zprof

# Add at the bottom
zprof
```

Run `zsh` and inspect the profiling output.

## More Information

- **Architecture guide**: `AGENTS.md`
- **Tool list**: `docs/TOOLS.md`
- **GitHub**: https://github.com/shihyuho/dotfiles
