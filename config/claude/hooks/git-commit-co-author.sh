#!/usr/bin/env bash
# Claude Code PreToolUse hook for git-commit-co-author
#
# Fires before Bash tool calls. Only injects the reminder when the command
# is a git commit. All rules (origin check, formatting, dedup) live in SKILL.md.
#
# Installation:
#   1. Copy to ~/.claude/hooks/git-commit-co-author.sh
#   2. chmod +x ~/.claude/hooks/git-commit-co-author.sh
#   3. Add hook entry to .claude/settings.json (see SKILL.md)

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

if [[ "$tool_name" == "Bash" && "$command" == *"git commit"* ]]; then
  cat <<'HOOK_JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": "When preparing a git commit, you MUST follow the git-commit-co-author skill rules."
  }
}
HOOK_JSON
else
  echo '{}'
fi
