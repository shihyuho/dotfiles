# Codex configuration

This directory is the repo-backed home for Codex configuration.

It intentionally manages only stable source-of-truth files. Runtime state such
as auth, logs, sessions, caches, SQLite databases, marketplace timestamps, and
hook trust hashes stays under `~/.codex` and is not committed here.

Currently managed:
- `AGENTS.md`
- `config.toml`
- `guides/` — shared guide content from `config/claude/guides`
- `hooks.json`
- `hooks/`

Install with the repo's normal entrypoint:

```bash
make install
```
