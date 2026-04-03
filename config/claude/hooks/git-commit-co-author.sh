#!/usr/bin/env bash
# Claude Code SessionStart hook for git-commit-co-author
#
# Fires once at session start to inject a reminder via additionalContext.
# All rules (origin check, formatting, dedup) live in SKILL.md.
#
# Installation:
#   1. Copy to ~/.claude/hooks/git-commit-co-author.sh
#   2. chmod +x ~/.claude/hooks/git-commit-co-author.sh
#   3. Add hook entry to .claude/settings.json (see SKILL.md)

cat <<'HOOK_JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "When preparing a git commit, you MUST follow the git-commit-co-author skill rules."
  }
}
HOOK_JSON
