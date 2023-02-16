# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Switch between different JDK versions === Deprecated, use SDKMAN now===
# https://github.com/sdkman/homebrew-tap
export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"

# iTerm2 shell integration
# https://iterm2.com/documentation-shell-integration.html
[ -f $HOME/.iterm2_shell_integration.zsh ] && source $HOME/.iterm2_shell_integration.zsh

# https://formulae.brew.sh/formula/gnu-sed
export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"

# FZF
source "$HOME/.fzf.zsh"

# https://github.com/jesseduffield/lazygit
lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}

# Set Golang env, ref: https://golang.org/doc/gopath_code#GOPATH
export PATH=/opt/homebrew/bin:$PATH
export GOPATH=$(go env GOPATH)
export PATH=$PATH:$GOPATH/bin

# Add scripts for JetBrains Toolbox
export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts":$PATH

# https://github.com/x-motemen/ghq
export GHQ_ROOT="$HOME/code"
function ghq-fzf() {
	if [ "$1" = "$HOME" ]; then
		cd "$GHQ_ROOT"
	else
		local selected_dir=$(ghq list | fzf --height ${FZF_TMUX_HEIGHT:-40%} --info=inline --reverse --border --select-1 --query="$1" --preview "(cat $GHQ_ROOT/{}/README.md 2>/dev/null || tree -C $GHQ_ROOT/{}) | head -100")
		if [ -n "$selected_dir" ]; then
			cd "$GHQ_ROOT/${selected_dir}"
		fi
	fi
}

# For docker run on Apple Silicon
export DOCKER_DEFAULT_PLATFORM=linux/amd64

