#!/usr/bin/env bash
# Claude Code SessionStart hook for git-commit-co-author
#
# Fires once at session start. If the working directory is a softleader repo,
# reminds the model to follow the git-commit-co-author skill when composing
# commits. Non-softleader repos get zero context injection.
#
# Installation:
#   1. Copy to ~/.claude/hooks/using-git-commit-co-author-session.sh
#   2. chmod +x ~/.claude/hooks/using-git-commit-co-author-session.sh
#   3. Add hook entry to .claude/settings.json (see SKILL.md)

# Check if any remote points to github.com/softleader; skip if not.
git remote -v 2>/dev/null | grep -q 'github\.com[/:]softleader' || exit 0

cat <<'HOOK_JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "This is a softleader repo. When composing git commits, you MUST invoke the git-commit-co-author skill."
  }
}
HOOK_JSON
