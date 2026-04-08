#!/usr/bin/env zsh
# ---
# Tool: Git helpers
# Purpose: Interactive git workflows (requires fzf, delta)
# Updated: 2026-04-08
# ---

# gdiff - interactive file-by-file diff between two refs
# Usage: gdiff main...feat            (compare main..feat)
#        gdiff main                    (base=main, fzf select target)
#        gdiff ...feat                 (fzf select base, target=feat)
#        gdiff                         (fzf select both)
gdiff() {
  if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'HELP'
gdiff - Interactive file-by-file diff between two git refs (fzf + delta)

Usage: gdiff [base][...target]

  gdiff                  fzf select both branches
  gdiff main             base=main, fzf select target
  gdiff ...feat          fzf select base, target=feat
  gdiff main...feat      compare main..feat directly

Symbols:
  ○  Not viewed
  ✓  Viewed (unchanged)
  ⚠  Viewed but diff changed since last viewed

Keybindings:
  space     Toggle viewed mark (✓/○), persists across sessions
  enter     Full-screen diff (q to exit)
  ctrl-x    Reset all viewed marks
  ctrl-s    Toggle preview panel
  esc       Quit
HELP
    return 0
  fi

  local base="" target=""

  if [[ -n "$1" ]]; then
    if [[ "$1" == *...* ]]; then
      base="${1%%...*}"
      target="${1#*...}"
    else
      base="$1"
    fi
  fi

  _gdiff_pick_branch() {
    local header="$1"
    git for-each-ref --sort=-committerdate refs/heads/ \
      --format='%(refname:short)	%(committerdate:relative)	%(subject)' \
      | column -t -s$'\t' \
      | fzf --header "$header" --no-mouse --nth=1 --layout=reverse \
          --preview "git log --oneline --graph --color -15 {1}" \
          --preview-window "right,50%" \
      | awk '{print $1}'
  }

  if [[ -z "$base" ]]; then
    base=$(_gdiff_pick_branch "Select BASE ref") || return 0
    [[ -z "$base" ]] && return 0
  fi

  if [[ -z "$target" ]]; then
    target=$(_gdiff_pick_branch "Select TARGET ref (base: $base)") || return 0
    [[ -z "$target" ]] && return 0
  fi

  local range="${base}..${target}"
  local files
  files=$(git diff --name-only "$range" 2>/dev/null)
  if [[ -z "$files" ]]; then
    echo "No changes between $range"
    return 1
  fi

  # Persistent viewed state per repo + range
  local repo_id range_id state_dir viewed_file
  repo_id=$(git rev-parse --show-toplevel 2>/dev/null | md5 -q)
  range_id=$(echo "$range" | md5 -q)
  state_dir="${TMPDIR:-/tmp}/gdiff-state"
  mkdir -p "$state_dir"
  viewed_file="${state_dir}/${repo_id}_${range_id}"
  touch "$viewed_file"

  local files_file="${state_dir}/${repo_id}_${range_id}_files"
  echo "$files" > "$files_file"

  local list_helper="${state_dir}/_list.sh"
  cat > "$list_helper" <<'EOF'
#!/usr/bin/env bash
viewed_file="$1"
files_file="$2"
range="$3"
while IFS= read -r f; do
  stored_hash=$(awk -F'\t' -v file="$f" '$1 == file {print $2; exit}' "$viewed_file" 2>/dev/null)
  if [[ -n "$stored_hash" ]]; then
    current_hash=$(git diff "$range" -- "$f" | md5 -q)
    if [[ "$stored_hash" == "$current_hash" ]]; then
      printf '  ✓  %s\n' "$f"
    else
      printf '  ⚠  %s\n' "$f"
    fi
  else
    printf '  ○  %s\n' "$f"
  fi
done < "$files_file"
EOF
  chmod +x "$list_helper"

  local toggle_helper="${state_dir}/_toggle.sh"
  cat > "$toggle_helper" <<'EOF'
#!/usr/bin/env bash
viewed_file="$1"
file="$2"
range="$3"
stored=$(awk -F'\t' -v f="$file" '$1 == f {print $2; exit}' "$viewed_file" 2>/dev/null)
if [[ -n "$stored" ]]; then
  awk -F'\t' -v f="$file" '$1 != f' "$viewed_file" > "${viewed_file}.tmp" && mv "${viewed_file}.tmp" "$viewed_file"
else
  h=$(git diff "$range" -- "$file" | md5 -q)
  printf '%s\t%s\n' "$file" "$h" >> "$viewed_file"
fi
EOF
  chmod +x "$toggle_helper"

  bash "$list_helper" "$viewed_file" "$files_file" "$range" | fzf \
    --layout=reverse --ansi --nth=2.. \
    --header "[$range] space:viewed  ctrl-x:reset  enter:full diff  ⚠=changed since viewed" \
    --preview "git diff ${range} -- {2..} | delta --width=\${FZF_PREVIEW_COLUMNS:-80}" \
    --preview-window "right,70%" \
    --bind "enter:execute(git diff ${range} -- {2..} | delta --width=\$COLUMNS | less -R +g)" \
    --bind "space:execute-silent(bash '${toggle_helper}' '${viewed_file}' {2..} '${range}')+reload(bash '${list_helper}' '${viewed_file}' '${files_file}' '${range}')" \
    --bind "ctrl-x:execute-silent(: > '${viewed_file}')+reload(bash '${list_helper}' '${viewed_file}' '${files_file}' '${range}')" \
    --bind "ctrl-s:toggle-preview" \
    --no-mouse
}
