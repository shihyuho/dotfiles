# Global Codex Guidance

## Behavioral Guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Merge with
project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial
tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes,
simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- "Refactor X" -> "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```text
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it
work") require constant clarification.

These guidelines are working if there are fewer unnecessary changes in diffs,
fewer rewrites due to overcomplication, and clarifying questions come before
implementation rather than after mistakes.

## ghq - Local Source Mirrors

ghq may have dependency source cloned locally at
`$(ghq root)/<host>/<org>/<repo>` (e.g. `github.com/x-motemen/ghq`) - a free,
full-history copy. Prefer it over fetching from the web or unpacking artifacts
(jar, `node_modules`, `vendor`, `site-packages`).

### Locate a repo - don't guess the path

```text
ghq list -p <query>          full path(s) whose name contains <query>
ghq list -e -p <org>/<repo>  exact match, one path (e.g. x-motemen/ghq)
ghq list                     all repos, relative paths
ghq root [--all]             the ghq root(s)
```

### When reading dependency source

- Resolve the path via `ghq list -e -p <org>/<repo>` and read there - don't
  assume `~/...`.
- Match the runtime version - don't assume `main`/`master`.

## cx - Semantic Code Navigation

Prefer cx over reading files. Escalate: overview -> symbols -> definition /
references -> file reads.

### Quick reference

```text
cx overview PATH                                    file or directory table of contents
cx overview DIR --full                              directory overview with ranges + signatures
cx symbols [--kind K] [--name GLOB] [--file PATH]   search symbols project-wide
cx symbols --kinds [--file PATH]                    list distinct kinds with counts
cx definition --name NAME [--from PATH] [--kind K]  get a function/type body
cx references --name NAME [--file PATH] [--context] usages grouped by file; --context exact lines
cx lang list                                        show supported languages
cx lang add LANG [LANG...]                          install language grammars
```

Global: `--no-tests` (exclude test files/symbols), `--json`, `--limit N`,
`--offset N`, `--all`

Aliases: `cx o`, `cx s`, `cx d`, `cx r`

Kinds: `fn`, `struct`, `enum`, `trait`, `type`, `const`, `class`, `interface`,
`module`, `event`, `heading`

### Key patterns

- Start with `cx overview .`, drill into subdirectories - cheaper than `ls` +
  reading files.
- `cx definition --name X` gives exact text for edit `old_string` without
  reading the whole file.
- `cx references --name X` groups hits by file; add `--context` only when exact
  source lines are needed.
- After context compression, use `cx overview` / `cx definition` to re-orient -
  don't re-read full files.
- Check signatures for `pub` / `export` to identify public API without reading
  the file.

### Pagination

Default limits: definition 3, symbols 100, references 50. When truncated,
stderr shows:

```text
cx: 3/32 definitions for "X" | --from PATH to narrow | --offset 3 for more | --all
```

`--offset N` pages forward, `--all` bypasses, `--limit N` overrides. Narrow
with `--from` / `--file` / `--kind` before paging.

JSON: paginated -> `{total, offset, limit, results: [...]}`, non-paginated ->
bare array.

### Missing grammars

If cx reports a missing grammar, install with `cx lang add <lang>`. Run
`cx lang list` to see what's installed.
