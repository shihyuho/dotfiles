#!/usr/bin/env bash
# Claude Code PostToolUse hook for git-commit-co-author
#
# Fires after Bash tool calls. When the command was a git commit, inject
# a self-check reminder: the model decides whether to act based on whether
# it already followed the skill during message composition.
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
    "hookEventName": "PostToolUse",
    "additionalContext": "If you haven't followed the git-commit-co-author skill, you MUST invoke it and amend HEAD if non-compliant."
  }
}
HOOK_JSON
else
  echo '{}'
fi
