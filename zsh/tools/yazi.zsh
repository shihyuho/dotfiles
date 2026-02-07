#!/usr/bin/env zsh
# ---
# Tool: Yazi
# Source: https://yazi-rs.github.io
# Purpose: Terminal File Manager (Rust-based)
# Updated: 2026-02-06
# Notes: Includes shell wrapper for 'yy' (change directory on exit)
# ---

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
