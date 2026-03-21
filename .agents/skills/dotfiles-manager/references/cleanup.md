# Cleaning Up Unused Tools

## When to Use

Use this workflow when removing a tool from dotfiles, Brewfile, and loading logic.

Execution rule: use `make` targets for standard verification; use scripts under `.agents/skills/dotfiles-manager/scripts/` for direct dependency checks or workflow internals.

## Safe Removal Workflow

### Step 1: Confirm removal intent

- Ask user if the tool is truly no longer needed.
- Identify possible replacement (if any).

### Step 2: Dependency and reference checks (required)

```bash
bash .agents/skills/dotfiles-manager/scripts/check-dependencies.sh <tool-name>
```

If dependency check is unsafe, stop and report impact.

### Step 3: Remove configuration safely

1. Remove `brew "<tool-name>"` or `cask "<app-name>"` from `brew/Brewfile`
2. Remove related config file under `zsh/tools/` (or `zsh/tools/dev/`)
3. Remove load line from `zsh/rc.zsh`
4. Update `docs/TOOLS.md` (move entry to removed section with reason/date)

### Step 4: Verify

```bash
zsh -n ~/.zshrc
make test
```

## Safety Checklist

- [ ] `check-dependencies.sh` reports safe removal before any file edits
- [ ] Repo sources were updated, not `$HOME` symlink targets
- [ ] Tool removed from `brew/Brewfile`, config files, load logic, and docs together
- [ ] Verification passed (`zsh -n ~/.zshrc` and `make test`)

## Optional Git Step

Only if user explicitly asks to commit:

```bash
git add "$DOTFILES_ROOT/brew/Brewfile" "$DOTFILES_ROOT/zsh/rc.zsh" "$DOTFILES_ROOT/docs/TOOLS.md"
git commit -m "Remove unused tool: <tool-name>"
```
