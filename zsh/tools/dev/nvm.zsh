#!/usr/bin/env zsh
# ---
# Tool: nvm (Node Version Manager)
# Source: https://github.com/nvm-sh/nvm
# Purpose: Manage multiple Node.js versions
# Updated: 2026-02-06
# Lazy Loading: Yes (reduces startup time by ~100ms)
# ---

export NVM_DIR="$HOME/.nvm"
mkdir -p "${NVM_DIR}"

_nvm_load() {
  unset -f _nvm_load nvm node npm npx corepack yarn pnpm
  [ -s "${BREW_PREFIX}/opt/nvm/nvm.sh" ] && \. "${BREW_PREFIX}/opt/nvm/nvm.sh"
  [ -s "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && \. "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"
}

nvm()     { unset -f nvm;      _nvm_load 2>/dev/null; nvm "$@"; }
node()    { unset -f node;     _nvm_load 2>/dev/null; node "$@"; }
npm()     { unset -f npm;      _nvm_load 2>/dev/null; npm "$@"; }
npx()     { unset -f npx;      _nvm_load 2>/dev/null; npx "$@"; }
corepack(){ unset -f corepack; _nvm_load 2>/dev/null; corepack "$@"; }
yarn()    { unset -f yarn;     _nvm_load 2>/dev/null; yarn "$@"; }
pnpm()    { unset -f pnpm;     _nvm_load 2>/dev/null; pnpm "$@"; }
