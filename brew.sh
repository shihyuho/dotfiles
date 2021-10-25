#!/usr/bin/env bash

# Install command-line tools using Homebrew.

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names
# Install a modern version of Bash.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install `wget` with IRI support.
brew install wget --with-iri

# Install GnuPG to enable PGP-signing commits.
brew install gnupg

# Install more recent versions of some macOS tools.
brew install vim --with-override-system-vi
brew install grep
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
brew install binutils
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
brew install imagemagick --with-webp
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
brew install maven
brew install watch
brew install nnn
brew install zoxide
brew install telnet
brew install redis
brew install subversion
brew install --cask hiddenbar
brew install --cask ngrok
brew install --cask switchhosts
brew install --cask dbeaver-community
brew install --cask openvpn-connect
brew install --cask atom
brew tap mkchoi212/fac https://github.com/mkchoi212/fac.git
brew install fac
brew install jq
brew install buildpacks/tap/pack
brew install dive
brew install --cask keycastr
brew install jsonnet
brew install tldr

# Language
brew install go
brew install node
brew tap homebrew/cask-versions
brew install --cask temurin8
brew install --cask temurin11
brew install --cask macdown

# Font
brew tap homebrew/cask-fonts
brew install --cask font-fira-code
## for iTerm2, 請在去 Preferences > Profiles > Text > Change Font 修改字形
brew install --cask font-fira-code-nerd-font

# Remove outdated versions from the cellar.
brew cleanup
