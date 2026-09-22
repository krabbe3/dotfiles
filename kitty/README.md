# Kitty

Kitty terminal emulator config with Rose Pine theme and Nerd Font support.

## Structure

```
kitty/
└── .config/kitty/
    ├── kitty.conf           # Main config (mostly defaults)
    └── themes/
        └── rose-pine.conf   # Rose Pine color theme
```

## Key Settings

| Setting | Value |
|---------|-------|
| Font | JetBrainsMono Nerd Font Mono (regular, bold, italic, bold-italic) |
| Theme | Rose Pine (loaded from `themes/rose-pine.conf`) |

## Notes

- Config file is the default kitty.conf with only font settings customized at the bottom
- All other settings use kitty defaults (clipboard control, shell integration, etc.)
