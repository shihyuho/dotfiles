# Managing Brew Packages

Use this workflow when editing `brew/Brewfile`, installing packages from it, or verifying package-related dotfiles changes.

## Step 1: Edit the repo source

- Update `brew/Brewfile` in the repository.
- If the package needs shell config, pair this workflow with `references/add-tool.md`.

## Step 2: Apply the Brewfile

```bash
make brew
```

Use `bash .agents/skills/dotfiles-manager/scripts/install-brew-bundle.sh` only when you need the helper directly.

## Step 3: Verify

```bash
zsh -n ~/.zshrc
make test
```

If package changes affect shell startup or lazy-loading behavior, also run:

```bash
make measure-startup
```

## Common Mistakes

- Installing with ad-hoc `brew install ...` but forgetting to record the package in `brew/Brewfile`
- Updating tool config without adding the package to `brew/Brewfile`
- Treating package installation as separate from shell verification
