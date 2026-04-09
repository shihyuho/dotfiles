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
  ctrl-v    Toggle filter: hide/show ✓ files
  enter     Full-screen diff (q to exit)
  ctrl-x    Reset all viewed marks
  ctrl-s    Toggle preview panel
  esc       Back (close help / turn off filter)
  ctrl-c    Quit
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

  # Pre-cache blob SHA pairs once at startup (reused by list + toggle)
  local hash_cache="${state_dir}/${repo_id}_${range_id}_hashes"
  git diff --raw --no-renames "$range" 2>/dev/null \
    | awk -F'\t' '{split($1,a," "); print $2 "\t" a[3] a[4]}' > "$hash_cache"

  # Mark stale viewed entries (hash changed since last viewed)
  if [[ -s "$viewed_file" ]]; then
    awk -F'\t' '
      NR==FNR {current[$1]=$2; next}
      {if ($2 != "" && ($1 in current) && $2 != current[$1]) print $1; else print $0}
    ' "$hash_cache" "$viewed_file" > "${viewed_file}.tmp" && mv "${viewed_file}.tmp" "$viewed_file"
  fi

  # Filter state: exists = hide ✓ files
  local filter_file="${state_dir}/${repo_id}_${range_id}_filter"
  rm -f "$filter_file"
  # Help toggle state
  local help_file="${state_dir}/${repo_id}_${range_id}_help"
  rm -f "$help_file"

  local list_helper="${state_dir}/_list.sh"
  cat > "$list_helper" <<'EOF'
#!/usr/bin/env bash
# No git commands - pure file lookups
viewed_file="$1"
files_file="$2"
filter_file="$3"
gen() {
  if [[ -s "$viewed_file" ]]; then
    awk -F'\t' '
      NR==FNR {
        if (NF >= 2 && $2 != "") viewed[$1]="ok"
        else viewed[$1]="stale"
        next
      }
      {
        f=$0
        if (f in viewed) {
          if (viewed[f]=="ok") printf "  ✓  %s\n", f
          else printf "  ⚠  %s\n", f
        } else printf "  ○  %s\n", f
      }
    ' "$viewed_file" "$files_file"
  else
    awk '{printf "  ○  %s\n", $0}' "$files_file"
  fi
}
if [[ -f "$filter_file" ]]; then
  gen | grep -v '^  ✓  '
else
  gen
fi
EOF
  chmod +x "$list_helper"

  local toggle_helper="${state_dir}/_toggle.sh"
  cat > "$toggle_helper" <<'EOF'
#!/usr/bin/env bash
viewed_file="$1"
file="$2"
hash_cache="$3"
has_entry=$(awk -F'\t' -v f="$file" '$1 == f {print 1; exit}' "$viewed_file" 2>/dev/null)
if [[ -n "$has_entry" ]]; then
  awk -F'\t' -v f="$file" '$1 != f' "$viewed_file" > "${viewed_file}.tmp" && mv "${viewed_file}.tmp" "$viewed_file"
else
  h=$(awk -F'\t' -v f="$file" '$1 == f {print $2; exit}' "$hash_cache")
  printf '%s\t%s\n' "$file" "$h" >> "$viewed_file"
fi
EOF
  chmod +x "$toggle_helper"

  local _hdr_normal="if [[ -f '${filter_file}' ]]; then echo '[$range] ✓ hidden  ?:help'; else echo '[$range] ?:help'; fi"
  local _hdr_help="echo '  space   Toggle viewed mark (✓/○)
  ctrl-v  Hide/show viewed files
  enter   Full-screen diff
  ctrl-x  Reset all viewed marks
  ctrl-s  Toggle preview
  esc     Back (close help / filter)
  ctrl-c  Quit
  ○ Not viewed  ✓ Viewed  ⚠ Changed since viewed'"

  bash "$list_helper" "$viewed_file" "$files_file" "$filter_file" | fzf \
    --layout=reverse --ansi --nth=2.. \
    --header "[$range] ?:help" \
    --preview "git diff ${range} -- {2..} | delta --width=\${FZF_PREVIEW_COLUMNS:-80}" \
    --preview-window "right,70%" \
    --bind "enter:execute(git diff ${range} -- {2..} | delta --width=\$COLUMNS | less -R +g)" \
    --bind "space:execute-silent(bash '${toggle_helper}' '${viewed_file}' {2..} '${hash_cache}')+reload-sync(bash '${list_helper}' '${viewed_file}' '${files_file}' '${filter_file}')+down" \
    --bind "ctrl-v:execute-silent(if [[ -f '${filter_file}' ]]; then rm -f '${filter_file}'; else touch '${filter_file}'; fi)+reload-sync(bash '${list_helper}' '${viewed_file}' '${files_file}' '${filter_file}')+execute-silent(rm -f '${help_file}')+transform-header(${_hdr_normal})" \
    --bind "ctrl-x:execute-silent(: > '${viewed_file}')+reload-sync(bash '${list_helper}' '${viewed_file}' '${files_file}' '${filter_file}')+execute-silent(rm -f '${help_file}')+transform-header(${_hdr_normal})" \
    --bind "?:execute-silent(if [[ -f '${help_file}' ]]; then rm -f '${help_file}'; else touch '${help_file}'; fi)+transform-header(if [[ -f '${help_file}' ]]; then ${_hdr_help}; else ${_hdr_normal}; fi)" \
    --bind "ctrl-s:toggle-preview" \
    --bind "esc:execute-silent(if [[ -f '${help_file}' ]]; then rm -f '${help_file}'; elif [[ -f '${filter_file}' ]]; then rm -f '${filter_file}'; fi)+transform-header(${_hdr_normal})+reload-sync(bash '${list_helper}' '${viewed_file}' '${files_file}' '${filter_file}')" \
    --no-mouse
}
