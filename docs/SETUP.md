# Manual Install Guide

For users running a manual install (macOS or Linux).

> **AI agents**: use [`INSTALL.md`](INSTALL.md) — the structured playbook designed for agents.
>
> **First-time setup**: complete [`PREREQUISITES.md`](PREREQUISITES.md) for your platform before continuing. Linux users: `make brew` does not apply — run only `make install`.

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

## OpenCode Configuration

### Automatic Management

The OpenCode configuration and launcher scripts are now managed by the dotfiles install flow:

```bash
make install  # Creates symlinks for OpenCode config
```

Managed symlinks include:
- `~/.config/opencode/opencode.json` -> `dotfiles/config/opencode/opencode.json`
- `~/.config/opencode/oh-my-opencode-slim.json` -> `dotfiles/config/opencode/oh-my-opencode-slim.json`
- `~/.config/opencode/commands/` -> `dotfiles/config/opencode/commands/`
- `~/.config/opencode/agents/` -> `dotfiles/config/opencode/agents/`
- `~/.config/opencode/oh-my-opencode-slim/` -> `dotfiles/config/opencode/oh-my-opencode-slim/`

### Migrating Existing OpenCode Config

If you have an existing OpenCode configuration that you want to preserve:

1. **Backup your existing config:**
   ```bash
   cp ~/.config/opencode/opencode.json ~/.config/opencode/opencode.json.backup
   cp ~/.config/opencode/oh-my-opencode-slim.json ~/.config/opencode/oh-my-opencode-slim.json.backup
   ```

   If you already have any of these managed OpenCode paths, `make install` will move the existing files or directories into `~/.dotfiles_backup/...` before creating symlinks:

    - `~/.config/opencode/opencode.json`
    - `~/.config/opencode/oh-my-opencode-slim.json`
    - `~/.config/opencode/commands/`
    - `~/.config/opencode/agents/`
    - `~/.config/opencode/oh-my-opencode-slim/`

2. **Review the managed config:**
   ```bash
   cat config/opencode/opencode.json
   cat config/opencode/oh-my-opencode-slim.json
   ```

3. **Merge settings manually into the repo copy**: Update `config/opencode/opencode.json` and `config/opencode/oh-my-opencode-slim.json` in this repository, not the files under `~/.config/opencode/`, because `make install` will replace the home-directory files with symlinks to the repo copies. The managed `opencode.json` includes JDTLS LSP configuration, and `oh-my-opencode-slim.json` stores the local preset definition for the `oh-my-opencode-slim` plugin. If you have custom settings, merge them carefully - the managed `opencode.json` contains:
   - Plugin list
   - Default agent and model settings
   - MCP server configurations
   - Provider definitions
   - Permission settings
   - **LSP configuration for JDTLS** (at the end under `lsp.jdtls`)

   If the managed plugin list includes local `file://` plugins, make sure those paths exist on the current machine or update the plugin entry after installation.

4. **Reinstall to apply changes:**
   ```bash
   make install
   ```

## Claude Configuration

### Automatic Management

The Claude settings file is managed by the dotfiles install flow:

```bash
make install  # Creates the Claude settings symlink
```

Managed symlinks:
- `~/.claude/settings.json` -> `dotfiles/config/claude/settings.json`
- `~/.claude/hooks` -> `dotfiles/config/claude/hooks`
- `~/.claude/commands` -> `dotfiles/config/claude/commands`

If any of these already exist, `make install` moves them into `~/.dotfiles_backup/...` before creating the symlink.

### Updating Claude Settings

Edit files under `config/claude/` in this repository, not the symlinks in `~/.claude/`.

This repo manages `settings.json`, `hooks/`, and `commands/` under `config/claude/`. Future candidates include `agents/`.

### JDTLS / Lombok Prerequisites

JDTLS (Java Development Tools Language Server) requires:

1. **Java 21+**: Ensure you have Java 21 or later installed:
   ```bash
   java -version  # Should show 21+
   ```

2. **JDTLS Installation**: Download and install JDTLS from:
   - Stable releases: https://download.eclipse.org/jdtls/milestones/
   - Latest builds: https://download.eclipse.org/jdtls/snapshots/
   - Source and build instructions: https://github.com/eclipse-jdtls/eclipse.jdt.ls
   - Install the extracted JDTLS distribution under `~/.local/share/opencode/bin/jdtls`, or set `JDTLS_HOME` to the installed location

3. **Lombok JAR**: Ensure Lombok jar exists at default location or set override:
   - Default: `~/.lombok/lombok.jar`
   - Override: `export JDTLS_LOMBOK_JAR=/path/to/lombok.jar`

If Java is older than 21, the launcher will fail with an error like:

```text
ERROR: Java major version must be >= 21
```

### Override Environment Variables

You can override default paths by setting these environment variables in your `~/.secrets` or shell profile:

| Variable | Default | Description |
|----------|---------|-------------|
| `JDTLS_HOME` | `$HOME/.local/share/opencode/bin/jdtls` | JDTLS installation directory |
| `JDTLS_JAVA_HOME` | `$JAVA_HOME` or system `java` | Java home for JDTLS |
| `JDTLS_LOMBOK_JAR` | `$HOME/.lombok/lombok.jar` | Lombok jar path |

Example in `~/.secrets`:
```bash
export JDTLS_HOME="/opt/jdtls"
export JDTLS_LOMBOK_JAR="$HOME/.local/lib/lombok.jar"
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

### JDTLS cache looks stale

If JDTLS has been upgraded or the cached writable config looks suspect, remove the cache and let the launcher rebuild it:

```bash
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/jdtls"
```

## More Information

- Prerequisites: [`PREREQUISITES.md`](PREREQUISITES.md)
- AI install playbook: [`INSTALL.md`](INSTALL.md)
- Tool list: [`TOOLS.md`](TOOLS.md)
- Project rules: [`../AGENTS.md`](../AGENTS.md)
- GitHub: https://github.com/shihyuho/dotfiles
