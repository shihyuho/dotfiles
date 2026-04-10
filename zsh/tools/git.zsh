#!/usr/bin/env zsh
# ---
# Tool: Git helpers
# Purpose: Interactive git workflows (requires fzf, delta)
# Updated: 2026-04-10
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
  ▾  Directory (expanded, tree mode)
  ▸  Directory (collapsed, tree mode)

Keybindings:
  space     Toggle viewed mark (✓/○), skip on dirs
  left      Collapse directory
  right     Expand directory
  ctrl-a    Toggle all directories (collapse ⇄ expand)
  ctrl-v    Toggle filter: hide/show ✓ files
  ctrl-t    Toggle view: flat / tree
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
  # View mode state: exists = tree, absent = flat (default: tree)
  local view_file="${state_dir}/${repo_id}_${range_id}_view"
  touch "$view_file"
  # Collapsed directories (one path per line, tree mode only)
  local collapsed_file="${state_dir}/${repo_id}_${range_id}_collapsed"
  rm -f "$collapsed_file"
  touch "$collapsed_file"

  local list_helper="${state_dir}/_list.sh"
  cat > "$list_helper" <<'EOF'
#!/usr/bin/env bash
# No git commands - pure file lookups
# Output: "<visual>\t<filepath>\t<dirpath>"
#   file line: filepath set, dirpath empty
#   dir line:  filepath empty, dirpath set (for collapse targeting)
viewed_file="$1"
files_file="$2"
filter_file="$3"
view_file="$4"
collapsed_file="$5"

# Apply filter (hide ✓ files) before rendering so tree stays clean
get_files() {
  if [[ -f "$filter_file" && -s "$viewed_file" ]]; then
    awk -v vf="$viewed_file" '
      BEGIN {
        while ((getline line < vf) > 0) {
          n = split(line, f, "\t")
          if (n >= 2 && f[2] != "") ok[f[1]] = 1
        }
        close(vf)
      }
      { if (!($0 in ok)) print }
    ' "$files_file"
  else
    cat "$files_file"
  fi
}

render() {
  local mode="$1"
  local sorter="cat"
  [[ "$mode" == "tree" ]] && sorter="sort"
  get_files | $sorter | awk -v mode="$mode" -v vf="$viewed_file" -v cf="$collapsed_file" '
    BEGIN {
      while ((getline line < vf) > 0) {
        n = split(line, f, "\t")
        if (n >= 2 && f[2] != "") viewed[f[1]] = "ok"
        else viewed[f[1]] = "stale"
      }
      close(vf)
      if (cf != "") {
        while ((getline line < cf) > 0) {
          if (line != "") collapsed[line] = 1
        }
        close(cf)
      }
    }
    function status(full) {
      if (full in viewed) {
        if (viewed[full] == "ok") return "✓"
        return "⚠"
      }
      return "○"
    }
    function join_parts(arr, upto,    i, s) {
      s = arr[1]
      for (i = 2; i <= upto; i++) s = s "/" arr[i]
      return s
    }
    function ind(depth,    i, s) {
      s = ""
      for (i = 1; i < depth; i++) s = s "  "
      return s
    }
    NF == 0 { next }
    {
      full = $0
      st = status(full)
      if (mode == "flat") {
        # 3-field format: visual, filepath, (empty dirpath)
        printf "  %s  %s\t%s\t\n", st, full, full
        next
      }

      # --- tree mode ---
      n = split(full, parts, "/")

      # Find topmost collapsed ancestor (if any)
      top_depth = 0
      top_path = ""
      accum = ""
      for (i = 1; i < n; i++) {
        accum = (i == 1) ? parts[1] : accum "/" parts[i]
        if (accum in collapsed) {
          top_depth = i
          top_path = accum
          break
        }
      }

      if (top_depth > 0) {
        # File is hidden inside a collapsed ancestor
        if (top_path in emitted_coll) next
        emitted_coll[top_path] = 1

        # Emit intermediate expanded dirs from (m+1) to (top_depth-1)
        m = 0
        for (i = 1; i < top_depth && i <= prev_n - 1; i++) {
          if (parts[i] != prev[i]) break
          m++
        }
        for (i = m + 1; i < top_depth; i++) {
          printf "  ▾  %s%s/\t\t%s\n", ind(i), parts[i], join_parts(parts, i)
        }
        # Emit the collapsed dir itself
        printf "  ▸  %s%s/\t\t%s\n", ind(top_depth), parts[top_depth], top_path

        delete prev
        for (i = 1; i <= top_depth; i++) prev[i] = parts[i]
        prev_n = top_depth
        next
      }

      # Normal file rendering: emit new expanded dir headers + the file
      m = 0
      for (i = 1; i < n && i <= prev_n - 1; i++) {
        if (parts[i] != prev[i]) break
        m++
      }
      for (i = m + 1; i < n; i++) {
        printf "  ▾  %s%s/\t\t%s\n", ind(i), parts[i], join_parts(parts, i)
      }
      printf "  %s  %s%s\t%s\t\n", st, ind(n), parts[n], full
      delete prev
      for (i = 1; i <= n; i++) prev[i] = parts[i]
      prev_n = n
    }
  '
}

if [[ -f "$view_file" ]]; then
  render tree
else
  render flat
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

  local collapse_helper="${state_dir}/_collapse.sh"
  cat > "$collapse_helper" <<'EOF'
#!/usr/bin/env bash
# Usage: _collapse.sh <collapsed_file> <dir> [add|remove]
collapsed_file="$1"
dir="$2"
mode="${3:-add}"
[[ -z "$dir" ]] && exit 0
touch "$collapsed_file"
case "$mode" in
  add)
    grep -Fxq -- "$dir" "$collapsed_file" || printf '%s\n' "$dir" >> "$collapsed_file"
    ;;
  remove)
    if grep -Fxq -- "$dir" "$collapsed_file"; then
      grep -Fxv -- "$dir" "$collapsed_file" > "${collapsed_file}.tmp" && mv "${collapsed_file}.tmp" "$collapsed_file"
    fi
    ;;
esac
EOF
  chmod +x "$collapse_helper"

  # Write every ancestor directory of every file into collapsed_file
  local bulk_collapse_helper="${state_dir}/_collapse_all.sh"
  cat > "$bulk_collapse_helper" <<'EOF'
#!/usr/bin/env bash
files_file="$1"
collapsed_file="$2"
awk -F/ 'NF > 1 {
  p = $1
  for (i = 1; i < NF; i++) {
    if (i > 1) p = p "/" $i
    print p
  }
}' "$files_file" | sort -u > "$collapsed_file"
EOF
  chmod +x "$bulk_collapse_helper"

  # Subtree preview: render files under <dir>/ as an indented tree with header
  local preview_helper="${state_dir}/_preview.sh"
  cat > "$preview_helper" <<'EOF'
#!/usr/bin/env bash
files_file="$1"
dir="$2"
[[ -z "$dir" ]] && exit 0

prefix="${dir}/"
filtered=$(awk -v p="$prefix" 'index($0, p) == 1' "$files_file" | sort)

if [[ -z "$filtered" ]]; then
  printf '%s/\n\n(no files under this directory)\n' "$dir"
  exit 0
fi

file_count=$(printf '%s\n' "$filtered" | wc -l | tr -d ' ')
max_depth=$(printf '%s\n' "$filtered" | awk -v pl=${#prefix} '
  {
    rel = substr($0, pl + 1)
    n = split(rel, a, "/")
    if (n > max) max = n
  }
  END { print max + 0 }
')

files_word="files"; [[ "$file_count" -eq 1 ]] && files_word="file"
levels_word="levels"; [[ "$max_depth" -eq 1 ]] && levels_word="level"
printf '%s/  —  %d %s, %d %s deep\n\n' \
  "$dir" "$file_count" "$files_word" "$max_depth" "$levels_word"

printf '%s\n' "$filtered" | awk -v pl=${#prefix} '
  {
    rel = substr($0, pl + 1)
    n = split(rel, parts, "/")
    m = 0
    for (i = 1; i < n && i <= prev_n - 1; i++) {
      if (parts[i] != prev[i]) break
      m++
    }
    for (i = m + 1; i < n; i++) {
      ind = ""
      for (j = 1; j < i; j++) ind = ind "  "
      printf "%s%s/\n", ind, parts[i]
    }
    ind = ""
    for (j = 1; j < n; j++) ind = ind "  "
    printf "%s%s\n", ind, parts[n]
    delete prev
    for (i = 1; i <= n; i++) prev[i] = parts[i]
    prev_n = n
  }
'
EOF
  chmod +x "$preview_helper"

  local hdr_helper="${state_dir}/_hdr.sh"
  cat > "$hdr_helper" <<'EOF'
#!/usr/bin/env bash
# Args: <range> <view_file> <filter_file> <help_file> [mode]
# mode: auto (default) | normal | help
range="$1"
view_file="$2"
filter_file="$3"
help_file="$4"
mode="${5:-auto}"
if [[ "$mode" == "auto" ]]; then
  [[ -f "$help_file" ]] && mode="help" || mode="normal"
fi
if [[ "$mode" == "help" ]]; then
  cat <<'HLP'
  space   Toggle viewed (✓/○), skip on dirs
  ←/→    Collapse / expand directory
  ctrl-a  Toggle all (collapse ⇄ expand)
  ctrl-v  Hide/show viewed files
  ctrl-t  Toggle tree/flat view
  enter   Full-screen diff
  ctrl-x  Reset all viewed marks
  ctrl-s  Toggle preview
  esc     Back (close help / filter)
  ctrl-c  Quit
  ○ Not viewed  ✓ Viewed  ⚠ Changed since viewed
  ▾ Expanded dir  ▸ Collapsed dir
HLP
  exit 0
fi
parts="[$range]"
[[ -f "$view_file" ]] && parts="$parts tree"
[[ -f "$filter_file" ]] && parts="$parts ✓ hidden"
echo "$parts  ?:help"
EOF
  chmod +x "$hdr_helper"

  local _list_cmd="bash '${list_helper}' '${viewed_file}' '${files_file}' '${filter_file}' '${view_file}' '${collapsed_file}'"
  local _hdr_cmd="bash '${hdr_helper}' '${range}' '${view_file}' '${filter_file}' '${help_file}'"

  bash "$list_helper" "$viewed_file" "$files_file" "$filter_file" "$view_file" "$collapsed_file" | fzf \
    --layout=reverse --ansi --track \
    --delimiter=$'\t' --with-nth=1 \
    --header "$(bash "$hdr_helper" "$range" "$view_file" "$filter_file" "$help_file" normal)" \
    --preview "if [[ -n {2} ]]; then git diff ${range} -- {2} | delta --width=\${FZF_PREVIEW_COLUMNS:-80}; elif [[ -n {3} ]]; then bash '${preview_helper}' '${files_file}' {3}; else echo '(directory)'; fi" \
    --preview-window "right,70%" \
    --bind "enter:execute([[ -n {2} ]] && git diff ${range} -- {2} | delta --width=\$COLUMNS | less -R +g)" \
    --bind "space:execute-silent([[ -n {2} ]] && bash '${toggle_helper}' '${viewed_file}' {2} '${hash_cache}')+reload-sync(${_list_cmd})+down" \
    --bind "left:execute-silent([[ -n {3} ]] && bash '${collapse_helper}' '${collapsed_file}' {3} add)+reload-sync(${_list_cmd})" \
    --bind "right:execute-silent([[ -n {3} ]] && bash '${collapse_helper}' '${collapsed_file}' {3} remove)+reload-sync(${_list_cmd})" \
    --bind "ctrl-a:execute-silent(if [[ -s '${collapsed_file}' ]]; then : > '${collapsed_file}'; else bash '${bulk_collapse_helper}' '${files_file}' '${collapsed_file}'; fi)+reload-sync(${_list_cmd})" \
    --bind "ctrl-v:execute-silent(if [[ -f '${filter_file}' ]]; then rm -f '${filter_file}'; else touch '${filter_file}'; fi)+reload-sync(${_list_cmd})+execute-silent(rm -f '${help_file}')+transform-header(${_hdr_cmd} normal)" \
    --bind "ctrl-t:execute-silent(if [[ -f '${view_file}' ]]; then rm -f '${view_file}'; else touch '${view_file}'; fi)+reload-sync(${_list_cmd})+execute-silent(rm -f '${help_file}')+transform-header(${_hdr_cmd} normal)" \
    --bind "ctrl-x:execute-silent(: > '${viewed_file}')+reload-sync(${_list_cmd})+execute-silent(rm -f '${help_file}')+transform-header(${_hdr_cmd} normal)" \
    --bind "?:execute-silent(if [[ -f '${help_file}' ]]; then rm -f '${help_file}'; else touch '${help_file}'; fi)+transform-header(${_hdr_cmd} auto)" \
    --bind "ctrl-s:toggle-preview" \
    --bind "esc:execute-silent(if [[ -f '${help_file}' ]]; then rm -f '${help_file}'; elif [[ -f '${filter_file}' ]]; then rm -f '${filter_file}'; fi)+transform-header(${_hdr_cmd} normal)+reload-sync(${_list_cmd})" \
    --no-mouse
}
