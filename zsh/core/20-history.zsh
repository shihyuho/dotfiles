#!/usr/bin/env zsh
# ---
# History configuration
# No duplicate history when reverse-searching
# ---

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
