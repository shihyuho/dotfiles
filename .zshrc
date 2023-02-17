source $HOME/.exports
source $HOME/.aliases
source $HOME/.zsh_prompt

# Set GNU tools as default; see: https://gist.github.com/skyzyx/3438280b18e4f7c490db8a2a2ca0b9da
for d in $(brew --prefix)/opt/*/libexec/gnubin; do export PATH=$d:$PATH; done

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# Enabling the Zsh Completion System
autoload -Uz compinit promptinit
## case-insensitive (all) completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
compinit

# https://kubernetes.io/docs/reference/kubectl/cheatsheet/
# setup autocomplete in bash into the current shell, bash-completion package should be installed first.
source <(kubectl completion zsh)
source <(oc completion zsh)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# https://github.com/kubernetes/kompose
source <(kompose completion zsh)

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
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zoxide: A smarter cd command for your terminal
# https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh --cmd z)"

# https://sdkman.io
# SDKMAN 我們故意不用 homebrew 安裝, 其原因是 brew 安裝的 SDKMAN 沒辦法指定 SDKMAN_DIR
# 又 homebrew 安裝的 SDKMAN_DIR 會預設在 homebrew 中該 formula 下, 造成日後更新 SDKMAN 時會遺失安裝過的 sdk
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR=$HOME/.sdkman
if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
  source "${SDKMAN_DIR}/bin/sdkman-init.sh"
else
  echo "Warning: '${SDKMAN_DIR}/bin/sdkman-init.sh' not found. Run 'curl -s \"https://get.sdkman.io\" | bash' to install SDKMAN!"
fi
