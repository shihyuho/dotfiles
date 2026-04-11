#!/usr/bin/env bash
# Claude Code PostToolUse hook for git-commit-co-author
#
# Fires after Bash tool calls. When the command was a git commit, inspect
# HEAD's commit message for a compliant Co-authored-by trailer. Only injects
# a remediation prompt when the trailer is missing or malformed — compliant
# commits pass through silently with zero model overhead.
#
# Installation:
#   1. Copy to ~/.claude/hooks/using-git-commit-co-author-tool.sh
#   2. chmod +x ~/.claude/hooks/using-git-commit-co-author-tool.sh
#   3. Add hook entry to .claude/settings.json (see SKILL.md)

input="$(cat)"
tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty')"
command="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"

# Silently skip unless this was a git commit — no output, no context injection.
[[ "$tool_name" == "Bash" && "$command" == *"git commit"* ]] || exit 0

# Check if any remote points to github.com/softleader; skip if not.
git remote -v 2>/dev/null | grep -q 'github\.com[/:]softleader' || exit 0

# Validate the trailer in HEAD's commit message.
msg="$(git log -1 --format='%B' 2>/dev/null)"
trailer="$(printf '%s' "$msg" | grep -i '^Co-authored-by:' | head -1)"

# Build a specific reason if non-compliant.
reason=""
if [[ -z "$trailer" ]]; then
  reason="Missing Co-authored-by trailer entirely."
elif ! printf '%s' "$trailer" | grep -q '^Co-authored-by:'; then
  reason="Trailer casing is wrong: got '$(printf '%s' "$trailer" | cut -d: -f1)' — must be 'Co-authored-by'."
elif ! printf '%s' "$trailer" | grep -q '<noreply@softleader\.com\.tw>'; then
  reason="Wrong email in trailer. Must be <noreply@softleader.com.tw>."
fi

# Compliant — exit silently, no context injection, no model overhead.
[[ -n "$reason" ]] || exit 0

cat <<HOOK_JSON
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "HEAD commit has a non-compliant Co-authored-by trailer. Reason: ${reason} Invoke the git-commit-co-author skill and amend HEAD to fix."
  }
}
HOOK_JSON
