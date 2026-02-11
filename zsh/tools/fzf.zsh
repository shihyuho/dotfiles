#!/usr/bin/env zsh
# ---
# Tool: FZF (Fuzzy Finder)
# Source: https://github.com/junegunn/fzf
# Purpose: Command-line fuzzy finder
# Updated: 2026-02-06
# ---

_source_fzf_script() {
  local script_path="$1"
  [[ -f "$script_path" ]] || return 0

  {
    source "$script_path"
  } 2> >(
    while IFS= read -r _fzf_stderr_line; do
      [[ "$_fzf_stderr_line" == "(eval):1: can't change option: zle" ]] && continue
      print -u2 -- "$_fzf_stderr_line"
    done
  )
}

# Load FZF configuration
_source_fzf_script "$HOME/.fzf.zsh"

# Load FZF key bindings only when not already loaded
if (( ! $+functions[fzf-file-widget] )); then
  _source_fzf_script "$HOME/.key-bindings.zsh"
fi

unset -f _source_fzf_script
