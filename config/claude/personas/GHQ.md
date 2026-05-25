# ghq — Local Source Mirrors

Dependency source is often already cloned locally via ghq, laid out as
`$(ghq root)/<host>/<org>/<repo>` (e.g. `github.com/x-motemen/ghq`). Read it
there before inspecting packaged artifacts (jar, `node_modules`, `vendor`,
`site-packages`) or fetching from the web — the local copy has full history and
costs nothing to open.

## Locate a repo — don't guess the path

```
ghq list -p <query>          full path(s) whose name contains <query>
ghq list -e -p <org>/<repo>  exact match, one path (e.g. ghq list -e -p x-motemen/ghq)
ghq list                     all cloned repos, relative paths
ghq root [--all]             the ghq root(s)
```

## When reading dependency source

- Resolve the path with `ghq list -e -p <org>/<repo>`, then `cx overview` /
  Read it directly — no need to assume `~/...`.
- Match the runtime version when reading — don't assume `main`/`master`.
