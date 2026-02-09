# Keybinding Test Guide

This document helps verify that all keybindings work correctly in the Ghostty → Zellij → OpenCode stack.

## Background

When running OpenCode inside Zellij inside Ghostty, keybindings can be intercepted at multiple layers:

```
┌─────────────────────────────────────┐
│  Ghostty (Terminal Emulator)       │  ← Layer 1: macOS shortcuts
├─────────────────────────────────────┤
│  Zellij (Terminal Multiplexer)     │  ← Layer 2: Modal keybindings
├─────────────────────────────────────┤
│  OpenCode (TUI Application)        │  ← Layer 3: Application shortcuts
└─────────────────────────────────────┘
```

## Fixed Issues

### Issue 1: Command + C doesn't copy
**Root cause**: Ghostty needed explicit clipboard integration settings.

**Solution**: 
- Added `clipboard-read = allow` and `clipboard-write = allow`
- Ensured system clipboard passthrough

### Issue 2: Command + Left/Right scrolls instead of jumping to line start/end
**Root cause**: 
1. Ghostty was sending `\x1bOH` (SS3 format) for Home/End
2. Zellij in scroll mode intercepts bare arrow keys for scrolling
3. The SS3 format wasn't recognized properly

**Solution**: Changed to CSI format (`\x1b[H` for Home, `\x1b[F` for End)

### Issue 3: Alt + F doesn't toggle floating panes
**Root cause**: Ghostty has default bindings for Alt+letter combinations that intercept the keys before passing to Zellij.

**Solution**: Explicitly unbind all Alt combinations used by Zellij.

---

## Test Checklist

After restarting Ghostty, verify these keybindings work:

### ✅ Basic Navigation (OpenCode & Shell)

| Keybinding | Expected Behavior | Layer |
|------------|-------------------|-------|
| `Command + C` | Copy selected text to clipboard | Ghostty |
| `Command + V` | Paste from clipboard | Ghostty |
| `Command + Left` | Jump to start of line | Shell (via Ghostty→Home) |
| `Command + Right` | Jump to end of line | Shell (via Ghostty→End) |
| `Alt + Left` | Jump word backward | Shell |
| `Alt + Right` | Jump word forward | Shell |

### ✅ Zellij Pane Management

| Keybinding | Expected Behavior | Mode |
|------------|-------------------|------|
| `Alt + F` | Toggle floating panes | Normal |
| `Alt + N` | Create new pane | Normal |
| `Alt + W` | Close current pane | Normal |
| `Alt + H` | Move focus left | Normal |
| `Alt + J` | Move focus down | Normal |
| `Alt + K` | Move focus up | Normal |
| `Alt + L` | Move focus right | Normal |

### ✅ Zellij Tab Management

| Keybinding | Expected Behavior | Mode |
|------------|-------------------|------|
| `Alt + I` | Move tab left | Normal |
| `Alt + O` | Move tab right | Normal |
| `Ctrl + T` | Enter tab mode | Normal |

### ✅ Zellij Scroll Mode

| Keybinding | Expected Behavior | Mode |
|------------|-------------------|------|
| `Ctrl + S` | Enter scroll mode | Normal |
| `Up/Down` | Scroll line by line | Scroll |
| `Left/Right` | Page scroll up/down | Scroll |
| `Ctrl + C` | Exit scroll mode | Scroll |

---

## How to Test

### 1. Restart Ghostty
```bash
# Quit Ghostty completely (Command + Q)
# Reopen Ghostty
```

### 2. Start Zellij
```bash
zellij
```

### 3. Test Each Category

**Basic Navigation:**
1. Type some text: `echo "test test test"`
2. Try `Command + Left` - cursor should jump to line start
3. Try `Command + Right` - cursor should jump to line end
4. Try `Alt + Left/Right` - cursor should jump by word
5. Select text and try `Command + C` - should copy to system clipboard

**Pane Management:**
1. Press `Alt + F` - should toggle floating panes overlay
2. Press `Alt + N` - should create new pane
3. Press `Alt + H/J/K/L` - should move focus between panes
4. Press `Alt + W` - should close current pane

**Tab Management:**
1. Press `Ctrl + T` then `n` - create new tab
2. Press `Alt + I` - should move tab left
3. Press `Alt + O` - should move tab right

**Scroll Mode:**
1. Press `Ctrl + S` - enter scroll mode
2. Press `Up/Down` - scroll line by line
3. Press `Left/Right` - should page scroll (NOT move cursor)
4. Press `Ctrl + C` - exit scroll mode

---

## Troubleshooting

### If Command + C still doesn't copy:
1. Check Ghostty config has:
   ```
   clipboard-read = allow
   clipboard-write = allow
   ```
2. Restart Ghostty completely
3. Try in both normal mode and scroll mode

### If Alt + F doesn't work:
1. Verify Ghostty config has: `keybind = alt+f=unbind`
2. Check macOS System Preferences → Keyboard → Shortcuts
3. Ensure no conflicting app-level shortcuts

### If Command + Left/Right doesn't work:
1. Test in a simple shell (outside OpenCode)
2. Run: `cat` then press `Command + Left` - you should see `^[[H` (Home sequence)
3. If you see something else, check Ghostty keybind settings

### If none of the Alt keys work:
1. Check: `macos-option-as-alt = left` is set in Ghostty config
2. Try pressing `Alt + H` in a shell - should show `^[h` (escape sequence)
3. If it shows special characters (˙), the setting isn't applied

---

## Additional Alt Keybindings (Zellij)

If you discover more Alt keybindings not working, add them to Ghostty config:

```
keybind = alt+<key>=unbind
```

Common Zellij Alt bindings from config:
- `Alt + +/-/=`: Resize panes
- `Alt + Shift + P`: Toggle group marking

---

## Reference

- **Ghostty Config**: `~/dotfiles/config/ghostty/config`
- **Zellij Config**: `~/dotfiles/config/zellij/config.kdl`
- **Ghostty Docs**: https://ghostty.org/docs/config/reference
- **Zellij Keybindings**: https://zellij.dev/documentation/keybindings.html
