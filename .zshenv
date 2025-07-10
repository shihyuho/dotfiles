# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# iTerm2 shell integration
# https://iterm2.com/documentation-shell-integration.html
[ -f $HOME/.iterm2_shell_integration.zsh ] && source $HOME/.iterm2_shell_integration.zsh

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
# Cache the GOPATH to avoid running 'go env' on every shell startup.
: "${GOPATH:=$(go env GOPATH)}"
export PATH="$PATH:$GOPATH/bin"

# Add scripts for JetBrains Toolbox
export PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts":$PATH

# https://github.com/x-motemen/ghq
export GHQ_ROOT="$HOME/code"
function ghq-fzf() {
	if [ "$1" = "$HOME" ]; then
		cd "$GHQ_ROOT"
	else
		local selected_dir=$(ghq list | fzf --height ${FZF_TMUX_HEIGHT:-40%} --cycle --info=inline --reverse --border --select-1 --query="$1" --preview "(bat --style=plain --color=always $GHQ_ROOT/{}/README.md 2>/dev/null || tree -C $GHQ_ROOT/{}) | head -100")
		if [ -n "$selected_dir" ]; then
			cd "$GHQ_ROOT/${selected_dir}"
		fi
	fi
}

# For docker run on Apple Silicon
export DOCKER_DEFAULT_PLATFORM=linux/amd64

export PJ_ROOT="$HOME/Documents/Projects"
function pj() {
	if [ "$1" = "$HOME" ]; then
		cd "$PJ_ROOT"
	else
		local selected_dir=$(find $PJ_ROOT -type d | fzf --height ${FZF_TMUX_HEIGHT:-40%} --cycle --info=inline --reverse --border --select-1 --query="$1" --preview "(exa --git -l -F {}) | head -100")
		if [ -n "$selected_dir" ]; then
			cd "${selected_dir}"
		fi
	fi
}
