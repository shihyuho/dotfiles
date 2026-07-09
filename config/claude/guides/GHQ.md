# ghq — Local Source Mirrors

Dependency source may already be cloned locally under `$(ghq root)` — prefer it over fetching from the web or unpacking artifacts (jar, `node_modules`, `vendor`, `site-packages`).

- Resolve the path with `ghq list -e -p <org>/<repo>` — never guess or assume `~/...`.
- Read at the runtime version, not `main`/`master`.
