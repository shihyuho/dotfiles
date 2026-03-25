#!/usr/bin/env zsh
# ---
# Tool: Yazi
# Source: https://yazi-rs.github.io
# Purpose: Terminal File Manager (Rust-based)
# Updated: 2026-02-06
# Notes: Includes shell wrapper for 'y' (change directory on exit)
# ---

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
