# Updating External Alias Files

## When to Use

Use this workflow when upstream alias sources changed and you want to refresh local alias files.

## Managed Alias Sources

- `kubectl-aliases`: `https://github.com/ahmetb/kubectl-aliases` -> `$HOME/.kubectl_aliases`
- `gitalias`: `https://github.com/GitAlias/gitalias` -> `$DOTFILES_ROOT/git/aliases/gitalias`

## Preferred Workflow

Use the built-in script:

```bash
# Update both
.agents/skills/dotfiles-manager/scripts/update-aliases.sh all

# Update one source only
.agents/skills/dotfiles-manager/scripts/update-aliases.sh kubectl
.agents/skills/dotfiles-manager/scripts/update-aliases.sh gitalias
```

## Manual Workflow (if script customization is needed)

### Step 1: Download upstream files

```bash
curl -sSL -o /tmp/kubectl_aliases \
  https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases

curl -sSL -o /tmp/gitalias \
  https://raw.githubusercontent.com/GitAlias/gitalias/main/gitalias.txt
```

### Step 2: Write local files with metadata headers

```bash
cat << EOF > "$HOME/.kubectl_aliases"
# ---
# Tool: kubectl-aliases
# Source: https://github.com/ahmetb/kubectl-aliases
# Purpose: 800+ kubectl shortcuts
# Updated: $(date +%Y-%m-%d)
# ---

EOF
cat /tmp/kubectl_aliases >> "$HOME/.kubectl_aliases"

cat << EOF > "$DOTFILES_ROOT/git/aliases/gitalias"
# ---
# Tool: gitalias
# Source: https://github.com/GitAlias/gitalias
# Purpose: 1780+ git aliases
# Updated: $(date +%Y-%m-%d)
# ---

EOF
cat /tmp/gitalias >> "$DOTFILES_ROOT/git/aliases/gitalias"
```

### Step 3: Verify

```bash
zsh -n ~/.zshrc
zsh -i -c "alias | grep kubectl | head -5"
make test
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
