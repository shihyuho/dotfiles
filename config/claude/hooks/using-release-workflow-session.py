#!/usr/bin/env python3
"""SessionStart hook for release-workflow commit hygiene.

Shared by Claude Code and Codex — both expose an identical hook contract
(same event names, JSON-on-stdin/stdout, hookSpecificOutput.additionalContext).

Fires once at session start. If the working directory is a repo that uses the
release-workflow conventional-commit gate (release-please + commitlint),
reminds the model that commit subjects and PR titles must be conventional-commit
valid. Repos without that gate get zero context injection.

Cross-platform: uses only the Python standard library. Works on macOS, Linux,
and Windows without `jq`, `grep`, or a POSIX shell.

Installation: see references/setup.md.
"""

import json
import os
import subprocess
import sys

# Signature files that indicate a repo opted into the release-workflow
# conventional-commit gate. Paths are relative to the git toplevel.
SIGNATURE_FILES = (
    ".release-please-config.json",
    ".github/workflows/commitlint.yml",
)
REMINDER = (
    "This repo uses softleader release-workflow (conventional commits). "
    "Every commit subject — and every PR title — must be a valid conventional "
    "commit (e.g. `feat(scope): ...`, `fix: ...`, `chore: ...`). After each "
    "`git commit`, the message is validated with commitlint; fix any failure "
    "with `git commit --amend` before pushing."
)


def repo_root():
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            timeout=5,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    if result.returncode != 0:
        return None
    return result.stdout.strip() or None


def uses_release_workflow():
    root = repo_root()
    if not root:
        return False
    return any(os.path.exists(os.path.join(root, f)) for f in SIGNATURE_FILES)


def main():
    if not uses_release_workflow():
        return 0
    payload = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": REMINDER,
        }
    }
    json.dump(payload, sys.stdout)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
