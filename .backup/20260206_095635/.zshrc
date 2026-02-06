source $HOME/.exports
source $HOME/.aliases
source $HOME/.zsh_prompt

# Use cached BREW_PREFIX from .zshenv (hardcoded)
: "${BREW_PREFIX:=$HOMEBREW_PREFIX}"

# Set GNU tools as default; see: https://gist.github.com/skyzyx/3438280b18e4f7c490db8a2a2ca0b9da
# for d in ${BREW_PREFIX}/opt/*/libexec/gnubin; do export PATH=$d:$PATH; done
# libtool 會影響 node-sass 編譯，因此我不要置換成 gnu 的
for d in ${BREW_PREFIX}/opt/*/libexec/gnubin; do
	if [[ ! $d =~ "libtool" ]]; then
		export PATH=$d:$PATH
	fi
done

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"

# --- Completion Cache Setup ---
: "${XDG_CACHE_HOME:=$HOME/.cache}"
ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
mkdir -p "$ZSH_CACHE_DIR"

ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-${ZSH_VERSION}"

# Setup custom completion directory
ZSH_COMP_DIR="$ZSH_CACHE_DIR/completions"
mkdir -p "$ZSH_COMP_DIR"
fpath=("$ZSH_COMP_DIR" $fpath)

# Generate completion cache for tools that don't have Homebrew completion
_zsh_gen_completion() {
  local tool="$1" cmdline="$2"
  local out="$ZSH_COMP_DIR/_${tool}"
  local bin; bin="$(command -v "$tool" 2>/dev/null)" || return 0

  # Only rebuild if missing or tool binary is newer
  if [[ ! -s "$out" || "$bin" -nt "$out" ]]; then
    umask 077
    {
      print -r -- "#compdef ${tool}"
      eval "$cmdline"
    } >| "${out}.tmp" && mv -f "${out}.tmp" "$out"
  fi
}

# Generate completions for k9s and opencode
_zsh_gen_completion k9s 'k9s completion zsh'
_zsh_gen_completion opencode 'opencode completion'

# Enabling the Zsh Completion System (with smart caching)
autoload -Uz compinit promptinit

# Only rebuild completion dump when needed
if [[ ! -s "$ZSH_COMPDUMP" \
   || "$HOME/.zshrc" -nt "$ZSH_COMPDUMP" \
   || "${BREW_PREFIX}/share/zsh/site-functions" -nt "$ZSH_COMPDUMP" ]]; then
  compinit -d "$ZSH_COMPDUMP"
else
  compinit -C -d "$ZSH_COMPDUMP"
fi

## case-insensitive (all) completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Enable completion cache for some completers
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"

# https://kubernetes.io/docs/reference/kubectl/cheatsheet/
# kubectl, oc, kompose completions are provided by Homebrew in site-functions
# No need to source them explicitly
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# k9s and opencode completions will be cached (see completion cache section below)

# No duplicate history when reverse-searching my commands
HISTSIZE=5000
HISTFILE=$HOME/.zsh_history
SAVEHIST=5000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Zsh syntax highlighting
source ${BREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zoxide: A smarter cd command for your terminal
# https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh --cmd z)"

# --- NVM (Lazy Loading) ---
# https://github.com/nvm-sh
# https://github.com/nvm-sh/nvm#macos-troubleshooting
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

# --- Pyenv (Lazy Loading) ---
# https://github.com/pyenv/pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT" ]]; then
  export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
fi

_pyenv_load() {
  unset -f pyenv
  eval "$(command pyenv init -)"
}

pyenv() { _pyenv_load; pyenv "$@"; }

# --- SDKMAN (Lazy Loading) ---
# https://sdkman.io
# SDKMAN 我們故意不用 homebrew 安裝，其原因是 brew 安裝的 SDKMAN 沒辦法指定 SDKMAN_DIR
# 又 homebrew 安裝的 SDKMAN_DIR 會預設在 homebrew 中該 formula 下，造成日後更新 SDKMAN 時會遺失安裝過的 sdk
export SDKMAN_DIR="$HOME/.sdkman"

_sdkman_load() {
  unset -f sdk
  if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
  else
    echo "Warning: '${SDKMAN_DIR}/bin/sdkman-init.sh' not found. Run 'curl -s \"https://get.sdkman.io\" | bash' to install SDKMAN, Visit https://sdkman.io for more details."
  fi
}

sdk() { _sdkman_load; sdk "$@"; }

# Load secrets (API keys, tokens, etc.)
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

# Antigravity
export ANTIGRAVITY_PATH=${HOME}/.antigravity/antigravity/bin
export PATH=${ANTIGRAVITY_PATH}:$PATH
