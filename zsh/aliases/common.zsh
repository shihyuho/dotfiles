#!/usr/bin/env zsh
# ---
# Common aliases
# Updated: 2026-02-06
# ---

# exa (modern ls replacement)
alias l='exa --git -laa'
alias ll='exa --git -l'
alias la='exa --git -laa'

# Enable colored grep output
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Enable aliases to be sudo'ed
alias sudo='sudo '

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\\t:]+:([^\\n]|\\n\\t)*status: active'"

# ghq shortcuts
alias g="ghq"
alias j="ghq-fzf"  # j for jump
