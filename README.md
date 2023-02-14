# Shihyu’s dotfiles

![](./rsync_exclude/neofetch.png)

## Installation

```bash
git clone https://github.com/shihyuho/dotfiles.git && cd dotfiles && source bootstrap.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

### Install Homebrew formulas

```bash
./brew.sh
```

### Install Go executables

```bash
./go-install.sh
```
