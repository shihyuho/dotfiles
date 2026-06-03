# Claude configuration

This directory is the repo-backed home for Claude configuration.

It is separate from the repo-root `.claude` compatibility link, which points to `.agents` for project-local agent discovery.

Currently managed:
- `settings.json`
- `hooks/`
- `commands/`
- `workflows/` — dynamic workflow scripts, linked to `~/.claude/workflows/` (research preview)
- `plugins/` — custom Claude Code plugins (see below)

Future candidates for this directory:
- `agents/`

## Custom Plugins

### jdtls-lombok-lsp

Custom JDTLS plugin with Lombok annotation processing support, replacing the official `jdtls-lsp@claude-plugins-official`.

**Why:** The official jdtls plugin doesn't support Lombok. Without the `-javaagent` flag, jdtls can't resolve Lombok-generated code (`@Getter`, `@Setter`, `@Builder`, etc.), causing LSP errors on most Java projects.

**How it works:**
- `.lsp.json` uses `${CLAUDE_PLUGIN_ROOT}/bin/jdtls-lombok` to reference the bundled wrapper script, so the plugin is self-contained — no PATH setup or symlinks needed
- `bin/jdtls-lombok` wrapper script dynamically finds the latest `lombok-*.jar` from Maven local repository (`~/.m2/repository/org/projectlombok/lombok/`), launches `jdtls` with `-javaagent`, falls back to plain `jdtls` if not found

**Installation:**

```bash
# 1. Install the plugin (self-contained, no symlink needed)
/plugin install jdtls-lombok-lsp@shihyuho-dotfiles

# 2. Remove the official jdtls plugin (if installed)
/plugin uninstall jdtls-lsp@claude-plugins-official
```

**Prerequisites:**
- `brew install jdtls` — the underlying language server
- Lombok jar in Maven local cache (any project with Lombok dependency will populate this)
