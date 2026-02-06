# Dotfiles Manager Skill

OpenCode skill for managing modular dotfiles configuration.

## Structure

```
dotfiles-manager/
├── SKILL.md                    # Main entry point (concise, universal)
└── references/
    ├── architecture.md         # Architecture principles
    ├── add-tool.md            # Add tool workflow
    ├── update-aliases.md      # Update aliases workflow
    ├── optimize-startup.md    # Optimize startup speed
    └── cleanup.md             # Cleanup workflow
```

## How It Works

AI agents will:
1. Read `SKILL.md` for overview
2. Read corresponding reference based on task type
3. Execute operations
4. Verify results

## Design Principles

- **Platform-agnostic**: No hardcoded paths, works with any dotfiles repo following this structure
- **Modular**: Main file is concise, detailed workflows are separated
- **On-demand loading**: AI loads only what's needed

## Related Documentation

For project-specific architecture details, refer to `AGENTS.md` in the dotfiles repository.
