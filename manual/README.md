# Manual Installation Configs

This directory contains configurations that require **manual installation** and are not automatically symlinked by `install.sh`.

These are typically:
- System-level tools with strict file management (e.g., Karabiner-Elements)
- GUI application preferences that don't support symlinks well
- Configurations that need OS-specific setup

## Structure

Each subdirectory contains:
- Configuration files (source of truth)
- `README.md` with installation instructions

## Available Configs

### `karabiner/`
Karabiner-Elements custom rules for keyboard behavior.

**See:** [`karabiner/README.md`](karabiner/README.md)

## Adding New Manual Configs

1. Create a new subdirectory under `manual/`
2. Add your configuration files
3. Create a `README.md` explaining:
   - What the config does
   - How to install it manually
   - How to update it when changed

**Example structure:**
```
manual/
└── your-tool/
    ├── README.md
    └── config-files...
```
