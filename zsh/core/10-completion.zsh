#!/usr/bin/env zsh
# ---
# Zsh completion system configuration
# Optimized with caching for fast startup
# ---

# Cache directory setup
: "${XDG_CACHE_HOME:=$HOME/.cache}"
ZSH_CACHE_DIR="$XDG_CACHE_HOME/zsh"
mkdir -p "$ZSH_CACHE_DIR"

# Completion dump file (versioned by zsh version)
ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-${ZSH_VERSION}"

# Custom completion directory for generated completions
ZSH_COMP_DIR="$ZSH_CACHE_DIR/completions"
mkdir -p "$ZSH_COMP_DIR"
fpath=("$ZSH_COMP_DIR" $fpath)

# Add Homebrew completions to fpath
FPATH="${BREW_PREFIX}/share/zsh/site-functions:${FPATH}"

# Generate completion cache for tools without Homebrew completion
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

# Generate completions for tools
_zsh_gen_completion k9s 'k9s completion zsh'
_zsh_gen_completion opencode 'opencode completion'

# Initialize completion system
autoload -Uz compinit promptinit

# Resolve dotfiles root for cache invalidation checks
_dotfiles_root="${DOTFILES_ROOT:-${${(%):-%N}:A:h:h:h}}"
_dotfiles_rc="${_dotfiles_root}/zsh/rc.zsh"

# Smart caching: only rebuild when necessary
if [[ ! -s "$ZSH_COMPDUMP" \
   || "${_dotfiles_rc}" -nt "$ZSH_COMPDUMP" \
   || "${BREW_PREFIX}/share/zsh/site-functions" -nt "$ZSH_COMPDUMP" ]]; then
  compinit -d "$ZSH_COMPDUMP"
else
  compinit -C -d "$ZSH_COMPDUMP"
fi

unset _dotfiles_root _dotfiles_rc

# Completion styles
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR/zcompcache"
