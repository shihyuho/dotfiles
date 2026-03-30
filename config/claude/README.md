# Claude configuration

This directory is the repo-backed home for Claude configuration.

It is separate from the repo-root `.claude` compatibility link, which points to `.agents` for project-local agent discovery.

Currently managed:
- `settings.json`

Guardrail:
- Keep the managed `settings.json` self-contained. Do not re-introduce references to unmanaged `hooks/`, `commands/`, or machine-specific absolute paths until those assets are repo-managed too.

Future candidates for this directory:
- `agents/`
- `hooks/`
- `commands/`
