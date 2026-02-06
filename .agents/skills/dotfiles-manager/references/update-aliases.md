# Updating External Alias Files

## When to Use

Use this workflow when upstream alias sources changed and you want to refresh local alias files.

Execution rule: use `.agents/skills/dotfiles-manager/scripts/update-aliases.sh` as the workflow entrypoint.

## Managed Alias Sources

- `kubectl-aliases`: `https://github.com/ahmetb/kubectl-aliases` -> `$HOME/.kubectl_aliases`
- `gitalias`: `https://github.com/GitAlias/gitalias` -> `$DOTFILES_ROOT/git/aliases/gitalias`

## Preferred Workflow

Use the built-in script:

```bash
# Update both
bash .agents/skills/dotfiles-manager/scripts/update-aliases.sh all

# Update one source only
bash .agents/skills/dotfiles-manager/scripts/update-aliases.sh kubectl
bash .agents/skills/dotfiles-manager/scripts/update-aliases.sh gitalias
```

## Script-First Rule

Do not copy manual curl/cat steps into workflow execution.
If customization is needed, update `scripts/update-aliases.sh` and keep the workflow entrypoint script-based.

### Step 3: Verify

```bash
bash .agents/skills/dotfiles-manager/scripts/test.sh
zsh -i -c "alias | grep kubectl | head -5"
```

## Performance Notes

If startup regresses after alias updates:

1. Check load guards in `zsh/tools/kubectl.zsh`
2. Prefer conditional loading over unconditional `source`
3. Measure with `make measure-startup`

## Optional Git Step

Only if the user explicitly asks for commit:

```bash
git add "$DOTFILES_ROOT/git/aliases/gitalias" "$HOME/.kubectl_aliases"
git commit -m "Update external aliases"
```
