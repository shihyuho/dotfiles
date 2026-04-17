#!/usr/bin/env python3
"""Claude Code SessionStart hook for git-commit-co-author.

Fires once at session start. If the working directory is a softleader repo,
reminds the model to follow the git-commit-co-author skill when composing
commits. Non-softleader repos get zero context injection.

Cross-platform: uses only the Python standard library. Works on macOS, Linux,
and Windows without `jq`, `grep`, or a POSIX shell.

Installation: see references/setup.md.
"""

import json
import re
import subprocess
import sys

REMOTE_PATTERN = re.compile(r"github\.com[/:]softleader")
REMINDER = (
    "This is a softleader repo. When composing git commits, "
    "you MUST invoke the git-commit-co-author skill."
)


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


def main() -> int:
    if not is_softleader_repo():
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
