# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# lang
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if which brew &> /dev/null && [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
	# Ensure existing Homebrew v1 completions continue to work
	export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d";
	source "$(brew --prefix)/etc/profile.d/bash_completion.sh";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null; then
	complete -o default -o nospace -F _git g;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults;

##### For Work

# Switch between different JDK versions === Deprecated, use SDKMAN now===
# https://github.com/AdoptOpenJDK/homebrew-openjdk
# jdk() {
#   version=$1
# 	if [ -z "$version" ]
# 	then
# 		/usr/libexec/java_home -V
# 	else
#   	export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
# 	fi
#   java -version
# }
# https://github.com/sdkman/homebrew-tap
export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"


# zoxide: A smarter cd command for your terminal
# https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init bash --cmd j)"

# iTerm2 shell integration
# https://iterm2.com/documentation-shell-integration.html
[ -f ~/.iterm2_shell_integration.bash ] && source ~/.iterm2_shell_integration.bash

# https://kubernetes.io/docs/reference/kubectl/cheatsheet/
## setup autocomplete in bash into the current shell, bash-completion package should be installed first.
source <(kubectl completion bash)
source <(oc completion bash)
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# kubectl-aliases: https://github.com/ahmetb/kubectl-aliases
[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
## Use GNU watch command instead of kubectl [...] --watch
[ -f ~/.kubectl_aliases ] && source \
   <(cat ~/.kubectl_aliases | sed -r 's/(kubectl.*) --watch/watch \1/g')

# https://docs.brew.sh/Shell-Completion
if type brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      [[ -r "$COMPLETION" ]] && source "$COMPLETION"
    done
  fi
fi

# GitHub CLI: https://github.com/cli/cli
eval "$(gh completion -s bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
[ -f ~/.forgit.bash ] && source ~/.forgit.bash
[ -f ~/.nnn.bash ] && source ~/.nnn.bash

# https://formulae.brew.sh/formula/gnu-sed
export PATH="$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$PATH"

# https://github.com/kubernetes/kompose
source <(kompose completion bash)

# https://github.com/nvm-sh/nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

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
