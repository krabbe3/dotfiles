# Zsh

Oh-My-Zsh shell config with a custom `lomo` theme and performance-focused plugins.

## Structure

```
zsh/
├── .zshrc                      # Main shell config
├── .stow-local-ignore          # Per-host overrides
├── .oh-my-zsh/                 # Submodule — Oh-My-Zsh framework
└── custom/
    ├── themes/
    │   └── lomo.zsh-theme      # Custom prompt (box-drawn, conda + git aware)
    └── plugins/                # Submodules — fzf, autosuggestions, fast-syntax-highlighting
```

## Key Config

| Setting | Value |
|---------|-------|
| Theme | `lomo` (custom, two-line box prompt with conda env + git branch) |
| Editor | `nvim` |
| Shell | `/bin/zsh` |
| Plugins | git, conda-env, zsh-autosuggestions, fzf-zsh-plugin, fast-syntax-highlighting |
| Autosuggest | History + completion strategy, accept with `C-y` |
| Docker | `DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock` |
| Conda | Miniforge at `~/.miniforge3`, auto-activate `base`, suppress prompt prefix |

## Custom Theme (`lomo`)

Two-line prompt using box-drawing chars:

```
╭─user@host ~/path (branch*) (base)
╰─➤ $
```

- Green user (red for root), green hostname (red over SSH)
- Yellow git branch with `*` dirty indicator
- Green conda env
- Last return code on the right (red on failure)

## Aliases

| Alias | Command |
|-------|---------|
| `kssh` | `kitty +kitten ssh -L 8988:localhost:8988` — Kitty SSH with matplotlib port forward |
| `aivim` | Docker Compose AI sandbox launcher |

## Transcriber Integration

Sources `transcriber/transcribe-notes.zsh` for the `transcribe-notes` shell function.
