#!/usr/bin/env zsh
# ---
# Tool: Ghostty
# Source: https://ghostty.org/docs/features/applescript
# Purpose: Ghostty pane workflow helpers for OpenCode
# Updated: 2026-03-18
# ---

_ghostty_require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    print -u2 -- "ghostty workflow error: missing command '$cmd'"
    return 1
  }
}

_ghostty_quote_for_shell() {
  printf '%q' "$1"
}

_ghostty_run_oc_workflow() {
  local left_cmd="$1" left_line right_line quoted_cwd err_msg

  [[ "$TERM_PROGRAM" != "Ghostty" ]] && {
    print -u2 -- "ghostty workflow error: not running in Ghostty"
    return 1
  }

  _ghostty_require_command osascript || return 1
  _ghostty_require_command opencode || return 1
  _ghostty_require_command ocmonitor || return 1
  _ghostty_require_command ghostty || return 1

  quoted_cwd="$(_ghostty_quote_for_shell "$PWD")"
  left_line="cd -- ${quoted_cwd} && ${left_cmd}"$'\n'
  right_line="cd -- ${quoted_cwd} && ocmonitor live --pick"$'\n'

  if ! err_msg="$(osascript - "$left_line" "$right_line" <<'APPLESCRIPT'
on run argv
    set leftLine to item 1 of argv
    set rightLine to item 2 of argv

    tell application "Ghostty"
        if not (running) then error "Ghostty is not running"
        if (count of windows) is 0 then error "Ghostty has no open windows"

        set frontWin to front window
        set selectedTab to selected tab of frontWin
        if selectedTab is missing value then error "No selected tab"
        set originalTerm to focused terminal of selectedTab
        if originalTerm is missing value then error "No focused terminal"

        set rightTerm to split originalTerm direction right

        input text leftLine to originalTerm
        input text rightLine to rightTerm
        focus originalTerm
    end tell
end run
APPLESCRIPT
  2>&1)"; then
    print -u2 -- "ghostty workflow error: $err_msg"
    return 1
  fi
}

ocm() {
  _ghostty_run_oc_workflow "opencode --continue"
}

om() {
  _ghostty_run_oc_workflow "opencode"
}
