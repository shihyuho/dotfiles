#!/usr/bin/env zsh
# ---
# Tool: pyenv (Python Version Manager)
# Source: https://github.com/pyenv/pyenv
# Purpose: Manage multiple Python versions
# Updated: 2026-02-06
# Lazy Loading: Yes
# ---

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT" ]]; then
  export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
fi

_pyenv_load() {
  unset -f pyenv
  eval "$(command pyenv init -)"
}

pyenv() { _pyenv_load; pyenv "$@"; }
