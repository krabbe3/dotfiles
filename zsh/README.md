# Zsh

Oh-My-Zsh shell config with a custom `lomo` theme and performance-focused plugins.

## Structure

```
zsh/
├── .zshrc                      # Main shell config
├── .zshrc.local                # Untracked: machine-specific settings (sourced last, optional)
├── .zshrc.local.example        # Template for .zshrc.local
├── .stow-local-ignore          # Keeps custom/ from being stowed
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
| Docker | `DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock`, only if that socket exists |
| X11 | `DISPLAY=:0` on macOS (XQuartz) when not already set |
| Conda | Miniforge at `~/miniforge3`, auto-activate `base`, suppress prompt prefix |

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
| `kssh` | `kitty +kitten ssh -Y` — Kitty SSH with trusted X11 forwarding |
| `lichtblick` | Runs the Lichtblick ROS visualizer in Docker on port 8080 |

## Machine-Specific Settings

`.zshrc` ends with `[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local`. Put settings that
only apply to one machine there, e.g. the HPC ROS tools `PATH`:

```bash
export PATH="/scratch/<user>/<project>/script:$PATH"
```

`setup_local.sh` creates it only where `/scratch/<user>` exists. On a Mac it is not
needed; `touch zsh/.zshrc.local && stow -R -t ~ zsh` silences the setup notice.

## Transcriber Integration

Sources `transcriber/transcribe-notes.zsh` for the `transcribe-notes` shell function.
