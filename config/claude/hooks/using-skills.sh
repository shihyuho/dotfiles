#!/usr/bin/env bash
# Claude Code SessionStart hook for using preferred skills

cat <<'HOOK_JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Use skills: planning-with-files, lessons-learned, caveman."
  }
}
HOOK_JSON
