#!/usr/bin/env zsh
# ---
# Tool: ghq
# Source: https://github.com/x-motemen/ghq
# Purpose: Manage remote repository clones
# Updated: 2026-02-06
# ---

function ghq-fzf() {
  if [ "$1" = "$HOME" ]; then
    cd "$GHQ_ROOT"
  else
    local selected_dir=$(ghq list | fzf --height ${FZF_TMUX_HEIGHT:-40%} --cycle --info=inline --reverse --border --select-1 --query="$1" --preview "(bat --style=plain --color=always $GHQ_ROOT/{}/README.md 2>/dev/null || tree -C $GHQ_ROOT/{}) | head -100")
    if [ -n "$selected_dir" ]; then
      cd "$GHQ_ROOT/${selected_dir}"
    fi
  fi
}

# Project navigation with fzf
function pj() {
  if [ "$1" = "$HOME" ]; then
    cd "$PJ_ROOT"
  else
    local selected_dir=$(find $PJ_ROOT -type d | fzf --height ${FZF_TMUX_HEIGHT:-40%} --cycle --info=inline --reverse --border --select-1 --query="$1" --preview "(exa --git -l -F {}) | head -100")
    if [ -n "$selected_dir" ]; then
      cd "${selected_dir}"
    fi
  fi
}
