#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU tools; see https://gist.github.com/skyzyx/3438280b18e4f7c490db8a2a2ca0b9da
brew install autoconf binutils coreutils diffutils ed findutils flex gawk \
    gnu-indent gnu-sed gnu-tar gnu-which gpatch grep gzip less m4 make nano \
    screen watch wdiff wget zip

# Install some other useful utilities like `sponge`.
brew install moreutils

# 有些 node 需要這個版本，因此我們多安裝一個
brew install pyenv
pyenv install 3.12
pyenv global 3.12
brew install openssh
brew install screen
brew install php
brew install gmp

# Install font tools.
brew tap bramstein/webfonttools
brew install sfnt2woff
brew install sfnt2woff-zopfli
brew install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
brew install aircrack-ng
brew install bfg
brew install binwalk
brew install cifer
brew install dex2jar
brew install dns2tcp
brew install fcrackzip
brew install foremost
brew install hashpump
brew install hydra
brew install john
brew install knock
brew install netpbm
brew install nmap
brew install pngcheck
brew install socat
brew install sqlmap
brew install tcpflow
brew install tcpreplay
brew install tcptrace
brew install ucspi-tcp # `tcpserver` etc.
brew install xpdf
brew install xz

# Install other useful binaries.
brew install ack
#brew install exiv2
brew install git
brew install git-lfs
brew install gs
brew install imagemagick
brew install lua
brew install lynx
brew install p7zip
brew install pigz
brew install pv
brew install rename
brew install rlwrap
brew install ssh-copy-id
brew install tree
brew install vbindiff
brew install zopfli
brew install neofetch

# Tools for work
brew install kube-ps1
brew install gh
brew install openshift-cli
brew install kubernetes-cli
brew install tmux
brew install fzf
brew install ripgrep
brew install fd
brew install gh
brew install exa
brew install helm
brew install kustomize
brew install zoxide
brew install telnet
brew install redis
brew install subversion
brew install ngrok/ngrok/ngrok
brew install --cask switchhosts
brew install --cask dbeaver-community
brew install --cask openvpn-connect
brew install jq
brew install buildpacks/tap/pack
brew install dive
brew install --cask keycastr
brew install jsonnet
brew install tldr
brew install kcat
brew install kompose
brew install marp-cli
brew install pnpm
brew install jesseduffield/lazygit/lazygit
brew install ncdu
brew install --cask macdown
brew install hugo
brew install --cask rectangle
brew install --cask alt-tab
brew install --cask iterm2
brew install --cask jetbrains-toolbox
brew install --cask snipaste
brew install --cask spotify
brew install --cask slack
brew install --cask bitwarden
brew install --cask raycast
brew install --cask drawio
brew install --cask sublime-text
brew install --cask visual-studio-code
brew install ghq
brew install --cask microsoft-teams
brew install --cask notion
brew install --cask mimestream
brew install zsh-syntax-highlighting
brew install --cask beyond-compare
brew install --cask aerial
brew isntall mkcert
brew install --cask iina
brew install --cask keka
brew install --cask kekaexternalhelper
brew install --cask appcleaner
brew install ansible
brew install asciidoctor
brew tap spring-io/tap
brew install spring-boot
brew install orbstack
brew install colima
brew install derailed/k9s/k9s
brew install liquibase
brew install oha

# Language
brew install go
brew install nvm
brew install oven-sh/bun/bun

# Font
brew tap homebrew/cask-fonts
brew install --cask font-fira-code
## for iTerm2, 請在去 Preferences > Profiles > Text > Change Font 修改字形
brew install --cask font-fira-code-nerd-font

# # https://github.com/vChewing/vChewing-macOS
# brew tap windwords/vchewing
# brew install --cask vchewing

brew install --cask ghostty

# Remove outdated versions from the cellar.
brew cleanup
