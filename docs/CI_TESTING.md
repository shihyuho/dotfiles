# CI/CD Testing Summary

## Overview

This document summarizes the CI/CD testing infrastructure for the dotfiles repository.

## Testing Requirements

All CI workflows in this project MUST:
1. ✅ Test on **both** `macos-latest` and `ubuntu-latest`
2. ✅ Support **manual triggering** via `workflow_dispatch`
3. ✅ Use **matrix strategy** with `fail-fast: false`
4. ✅ Include **platform-specific setup** steps

## Current Workflows

### 1. Verify Dotfiles (`.github/workflows/verify.yml`)

**Purpose**: Validates basic dotfiles installation and shell startup

**Triggers**:
- Push to any branch
- Pull requests
- Manual (workflow_dispatch)

**Tests**:
- Symlink installation (`make install`)
- Shell syntax validation
- Startup speed measurement (CI mode, no threshold)

**Platforms**: macOS, Ubuntu

---

### 2. Test Keybindings (`.github/workflows/test-keybindings.yml`)

**Purpose**: Validates Zellij and Ghostty keybinding configurations

**Triggers**:
- Push when keybinding files change
- Pull requests with keybinding changes
- Manual (workflow_dispatch)

**Tests**:
- Zellij config syntax validation
- Ghostty config syntax validation
- Required settings presence
- Cross-config consistency

**Platforms**: macOS, Ubuntu

**Platform-specific**:
- macOS: Installs Zellij via Homebrew
- Ubuntu: Installs Zellij from GitHub releases

---

## Manual Triggering

### How to Trigger Workflows Manually

1. **Navigate to Actions Tab**
   - Go to: https://github.com/shihyuho/dotfiles/actions

2. **Select Workflow**
   - Click on workflow name from left sidebar:
     - "Verify Dotfiles"
     - "Test Keybindings"

3. **Run Workflow**
   - Click "Run workflow" dropdown button
   - Select branch (usually `main`)
   - Click green "Run workflow" button

4. **Monitor Progress**
   - Workflow run appears at the top of the list
   - Click to see real-time progress
   - Both macOS and Ubuntu jobs run in parallel

---

## Creating New Workflows

When adding a new workflow, use this template:

```yaml
name: Your Workflow Name

on:
  push:
    paths:
      - 'relevant/path/**'
  pull_request:
    paths:
      - 'relevant/path/**'
  workflow_dispatch:  # REQUIRED: Enable manual triggering

jobs:
  your-job:
    strategy:
      fail-fast: false  # REQUIRED: Don't stop on first failure
      matrix:
        os: [macos-latest, ubuntu-latest]  # REQUIRED: Both platforms
    runs-on: ${{ matrix.os }}
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      # REQUIRED: Platform-specific setup
      - name: Setup (macOS)
        if: matrix.os == 'macos-latest'
        run: |
          # macOS-specific commands
          brew install your-tool
      
      - name: Setup (Ubuntu)
        if: matrix.os == 'ubuntu-latest'
        run: |
          # Ubuntu-specific commands
          sudo apt-get update && sudo apt-get install -y your-tool
      
      # Common test steps
      - name: Run Tests
        run: |
          make your-test
```

---

## Test Execution Flow

### Parallel Execution

Both platforms run **simultaneously**:

```
Trigger (push/PR/manual)
    ↓
┌───────────────────┬───────────────────┐
│   macOS-latest    │  ubuntu-latest    │
├───────────────────┼───────────────────┤
│ 1. Checkout       │ 1. Checkout       │
│ 2. macOS Setup    │ 2. Ubuntu Setup   │
│ 3. Run Tests      │ 3. Run Tests      │
│ 4. Report         │ 4. Report         │
└───────────────────┴───────────────────┘
         ↓                  ↓
    Both Complete
         ↓
    Workflow Success/Fail
```

### Exit Codes

- **0**: All tests passed
- **Non-zero**: One or more tests failed

With `fail-fast: false`, both platforms complete even if one fails.

---

## Local Testing

Before pushing, test locally:

```bash
# Test keybindings
make test-keybindings

# Test dotfiles installation
make test-ci

# Full test suite
make test
```

---

## Platform-Specific Notes

### macOS
- Uses Homebrew for package installation
- Native Zsh support
- Faster execution (better GitHub runners)

### Ubuntu
- Uses apt-get for system packages
- Requires explicit Zsh installation
- Some tools installed from releases (e.g., Zellij)

---

## Common Issues

### Issue: Workflow doesn't appear in Actions tab
**Solution**: Ensure workflow file is in `.github/workflows/` and has `.yml` extension

### Issue: Manual trigger button missing
**Solution**: Add `workflow_dispatch:` to the `on:` section

### Issue: Test fails on one platform only
**Solution**: Check platform-specific setup steps and tool availability

### Issue: Workflow times out
**Solution**: Check for infinite loops, reduce test scope, or increase timeout

---

## Monitoring

### GitHub Actions Dashboard
- View all workflow runs: https://github.com/shihyuho/dotfiles/actions
- Filter by workflow, branch, status
- Download logs for debugging

### Notifications
- Email notifications for failures (configurable in GitHub settings)
- Status checks on pull requests
- Commit status badges (optional)

---

## Best Practices

1. **Keep workflows fast** - Aim for < 5 minutes per workflow
2. **Use caching** - Cache dependencies when possible
3. **Clear naming** - Use descriptive step names
4. **Fail early** - Put syntax checks first
5. **Log verbosely** - Echo what's being tested
6. **Test locally** - Always test before pushing

---

## Related Documentation

- [AGENTS.md](../AGENTS.md) - Full agent guide with CI policy
- [test-keybindings.sh](../.agents/scripts/README.md) - Keybinding test implementation
- [verify workflow](../.github/workflows/verify.yml) - Dotfiles verification
- [keybindings workflow](../.github/workflows/test-keybindings.yml) - Keybinding tests
