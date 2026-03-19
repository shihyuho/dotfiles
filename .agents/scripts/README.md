# Keybinding Testing

This directory contains automated tests for Ghostty keybinding configuration.

## What Gets Tested

### Ghostty Configuration
- ✅ Configuration file exists and is readable
- ✅ `macos-option-as-alt` is set to `left`
- ✅ `cmd+c` and `cmd+v` clipboard bindings exist
- ✅ Command+Left/Right mappings exist
- ✅ Clipboard integration is enabled
- ✅ Split keybindings exist

## Running Tests

### Locally

```bash
# Run all keybinding tests
make test-keybindings

# Or run specific test categories
.agents/scripts/test-keybindings.sh ghostty     # Ghostty only
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

=== Testing Ghostty Configuration ===

✓ Ghostty config file exists
✓ Ghostty: macos-option-as-alt is set to 'left'
...

=== Test Summary ===

Total Tests: 6
Passed: 6
All tests passed!
```

## Adding New Tests

To add a new test:

1. Open `.agents/scripts/test-keybindings.sh`
2. Add test logic to the appropriate function:
   - `test_ghostty_config()` - Ghostty-specific tests
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
│   └── ghostty/config               # Ghostty keybindings
└── docs/
    ├── KEYBINDING_TEST.md           # Manual test guide
    └── KEYBINDING_DIAGNOSIS.md      # Troubleshooting guide
```

## CI Requirements

The GitHub workflow requires:
- **OS**: `macos-latest` and `ubuntu-latest`
- **Tools**: shell utilities available in GitHub-hosted runners
- **Runtime**: ~20 seconds

## Troubleshooting

### Test fails locally but passes in CI
- Check if you have local modifications to config files
- Ensure configs are symlinked correctly: `make install`

### Test fails in CI but passes locally
- Check if CI has latest config changes committed
- Verify workflow file is up to date

### Adding a new keybinding breaks tests
1. Add the keybinding to appropriate config
2. Run `make test-keybindings` to verify
3. Update test expectations if needed

## Related Documentation

- [AGENTS.md](../AGENTS.md) - Agent guide for maintaining this project
- [KEYBINDING_TEST.md](docs/KEYBINDING_TEST.md) - Manual testing checklist
- [KEYBINDING_DIAGNOSIS.md](docs/KEYBINDING_DIAGNOSIS.md) - Troubleshooting guide
