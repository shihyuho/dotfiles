#!/usr/bin/env bash
# Lightweight Claude Code status line — pure shell + jq, no Node.js overhead.
# Receives JSON on stdin from Claude Code, outputs ANSI-colored status text.
set -euo pipefail

INPUT=$(cat)
# Parse all fields in a single jq call for speed
eval "$(echo "$INPUT" | jq -r '
  @sh "MODEL=\(.model // "" | if type == "object" then (.display_name // .id // "") else . end)",
  @sh "CTX_USED=\(.context_window.used_percentage // 0 | round)",
  @sh "CTX_MAX=\(.context_window.context_window_size // 0)",
  @sh "CWD=\(.cwd // .workspace.current_dir // "")",
  @sh "VERSION=\(.version // "")",
  @sh "RL_5H=\(.rate_limits.five_hour.used_percentage // 0 | round)",
  @sh "RL_5H_RESET=\(.rate_limits.five_hour.resets_at // 0)",
  @sh "RL_7D=\(.rate_limits.seven_day.used_percentage // 0 | round)",
  @sh "RL_7D_RESET=\(.rate_limits.seven_day.resets_at // 0)"
' 2>/dev/null)" || exit 0

# Git info — cached for 5s to avoid hammering git on every render
CACHE="/tmp/statusline-git-cache"
BRANCH=""
WORKTREE_NAME=""
if [[ -n "$CWD" ]]; then
  NOW=$(date +%s)
  CACHE_HIT=false
  if [[ -f "$CACHE" ]]; then
    CACHE_TIME=$(head -1 "$CACHE")
    CACHE_DIR=$(sed -n '2p' "$CACHE")
    if (( NOW - CACHE_TIME < 5 )) && [[ "$CACHE_DIR" == "$CWD" ]]; then
      BRANCH=$(sed -n '3p' "$CACHE")
      WORKTREE_NAME=$(sed -n '4p' "$CACHE")
      CACHE_HIT=true
    fi
  fi
  if [[ "$CACHE_HIT" == false ]]; then
    BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
    # Detect if we're in a worktree (not the main working tree)
    if [[ -n "$BRANCH" ]]; then
      GIT_TOPLEVEL=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || true)
      GIT_COMMON=$(git -C "$CWD" rev-parse --git-common-dir 2>/dev/null || true)
      GIT_DIR=$(git -C "$CWD" rev-parse --git-dir 2>/dev/null || true)
      # If git-dir != git-common-dir, we're in a linked worktree
      if [[ -n "$GIT_DIR" && -n "$GIT_COMMON" && "$GIT_DIR" != "$GIT_COMMON" && -n "$GIT_TOPLEVEL" ]]; then
        WORKTREE_NAME=$(basename "$GIT_TOPLEVEL")
      fi
    fi
    printf '%s\n%s\n%s\n%s\n' "$NOW" "$CWD" "$BRANCH" "$WORKTREE_NAME" > "$CACHE"
  fi
fi


# Colors
RST='\033[0m'
DIM='\033[2m'
CYAN='\033[36m'
BRANCH_CLR='\033[38;5;175m'
DIR_CLR='\033[38;5;173m'

# Effort level — read from env (set in settings.json)
EFFORT="${CLAUDE_CODE_EFFORT_LEVEL:-}"
case "$EFFORT" in
  low)      EFFORT_CLR='\033[38;5;114m' ;;  # green — chill
  medium)   EFFORT_CLR='\033[38;5;228m' ;;  # yellow — working
  high)     EFFORT_CLR='\033[38;5;214m' ;;  # orange — serious
  max)      EFFORT_CLR='\033[38;5;203m' ;;  # red — going for it
  *)        EFFORT_CLR="$DIM" ;;            # dim — unset/unknown
esac

# Context bar color: yellow → orange → red gradient (ANSI 256)
# 228=light yellow, 222, 216, 210, 204, 196=red
GRADIENT=(228 222 216 210 204 196)
FADED_GRADIENT=(143 137 131 95 89 52)
IDX=$(( CTX_USED * 5 / 100 ))
(( IDX > 5 )) && IDX=5
CTX_COLOR="\033[38;5;${GRADIENT[$IDX]}m"
CTX_FADED="\033[38;5;${FADED_GRADIENT[$IDX]}m"

# Format token counts (e.g. 130000 → 130k, 1200000 → 1.2M)
fmt_tokens() {
  local n=$1
  if (( n >= 1000000 )); then
    awk "BEGIN{v=${n}/1000000; printf (v==int(v)) ? \"%dM\" : \"%.1fM\", v}"
  elif (( n >= 1000 )); then
    echo "$(( n / 1000 ))k"
  else
    echo "$n"
  fi
}
CTX_USED_TOKENS=$(( CTX_MAX * CTX_USED / 100 ))

# Build line 1
LINE1=""
[[ -n "$MODEL" ]]   && LINE1+="${CYAN}${MODEL}${RST}"
[[ -n "$EFFORT" ]]  && LINE1+=" ${EFFORT_CLR}${EFFORT}${RST}"
LINE1+=" ${DIM}│${RST} ${CTX_COLOR}${CTX_USED}%${RST} ${DIM}(${RST}${CTX_COLOR}$(fmt_tokens $CTX_USED_TOKENS)${DIM}/${RST}${CTX_FADED}$(fmt_tokens $CTX_MAX)${DIM})${RST}"


# Rate limit color based on projected usage at reset time
# Green → yellow → orange → red (ANSI 256)
RL_COLORS=(114 150 228 214 196)

# Calculate projected % at reset: (used / elapsed_pct) * 100
# If elapsed < 5% of window, fall back to raw used_pct (not enough data)
rl_danger() {
  local used=$1 reset_at=$2 window=$3
  local now elapsed elapsed_pct projected
  now=$(date +%s)
  elapsed=$(( window - (reset_at - now) ))
  (( elapsed < 0 )) && elapsed=0
  elapsed_pct=$(( elapsed * 100 / window ))
  if (( elapsed_pct < 5 )); then
    echo "$used"
  else
    projected=$(( used * 100 / elapsed_pct ))
    echo "$projected"
  fi
}

rl_color_for() {
  local projected=$1
  local idx
  if   (( projected <= 50  )); then idx=0   # green — plenty of room
  elif (( projected <= 75  )); then idx=1   # green-yellow — fine
  elif (( projected <= 90  )); then idx=2   # yellow — watch it
  elif (( projected <= 100 )); then idx=3   # orange — cutting it close
  else                              idx=4   # red — will exceed
  fi
  printf '\033[38;5;%sm' "${RL_COLORS[$idx]}"
}

# Format reset timer (seconds → Xh Ym)
fmt_reset() {
  local now reset_at remaining h m
  now=$(date +%s)
  reset_at=$1
  if (( reset_at <= now )); then
    echo "now"
    return
  fi
  remaining=$(( reset_at - now ))
  local d h m
  d=$(( remaining / 86400 ))
  h=$(( (remaining % 86400) / 3600 ))
  m=$(( (remaining % 3600) / 60 ))
  if (( d > 0 )); then
    echo "${d}d${h}h"
  elif (( h > 0 )); then
    echo "${h}h${m}m"
  else
    echo "${m}m"
  fi
}

# Rate limits display
RL_5H_PROJ=$(rl_danger "$RL_5H" "$RL_5H_RESET" 18000)
RL_7D_PROJ=$(rl_danger "$RL_7D" "$RL_7D_RESET" 604800)
RL_5H_COLOR=$(rl_color_for "$RL_5H_PROJ")
RL_7D_COLOR=$(rl_color_for "$RL_7D_PROJ")
RL_5H_TIMER=$(fmt_reset "$RL_5H_RESET")
RL_7D_TIMER=$(fmt_reset "$RL_7D_RESET")

LINE1+=" ${DIM}│${RST} ⚡ ${RL_5H_COLOR}5h:${RL_5H}%${RST} ${DIM}${RL_5H_TIMER}${RST} ${RL_7D_COLOR}7d:${RL_7D}%${RST} ${DIM}${RL_7D_TIMER}${RST}"

# Build line 2: CWD + branch
LEFT_TEXT="${CWD/#"$HOME"/~}"
LINE2="${DIR_CLR}${LEFT_TEXT}${RST}"
BRANCH_ICON=$(printf '\xee\x82\xa0')
[[ -n "$BRANCH" ]] && LINE2+=" ${BRANCH_ICON} ${BRANCH_CLR}${BRANCH}${RST}"
[[ -n "$WORKTREE_NAME" ]] && LINE2+=" ${DIM}[${WORKTREE_NAME}]${RST}"

# Prefix with ANSI reset to override Claude Code's dim, convert spaces to NBSP (U+00A0) to prevent trimming
NBSP=$'\xc2\xa0'
OUTPUT=$(printf '%b\n%b\n' "\033[0m${LINE1}" "\033[0m${LINE2}")
echo "${OUTPUT// /${NBSP}}"
