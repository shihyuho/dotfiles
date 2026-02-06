#!/usr/bin/env zsh
# ---
# Tool: lazygit
# Source: https://github.com/jesseduffield/lazygit
# Purpose: Terminal UI for git
# Updated: 2026-02-06
# ---

lg() {
  export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

  lazygit "$@"

  if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
    cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
    rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
  fi
}
