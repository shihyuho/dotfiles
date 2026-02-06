#!/usr/bin/env zsh
# ---
# Prompt configuration with cached git info
# Source: Based on previous prompt implementation
# ---

# Detect ls flavor for colors
if ls --color > /dev/null 2>&1; then  # GNU ls
  colorflag="--color"
  export LS_COLORS='no=00:fi=00:di=01;31:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
else  # macOS ls
  colorflag="-G"
  export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
fi

# Enable PROMPT_SUBST for dynamic prompt
setopt PROMPT_SUBST
autoload -Uz add-zsh-hook

# Git prompt segment (cached with TTL)
typeset -g __GIT_SEG=""
typeset -g __GIT_LAST_PWD=""
typeset -g __GIT_LAST_TS=0

_git_segment_update() {
  local now=$EPOCHSECONDS
  # Same directory + within 2 seconds -> skip update
  if [[ "$PWD" == "$__GIT_LAST_PWD" && $(( now - __GIT_LAST_TS )) -lt 2 ]]; then
    return
  fi
  __GIT_LAST_PWD="$PWD"
  __GIT_LAST_TS=$now
  __GIT_SEG=""

  command git rev-parse --is-inside-work-tree &>/dev/null || return

  local s head branch dirty=""
  s="$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v1 -b 2>/dev/null)" || return
  head="${${(f)s}[1]}"
  branch="${head#\#\# }"
  branch="${branch%%...*}"

  # Any files in status output = dirty (including untracked)
  [[ "${#${(f)s}}" -gt 1 ]] && dirty=" [*]"

  __GIT_SEG="%F{15} on %f%F{61}${branch}%f%F{33}${dirty}%f"
}

add-zsh-hook precmd _git_segment_update
add-zsh-hook chpwd  _git_segment_update

# Color setup
if tput setaf 1 &> /dev/null; then
  tput sgr0  # reset colors
  bold=$(tput bold)
  reset=$(tput sgr0)
  # Solarized colors
  black=$(tput setaf 0)
  blue=$(tput setaf 33)
  cyan=$(tput setaf 37)
  green=$(tput setaf 64)
  orange=$(tput setaf 166)
  purple=$(tput setaf 125)
  red=$(tput setaf 124)
  violet=$(tput setaf 61)
  white=$(tput setaf 15)
  yellow=$(tput setaf 136)
  grey=$(tput setaf 8)
else
  bold=''
  reset="\e[0m"
  black="\e[1;30m"
  blue="\e[1;34m"
  cyan="\e[1;36m"
  green="\e[1;32m"
  orange="\e[1;33m"
  purple="\e[1;35m"
  red="\e[1;31m"
  violet="\e[1;35m"
  white="\e[1;37m"
  yellow="\e[1;33m"
  grey="\e[1;37,47m"
fi

# User/host colors
if [[ "${USER}" == "root" ]]; then
  userStyle="${red}"
else
  userStyle="${orange}"
fi

if [[ "${SSH_TTY}" ]]; then
  hostStyle="${bold}${red}"
else
  hostStyle="${yellow}"
fi

# kube-ps1 (only if kubectl exists)
if command -v kubectl >/dev/null 2>&1; then
  source "$HOME/.kube-ps1.sh"
fi

# Build prompt
PROMPT="
%B"  # newline + bold
PROMPT+="%F${userStyle}%n%f"  # username
PROMPT+="%F${white} at %f"
PROMPT+="%F${hostStyle}%m%f"  # host
PROMPT+="%F${white} in %f"
PROMPT+="%F${green}%~%f"  # working directory
PROMPT+="%F\${__GIT_SEG}%f"  # Git info (cached)
if command -v kubectl >/dev/null 2>&1; then
  PROMPT+="\$(kube_ps1)"  # Kubernetes prompt
fi
PROMPT+="%b %F${grey}[%*]%f
%B$%b "
