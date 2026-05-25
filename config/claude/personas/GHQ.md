# ghq — Local Source Mirrors

Dependency source may already be cloned locally via ghq at
`$(ghq root)/<host>/<org>/<repo>` (e.g. `github.com/x-motemen/ghq`) — full
history, free to open. Check there before packaged artifacts (jar,
`node_modules`, `vendor`, `site-packages`) or the web.

## Locate a repo — don't guess the path

```
ghq list -p <query>          full path(s) whose name contains <query>
ghq list -e -p <org>/<repo>  exact match, one path (e.g. x-motemen/ghq)
ghq list                     all repos, relative paths
ghq root [--all]             the ghq root(s)
```

## When reading dependency source

- Resolve the path via `ghq list -e -p <org>/<repo>` and read there — don't
  assume `~/...`.
- Match the runtime version — don't assume `main`/`master`.
