#!/usr/bin/env bash
# Claude Code SessionStart hook for ultrabrain
#
# Fires once at session start. If ~/.ultrabrain/ exists, injects a
# one-line vault status into Claude's context so the model is aware
# the vault is available. Silent (no output) if the vault does not
# exist, so non-ultrabrain users see nothing.
#
# Installation:
#   1. Copy to ~/.claude/hooks/using-ultrabrain-session.sh
#   2. chmod +x ~/.claude/hooks/using-ultrabrain-session.sh
#   3. Add SessionStart hook entry to ~/.claude/settings.json (see setup.md)

set +e

VAULT="$HOME/.ultrabrain"

[ -d "$VAULT" ] || exit 0

wiki_count=$(find "$VAULT/wiki" -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
raw_count=$(find "$VAULT/raw" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

last_ingest=""
if [ -f "$VAULT/log.md" ]; then
    last_ingest=$(grep ' INGEST ' "$VAULT/log.md" 2>/dev/null | tail -n 1 | awk '{print $1}')
fi

if [ -n "$last_ingest" ]; then
    msg="ultrabrain vault available at ~/.ultrabrain/ — ${wiki_count} wiki pages, ${raw_count} unprocessed raw entries, last ingest ${last_ingest}. Consult index.md before answering factual questions that may be covered."
else
    msg="ultrabrain vault available at ~/.ultrabrain/ — ${wiki_count} wiki pages, ${raw_count} unprocessed raw entries, no ingest yet. Consult index.md before answering factual questions that may be covered."
fi

cat <<HOOK_JSON
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "${msg}"
  }
}
HOOK_JSON
