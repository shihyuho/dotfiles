#!/usr/bin/env bash
# Claude Code SessionStart hook for caveman skill
#
# Fires once at session start to auto-activate caveman mode.

cat <<'HOOK_JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Use caveman skill."
  }
}
HOOK_JSON
