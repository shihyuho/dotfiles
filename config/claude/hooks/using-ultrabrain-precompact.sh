#!/usr/bin/env bash
# Claude Code PreCompact hook for ultrabrain
#
# Fires before Claude Code compacts the context window. Injects a
# reminder to capture important session content before detail is lost.
# Static message — does not read vault stats. Silent (no output) if
# ~/.ultrabrain/ does not exist, so non-ultrabrain users see nothing.
#
# Installation:
#   1. Copy to ~/.claude/hooks/using-ultrabrain-precompact.sh
#   2. chmod +x ~/.claude/hooks/using-ultrabrain-precompact.sh
#   3. Add PreCompact hook entry to ~/.claude/settings.json (see setup.md)

set +e

VAULT="$HOME/.ultrabrain"

[ -d "$VAULT" ] || exit 0

cat <<'HOOK_JSON'
{
  "systemMessage": "Compaction imminent. Invoke the ultrabrain skill's capture to save anything worth keeping."
}
HOOK_JSON
