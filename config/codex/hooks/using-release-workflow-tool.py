#!/usr/bin/env python3
"""PostToolUse hook for release-workflow commit hygiene.

Shared by Claude Code and Codex — both expose an identical hook contract
(same event names, JSON-on-stdin/stdout, hookSpecificOutput.additionalContext).

Fires after Bash tool calls. When the command was a git commit and the repo
uses the release-workflow conventional-commit gate, validates HEAD's message
with commitlint (`--last`). Only injects a remediation prompt when commitlint
reports a lint failure — compliant commits pass through silently.

The check is authoritative: it shells out to commitlint, so it honors the
repo's own commitlint config and falls back to @commitlint/config-conventional
otherwise (same command the PR-time gate uses). It requires Node.js / npx on
PATH; when npx is unavailable, offline, or slow, the hook stays silent rather
than raising a false alarm.

Installation: see references/setup.md.
"""

import json
import os
import subprocess
import sys

SIGNATURE_FILES = (
    ".release-please-config.json",
    ".github/workflows/commitlint.yml",
)
# Self-contained: --extends supplies config-conventional inline, so the check
# works even when the repo ships no commitlint config file. A repo config, if
# present, is still loaded and merged by commitlint.
COMMITLINT_CMD = [
    "npx", "--yes",
    "-p", "@commitlint/cli",
    "-p", "@commitlint/config-conventional",
    "commitlint", "--last",
    "--extends", "@commitlint/config-conventional",
]
# First npx run may download packages — allow generous headroom.
COMMITLINT_TIMEOUT = 120


def read_payload():
    try:
        return json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return {}


def is_git_commit(payload):
    if payload.get("tool_name") != "Bash":
        return False
    command = payload.get("tool_input", {}).get("command", "")
    return "git commit" in command


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


def run_commitlint(root):
    """Return commitlint output when HEAD fails the lint, else empty string.

    Stays silent (empty string) when the commit passes or when commitlint
    cannot run at all (npx missing, offline, timeout) — we never nag on a
    result we could not actually compute.
    """
    try:
        result = subprocess.run(
            COMMITLINT_CMD,
            cwd=root,
            capture_output=True,
            text=True,
            timeout=COMMITLINT_TIMEOUT,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    # commitlint exits 1 on a lint failure; 0 on pass; other codes mean it
    # could not evaluate (e.g. npx/network error) — treat those as silent.
    if result.returncode != 1:
        return ""
    return (result.stdout + result.stderr).strip()


def main():
    payload = read_payload()
    if not is_git_commit(payload):
        return 0
    root = repo_root()
    if not root:
        return 0
    if not any(os.path.exists(os.path.join(root, f)) for f in SIGNATURE_FILES):
        return 0
    output = run_commitlint(root)
    if not output:
        return 0
    result = {
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": (
                "HEAD's commit message failed commitlint (release-workflow "
                "conventional-commit gate):\n\n"
                + output
                + "\n\nAmend HEAD with a conventional-commit-valid message "
                "(`git commit --amend`), then re-run the check. Only amend "
                "before the commit is pushed."
            ),
        }
    }
    json.dump(result, sys.stdout)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
