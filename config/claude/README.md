# Claude configuration

This directory is the repo-backed home for Claude configuration.

It is separate from the repo-root `.claude` compatibility link, which points to `.agents` for project-local agent discovery.

Currently managed:
- `settings.json`
- `hooks/`
- `commands/`
- `plugins/` — custom Claude Code plugins (see below)

Future candidates for this directory:
- `agents/`

## Custom Plugins

### jdtls-lombok

Custom JDTLS plugin with Lombok annotation processing support, replacing the official `jdtls-lsp@claude-plugins-official`.

**Why:** The official jdtls plugin doesn't support Lombok. Without the `-javaagent` flag, jdtls can't resolve Lombok-generated code (`@Getter`, `@Setter`, `@Builder`, etc.), causing LSP errors on most Java projects.

**How it works:**
- `plugins/jdtls-lombok/bin/jdtls-lombok` — wrapper script that:
  1. Dynamically finds the latest `lombok-*.jar` from Maven local repository (`~/.m2/repository/org/projectlombok/lombok/`)
  2. Launches `jdtls` (Homebrew) with `--jvm-arg="-javaagent:<lombok.jar>"`
  3. Falls back to plain `jdtls` if Lombok jar is not found
- `plugins/jdtls-lombok/.lsp.json` — LSP config pointing to the wrapper
- `plugins/jdtls-lombok/.claude-plugin/plugin.json` — plugin manifest

**Installation:**

```bash
# 1. Symlink wrapper to PATH (handled by install.sh / make install)
ln -sf <dotfiles>/config/claude/plugins/jdtls-lombok/bin/jdtls-lombok ~/.local/bin/jdtls-lombok

# 2. Add the dotfiles repo as a plugin marketplace
/plugin marketplace add <dotfiles>
# or from GitHub:
/plugin marketplace add https://github.com/shihyuho/dotfiles

# 3. Install the plugin
/plugin install jdtls-lombok@shihyuho-dotfiles

# 4. Remove the official jdtls plugin (if installed)
/plugin uninstall jdtls-lsp@claude-plugins-official
```

**Prerequisites:**
- `brew install jdtls` — the underlying language server
- Lombok jar in Maven local cache (any project with Lombok dependency will populate this)
