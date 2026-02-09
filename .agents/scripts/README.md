# Keybinding Testing

This directory contains automated tests for keybinding configurations in Ghostty and Zellij.

## What Gets Tested

### Zellij Configuration
- ✅ Configuration syntax is valid
- ✅ Required settings exist at top level (`theme`, `default_layout`, `mouse_mode`, `copy_command`)
- ✅ Theme is set to `catppuccin-macchiato`
- ✅ Default layout is `compact`
- ✅ Alt+F binding exists for `ToggleFloatingPanes`
- ✅ Alt Left/Right are unbound (for shell word jumping)
- ✅ Critical Alt bindings exist (h, j, k, l, n, w, etc.)
- ✅ UI block structure is correct
- ✅ No top-level settings incorrectly placed in UI block
- ✅ Copy command is set to `pbcopy`

### Ghostty Configuration
- ✅ Configuration file exists and is readable
- ✅ `macos-option-as-alt` is set to `left`
- ✅ All required Alt keys are unbound (f, h, j, k, l, n, w, i, o, p)
- ✅ Command+Left/Right mappings exist
- ✅ Clipboard integration is enabled
- ✅ Alt+Left/Right are unbound (for shell word jumping)

### Cross-Configuration Consistency
- ✅ Ghostty unbinds all Alt keys that Zellij binds
- ✅ Both configs use `pbcopy` for clipboard operations

## Running Tests

### Locally

```bash
# Run all keybinding tests
make test-keybindings

# Or run specific test categories
.agents/scripts/test-keybindings.sh zellij      # Zellij only
.agents/scripts/test-keybindings.sh ghostty     # Ghostty only
.agents/scripts/test-keybindings.sh consistency # Consistency only
```

### In CI

Tests run automatically on:
- Push to `main` when keybinding configs change
- Pull requests that modify keybinding configs

See `.github/workflows/test-keybindings.yml` for workflow configuration.

## Test Output

```
╔════════════════════════════════════════╗
║  Keybinding Configuration Test Suite  ║
╚════════════════════════════════════════╝

=== Testing Zellij Configuration ===

✓ Zellij config file exists
✓ Zellij: 'theme' is defined at top level
✓ Zellij: 'default_layout' is defined at top level
...

=== Test Summary ===

Total Tests: 21
Passed: 21
All tests passed!
```

## Adding New Tests

To add a new test:

1. Open `.agents/scripts/test-keybindings.sh`
2. Add test logic to the appropriate function:
   - `test_zellij_config()` - Zellij-specific tests
   - `test_ghostty_config()` - Ghostty-specific tests
   - `test_consistency()` - Cross-config consistency tests
3. Use `test_result "Test name" $result "Optional message"` to report results
4. Run locally to verify: `make test-keybindings`

Example:
```bash
# Test that a specific setting exists
if grep -q "^setting_name value" "$CONFIG_FILE"; then
    test_result "Setting exists" 0
else
    test_result "Setting exists" 1 "Setting not found"
fi
```

## What This DOESN'T Test

These tests verify **configuration correctness**, not runtime behavior:

❌ **NOT tested** (requires GUI/user interaction):
- Actual key presses triggering actions
- Visual feedback from keybindings
- macOS system-level key interception
- Application-specific keybinding conflicts

For runtime testing, use the manual guides:
- `docs/KEYBINDING_TEST.md` - Manual testing checklist
- `docs/KEYBINDING_DIAGNOSIS.md` - Troubleshooting guide

## File Locations

```
dotfiles/
├── .agents/scripts/
│   └── test-keybindings.sh          # Test implementation
├── .github/workflows/
│   └── test-keybindings.yml         # CI workflow
├── config/
│   ├── ghostty/config               # Ghostty keybindings
│   └── zellij/config.kdl            # Zellij keybindings
└── docs/
    ├── KEYBINDING_TEST.md           # Manual test guide
    └── KEYBINDING_DIAGNOSIS.md      # Troubleshooting guide
```

## CI Requirements

The GitHub workflow requires:
- **OS**: `macos-latest` (for Zellij via Homebrew)
- **Tools**: Zellij (installed via `brew install zellij`)
- **Runtime**: ~30 seconds

## Troubleshooting

### Test fails locally but passes in CI
- Check if you have local modifications to config files
- Ensure configs are symlinked correctly: `make install`

### Test fails in CI but passes locally
- Check if CI has latest config changes committed
- Verify workflow file is up to date

### Adding a new keybinding breaks tests
1. Add the keybinding to appropriate config
2. If it's an Alt key in Zellij, add `unbind` to Ghostty config
3. Run `make test-keybindings` to verify
4. Update test expectations if needed

## Related Documentation

- [AGENTS.md](../AGENTS.md) - Agent guide for maintaining this project
- [KEYBINDING_TEST.md](docs/KEYBINDING_TEST.md) - Manual testing checklist
- [KEYBINDING_DIAGNOSIS.md](docs/KEYBINDING_DIAGNOSIS.md) - Troubleshooting guide
