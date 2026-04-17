#!/usr/bin/env python3
"""Claude Code PostToolUse hook for git-commit-co-author.

Fires after Bash tool calls. When the command was a git commit, inspects
HEAD's commit message for a compliant Co-authored-by trailer. Only injects
a remediation prompt when the trailer is missing or malformed — compliant
commits pass through silently with zero model overhead.

Cross-platform: uses only the Python standard library. Works on macOS, Linux,
and Windows without `jq`, `grep`, or a POSIX shell.

Installation: see references/setup.md.
"""

import json
import re
import subprocess
import sys

REMOTE_PATTERN = re.compile(r"github\.com[/:]softleader")
TRAILER_PATTERN = re.compile(r"^Co-authored-by:", re.IGNORECASE)
CANONICAL_PREFIX = "Co-authored-by:"
CANONICAL_EMAIL = "<noreply@softleader.com.tw>"


def read_payload() -> dict:
    try:
        return json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return {}


def is_git_commit(payload: dict) -> bool:
    if payload.get("tool_name") != "Bash":
        return False
    command = payload.get("tool_input", {}).get("command", "")
    return "git commit" in command


def is_softleader_repo() -> bool:
    try:
        result = subprocess.run(
            ["git", "remote", "-v"],
            capture_output=True,
            text=True,
            timeout=5,
        )
    except (OSError, subprocess.SubprocessError):
        return False
    if result.returncode != 0:
        return False
    return bool(REMOTE_PATTERN.search(result.stdout))


def head_commit_message() -> str:
    try:
        result = subprocess.run(
            ["git", "log", "-1", "--format=%B"],
            capture_output=True,
            text=True,
            timeout=5,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    if result.returncode != 0:
        return ""
    return result.stdout


def validate_trailer(message: str) -> str:
    """Return a reason string when non-compliant, empty string when compliant."""
    trailer = next(
        (line for line in message.splitlines() if TRAILER_PATTERN.match(line)),
        None,
    )
    if trailer is None:
        return "Missing Co-authored-by trailer entirely."
    if not trailer.startswith(CANONICAL_PREFIX):
        prefix = trailer.split(":", 1)[0]
        return (
            f"Trailer casing is wrong: got '{prefix}' — "
            f"must be '{CANONICAL_PREFIX.rstrip(':')}'."
        )
    if CANONICAL_EMAIL not in trailer:
        return f"Wrong email in trailer. Must be {CANONICAL_EMAIL}."
    return ""


def main() -> int:
    payload = read_payload()
    if not is_git_commit(payload):
        return 0
    if not is_softleader_repo():
        return 0
    reason = validate_trailer(head_commit_message())
    if not reason:
        return 0
    output = {
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "additionalContext": (
                "HEAD commit has a non-compliant Co-authored-by trailer. "
                f"Reason: {reason} "
                "Invoke the git-commit-co-author skill and amend HEAD to fix."
            ),
        }
    }
    json.dump(output, sys.stdout)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
