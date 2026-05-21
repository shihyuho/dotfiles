#!/usr/bin/env bash
# Validate every repo JSON file that declares a "$schema" against that schema.
# Best-effort: JSON syntax errors and schema violations fail; missing tooling
# or an unreachable schema is skipped with a warning (so CI stays green offline).
# Usage: ./scripts/validate-json-schemas.sh

set -e

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

DOTFILES_ROOT="$DOTFILES_ROOT" python3 - <<'PY'
import json, os, sys

ROOT = os.environ["DOTFILES_ROOT"]
SKIP_DIRS = {".git", "node_modules", ".worktrees"}

try:
    import jsonschema
    from jsonschema.validators import validator_for
    have_jsonschema = True
except ImportError:
    have_jsonschema = False

from urllib.request import urlopen, Request
from urllib.error import URLError

def find_json_files():
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            if name.endswith(".json"):
                yield os.path.join(dirpath, name)

schema_cache = {}
def fetch_schema(url):
    if url not in schema_cache:
        req = Request(url, headers={"User-Agent": "dotfiles-json-validator"})
        with urlopen(req, timeout=10) as resp:
            schema_cache[url] = json.load(resp)
    return schema_cache[url]

failed = False
checked = 0
for path in sorted(find_json_files()):
    rel = os.path.relpath(path, ROOT)
    try:
        data = json.load(open(path))
    except json.JSONDecodeError as e:
        print(f"   ❌ {rel}: invalid JSON ({e})")
        failed = True
        continue

    schema_url = data.get("$schema") if isinstance(data, dict) else None
    if not (isinstance(schema_url, str) and schema_url.startswith("http")):
        continue  # no remote schema declared

    checked += 1
    if not have_jsonschema:
        print(f"   ⏭️  {rel}: syntax OK (jsonschema not installed; schema check skipped)")
        continue
    try:
        schema = fetch_schema(schema_url)
    except (URLError, OSError, json.JSONDecodeError):
        print(f"   ⏭️  {rel}: syntax OK (schema unreachable; schema check skipped)")
        continue

    errs = sorted(validator_for(schema)(schema).iter_errors(data), key=lambda e: list(e.path))
    if errs:
        failed = True
        for e in errs:
            loc = "/".join(map(str, e.path)) or "(root)"
            print(f"   ❌ {rel} [{loc}]: {e.message}")
    else:
        print(f"   ✅ {rel} matches schema")

if checked == 0:
    print("   (no JSON files declare a remote $schema)")
sys.exit(1 if failed else 0)
PY
