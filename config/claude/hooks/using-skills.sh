#!/usr/bin/env bash
# Claude Code SessionStart hook for using preferred skills

cat <<'HOOK_JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Invoke the skills: planning-with-files, lessons-learned."
  }
}
HOOK_JSON
