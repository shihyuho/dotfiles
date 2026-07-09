# cx — Semantic Code Navigation

Prefer cx over reading files. Escalate: overview → symbols → definition/references → Read tool.

- `cx overview PATH` — file/directory table of contents; start with `cx overview .` instead of ls + reading files
- `cx symbols --name GLOB` — search symbols project-wide
- `cx definition --name NAME` — a symbol's body; exact text for Edit's `old_string`
- `cx references --name NAME` — usages grouped by file

Flags (`--kind`, `--no-tests`, `--json`, paging, …): see `cx <cmd> --help`. Truncated output prints on stderr how to narrow/page. After context compression, re-orient with overview/definition — don't re-read full files.
