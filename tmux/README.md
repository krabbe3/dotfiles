# Tmux

Terminal multiplexer config with Rose Pine theme, vim-style navigation, and mouse support.

## Structure

```
tmux/
├── .tmux.conf              # Main tmux config
├── .stow-local-ignore      # Keeps plugins/ from being stowed
├── .config/
│   └── tmuxinator/
│       └── duncan.yml      # Optional template for 'dune ghola -t duncan'
└── plugins/
    └── tpm/                # Submodule — Tmux Plugin Manager
```

## Prefix

`Ctrl+s` (remapped from default `Ctrl+b`)

## Keybindings

### Pane Navigation

| Key | Action |
|-----|--------|
| `Ctrl+h` | Left pane |
| `Ctrl+l` | Right pane |
| `Ctrl+k` | Up pane |
| `Ctrl+j` | Down pane |

### Pane Splitting

| Key | Action |
|-----|--------|
| `-` | Split vertically (horizontal divider) |
| `\|` | Split horizontally (vertical divider) |

### Pane Resizing

| Key | Action |
|-----|--------|
| `Alt+←` | Resize left 5 cells |
| `Alt+→` | Resize right 5 cells |
| `Alt+↑` | Resize up 2 cells |
| `Alt+↓` | Resize down 2 cells |

### Window Navigation

| Key | Action |
|-----|--------|
| `Ctrl+p` | Previous window |
| `Ctrl+n` | Next window |

### Misc

| Key | Action |
|-----|--------|
| `Prefix + r` | Reload `.tmux.conf` |

## Settings

- Mouse enabled (clickable windows/panes, resizeable)
- Status bar on top, Rose Pine theme (main variant)
- System clipboard sync (`set-clipboard on`)
- Focus events passed to apps (`focus-events on`), so nvim reloads files changed outside it when you switch back to its pane
- No automatic window renaming
- Default shell: `/bin/zsh`

## Project Workspace (`dune ghola`)

`dune ghola` (from [`dune/`](../dune/README.md#workspace-dune-ghola)) opens a tmux session for the
current directory, built with plain tmux:

```
window "agent":  dune mentat (38%) | nvim . (38%) | shell (24%)
window "git":    lazygit
```

- Every pane activates the same Python env (active conda env / venv, or `./.venv`).
- Running it again returns to the session; inside tmux it switches client instead of nesting.
- `dune ghola -k` kills the session; `dune ghola -t duncan` uses the tmuxinator template instead.

tmuxinator is optional: it is only needed for `-t <template>`.

## Plugins

| Plugin | Purpose |
|--------|---------|
| [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [rose-pine/tmux](https://github.com/rose-pine/tmux) | Rose Pine color theme |
| [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless vim ↔ tmux pane navigation |
