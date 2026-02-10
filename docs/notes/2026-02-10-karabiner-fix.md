# Fix macOS Chinese Input Modifier Keys with Karabiner

**Date**: 2026-02-10  
**Tags**: #macos #karabiner #dotfiles #debugging

## Context
When using Traditional Chinese (Zhuyin) input method on macOS, pressing modifier keys like `Option` + `Key` (e.g., `Option+C`) often results in garbled output or Unicode characters (e.g., `12561;3u`) instead of the expected modifier command. This happens because the Input Method intercepts the keystroke before it reaches the terminal/application.

## Solution
Use **Karabiner-Elements** to force a temporary switch to English input mode whenever a modifier key is held down.

### Key Implementation Details

1. **Rule Logic**: 
   - Trigger: Left Control / Option / Command pressed.
   - Action: Switch input source to English (`com.apple.keylayout.ABC`).
   - Release: Switch input source back to Zhuyin (`com.apple.inputmethod.TCIM.Zhuyin`).

2. **Critical Config**:
   The simple `language: "zh-Hant"` condition proved insufficient. We successfully used specific `input_mode_id` and `input_source_id`:
   - Target (English): `com.apple.keylayout.ABC`
   - Source (Zhuyin): `com.apple.inputmethod.TCIM.Zhuyin`

### Repository Management
We adopted a **Manual Installation Strategy** for this configuration:
- **Location**: `manual/karabiner/`
- **Reason**: Karabiner manages its config dynamically, making symlinks unstable/risky.
- **Workflow**: User manually copies the JSON rule file to `~/.config/karabiner/assets/complex_modifications/`.

## Reference
- **Rule File**: [`manual/karabiner/assets/complex_modifications/prevent_chinese_input.json`](../../manual/karabiner/assets/complex_modifications/prevent_chinese_input.json)
- **Docs**: [`manual/karabiner/README.md`](../../manual/karabiner/README.md)
