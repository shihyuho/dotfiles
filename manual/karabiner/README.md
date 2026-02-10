# Karabiner-Elements Configuration

This directory contains custom Karabiner-Elements rules for improving keyboard behavior.

## What's Included

### `assets/complex_modifications/prevent_chinese_input.json`

Automatically switches to English input when pressing modifier keys (Ctrl/Option/Command) in Chinese input mode.

**Features:**
- Auto-switches to English when pressing left Control/Option/Command
- Auto-switches back to Chinese when releasing the modifier key
- Only activates when in Traditional Chinese (zh-Hant) input mode

**Solves:** Prevents Unicode characters (e.g., `12561;3u`) from appearing in terminal when using shortcuts like `Option+C` or `Command+V` in Chinese input mode.

## Installation

### 1. Install Karabiner-Elements

```bash
brew install --cask karabiner-elements
```

### 2. Apply Custom Rules

Copy the custom rules to Karabiner's configuration directory:

```bash
cp -r ~/dotfiles/manual/karabiner/assets/complex_modifications/* \
      ~/.config/karabiner/assets/complex_modifications/
```

### 3. Enable Rules

1. Open **Karabiner-Elements** app
2. Go to **Complex Modifications** tab
3. Click **Add rule**
4. Find and enable: **"Auto-switch to English when holding left modifier keys"**

## Updating Rules

When you modify rules in this repository:

```bash
cp ~/dotfiles/manual/karabiner/assets/complex_modifications/prevent_chinese_input.json \
   ~/.config/karabiner/assets/complex_modifications/
```

Then restart Karabiner-Elements or reload the configuration from the app.

## Why Not Symlink?

Karabiner-Elements dynamically manages its configuration files (`karabiner.json`), which can conflict with symlinks. To avoid complications:

- We maintain source files in this repository
- Users manually copy files to `~/.config/karabiner/`
- This approach is more reliable and easier to troubleshoot

## Adding More Rules

1. Create new `.json` files in `assets/complex_modifications/`
2. Follow Karabiner's [rule format](https://karabiner-elements.pqrs.org/docs/json/)
3. Copy to `~/.config/karabiner/assets/complex_modifications/`
4. Enable via Karabiner-Elements app

## References

- [Karabiner-Elements Documentation](https://karabiner-elements.pqrs.org/docs/)
- [Complex Modifications Rules](https://ke-complex-modifications.pqrs.org/)
