#!/usr/bin/env zsh
# ---
# Tool: Zsh Key Bindings
# Source: https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html
# Purpose: Normalize word navigation and deletion key bindings across terminals
# Updated: 2026-02-06
# ---

[[ -o interactive ]] || return 0

for _keymap in emacs viins; do
  bindkey -M "$_keymap" '^A' beginning-of-line
  bindkey -M "$_keymap" '^E' end-of-line
  bindkey -M "$_keymap" '^[[H' beginning-of-line
  bindkey -M "$_keymap" '^[[F' end-of-line
  bindkey -M "$_keymap" '^[OH' beginning-of-line
  bindkey -M "$_keymap" '^[OF' end-of-line
  bindkey -M "$_keymap" '^[[1~' beginning-of-line
  bindkey -M "$_keymap" '^[[4~' end-of-line
  bindkey -M "$_keymap" '\eb' backward-word
  bindkey -M "$_keymap" '\ef' forward-word
  bindkey -M "$_keymap" '^[^?' backward-kill-word
  bindkey -M "$_keymap" '^[[3;3~' backward-kill-word
  bindkey -M "$_keymap" '^[[3;5~' backward-kill-word
  bindkey -M "$_keymap" '^[[3;9~' backward-kill-word
  bindkey -M "$_keymap" '^[[1;3D' backward-word
  bindkey -M "$_keymap" '^[[1;3C' forward-word
  bindkey -M "$_keymap" '^[[1;9D' backward-word
  bindkey -M "$_keymap" '^[[1;9C' forward-word
done
unset _keymap
