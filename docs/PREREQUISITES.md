# Prerequisites

Before installing this dotfiles repo, install the items below for your platform.

> **Platform support**: Symlink installation (`make install`) is tested in CI on both macOS and Linux. Homebrew package install (`make brew`) is **macOS only** — the Brewfile contains macOS-only casks (`iterm2`, `karabiner-elements`, etc.).

## macOS

1. **Xcode Command Line Tools** (for `git` and compilers):

   ```bash
   xcode-select --install
   ```

2. **Homebrew** (for `make brew`):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

## Linux

Install `git`, `zsh`, `bc`, and a C build toolchain.

**Ubuntu / Debian:**

```bash
sudo apt-get update
sudo apt-get install -y git zsh bc build-essential
```

**Fedora / RHEL:**

```bash
sudo dnf install -y git zsh bc gcc make
```

**Arch:**

```bash
sudo pacman -S --needed git zsh bc base-devel
```

> Linux users skip `make brew` — install tools like `fzf`, `ripgrep`, `exa`, `zoxide` via your distro's package manager separately. Run only `make install` for symlinks.

---

Already have what you need? Continue to:

- [README → Quick Start](../README.md#quick-start) to choose AI-assisted or manual install, or
- [SETUP.md](SETUP.md) to jump straight into manual install.
