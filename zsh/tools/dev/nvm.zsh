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
  unset -f nvm node npm npx corepack yarn pnpm
  [ -s "${BREW_PREFIX}/opt/nvm/nvm.sh" ] && \. "${BREW_PREFIX}/opt/nvm/nvm.sh"
  [ -s "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm" ] && \. "${BREW_PREFIX}/opt/nvm/etc/bash_completion.d/nvm"
}

nvm()     { _nvm_load; nvm "$@"; }
node()    { _nvm_load; node "$@"; }
npm()     { _nvm_load; npm "$@"; }
npx()     { _nvm_load; npx "$@"; }
corepack(){ _nvm_load; corepack "$@"; }
yarn()    { _nvm_load; yarn "$@"; }
pnpm()    { _nvm_load; pnpm "$@"; }
