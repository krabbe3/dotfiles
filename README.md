# 🌵 Dotfiles — Lorenz Mohr

Personal development environment configuration. Managed via [GNU Stow](https://www.gnu.org/software/stow/) for symlink-based deployment.

**Asterianus**.

## Table of Contents

- [Quick Install](#quick-install)
- [Docker Install](#docker-install)
- [Directory Layout](#directory-layout)
- [Tools & Configs](#tools--configs)
- [Submodules](#submodules)
- [Setup Scripts](#setup-scripts)
- [Platform Notes](#platform-notes)
- [Backup Strategy](#backup-strategy)

---

## Quick Install

```bash
# Clone with submodules
git clone --recurse-submodules git@<your-repo>.git ~/dotfiles
cd ~/dotfiles

# Full setup (Linux / TU Ilmenau Makalu cluster)
./setup_full.sh
```

This will:

- Install Neovim `v0.11.5` to `~/.local/bin` (pinned)
- Install lazygit, GNU Stow, tmuxinator (if missing)
- Backup existing dotfiles to `backups/dotfile_bk_<timestamp>/`
- Symlink all config directories into `~` via `stow`
- Set correct permissions on `~/.ssh/config`

### Manual stow (pick your tools)

```bash
cd ~/dotfiles
stow nvim
stow zsh
stow tmux
stow ssh
stow git
stow kitty
stow lazygit
```

---

## Docker Install

For containers (no host installs, no stow dependencies):

```bash
./setup_docker.sh
```

Installs Neovim `v0.11.5` to `/opt` and symlinks `nvim`, `zsh`, `tmux` only.

---

## Directory Layout

```
dotfiles/
├── setup_full.sh              # Full Linux setup (Makalu cluster)
├── setup_docker.sh            # Minimal Docker container setup
├── .env                       # API keys / secrets (gitignored)
├── .gitmodules                # Git submodules (oh-my-zsh, TPM, fzf, etc.)
│
├── nvim/                      # Neovim (Lua, lazy.nvim)
├── zsh/                       # Zsh + Oh My Zsh + custom theme
├── tmux/                      # Tmux + TPM + rose-pine theme
├── kitty/                     # Kitty terminal (Nerd Fonts, rose-pine)
├── git/                       # Git config & hooks
├── lazygit/                   # Lazygit configuration
├── ssh/                       # SSH config (HPC, Makalu, tunnels)
├── scripts/                   # Helper scripts (macOS LaTeX OCR)
│
├── dune/                      # Isolated AI sandbox (Docker + shallow clone)
├── transcriber/               # Supernote → Markdown via Ollama vision
│
└── backups/                   # Timestamped dotfile backups
```

---

## Tools & Configs

| Directory | Tool | Config | Details |
|-----------|------|--------|---------|
| [`nvim/`](nvim/README.md) | Neovim `v0.11.5+` | Lua + lazy.nvim | Blink completion, LSP, DAP, Telescope, Oil, Obsidian, Harpoon, Dap, rose-pine theme |
| [`zsh/`](zsh/README.md) | Zsh | Oh My Zsh + custom theme | fzf, autosuggestions, fast-syntax-highlighting, conda integration, custom `lomo` prompt |
| [`tmux/`](tmux/README.md) | Tmux | `.tmux.conf` + TPM | `Ctrl+Space` prefix, `Ctrl+hjkl` pane nav, rose-pine theme, vim-tmux-navigator |
| [`kitty/`](kitty/README.md) | Kitty | `kitty.conf` | JetBrainsMono Nerd Font Mono, rose-pine color theme |
| [`git/`](git/README.md) | Git | `.gitconfig` | TU Ilmenau GitLab URL rewrite, pull-rebase, custom hooks |
| [`lazygit/`](lazygit/README.md) | Lazygit | `config.yml` | Git TUI companion |
| [`ssh/`](ssh/README.md) | SSH | `config` | HPC cluster, Makalu proxy jump, port forwards, GitHub over 443, LLM tunnel |
| [`dune/`](dune/README.md) | Dune Sandbox | Docker + bash | Isolated dev sandbox with shallow clones, live sync, auto-commit on exit |
| [`transcriber/`](transcriber/README.md) | Supernote Transcriber | Python + Ollama | `.note` → Markdown via `qwen3-vl:8b-instruct` vision model |
| [`scripts/`](scripts/README.md) | Misc Scripts | Bash | macOS LaTeX OCR (pix2tex) |

---

## Submodules

Run `git submodule update --init --recursive` after clone.

| Submodule | Path | Purpose |
|-----------|------|---------|
| [ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) | `zsh/.oh-my-zsh` | Zsh framework |
| [tmux-plugins/tpm](https://github.com/tmux-plugins/tpm) | `tmux/plugins/tpm` | Tmux plugin manager |
| [unixorn/fzf-zsh-plugin](https://github.com/unixorn/fzf-zsh-plugin) | `zsh/custom/plugins/fzf-zsh-plugin` | fzf integration for Zsh |
| [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | `zsh/custom/plugins/zsh-autosuggestions` | Fish-style autosuggest |
| [zdharma-continuum/fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | `zsh/custom/plugins/fast-syntax-highlighting` | Performant syntax highlighting |

---

## Setup Scripts

### `setup_full.sh`

Full workstation setup for Linux (TU Ilmenau Makalu cluster hosts). Handles:

- **Neovim v0.11.5** — downloads pinned release to `~/.local/bin/nvim` (only if current version differs)
- **lazygit v0.53.0** — binary install to `~/.local/bin`
- **GNU Stow** — compiled from source to `~/.local` if missing
- **tmuxinator** — installed via RubyGems to `~/.local/bin`
- **Dune launcher** — links `dune/bin/dune` → `~/.local/bin/dune`
- **Dotfile symlinks** — backs up existing configs, then `stow`s all 9 program directories
- **SSH permissions** — sets `~/.ssh/config` to `600`

### `setup_docker.sh`

Minimal setup for Docker containers. Installs Neovim to `/opt`, symlinks `nvim`, `zsh`, `tmux` only.

---

## Platform Notes

- **Primary platform**: Linux (TU Ilmenau HPC / Makalu compute cluster)
- **Neovim**: Pinned to `v0.11.5` for compatibility (treesitter branch + lspconfig config target this version)
- **macOS scripts**: `scripts/macos/` contains macOS-specific helpers (LaTeX OCR)
- **Conda/Miniforge**: Shell init in `.zshrc` expects `~/.miniforge3`
- **Docker**: Uses user namespace socket (`unix:///run/user/$(id -u)/docker.sock`)

---

## Backup Strategy

Before symlinking, `setup_full.sh` moves existing configs to `backups/dotfile_bk_<YYYYMMDDHHMMSS>/`. This covers:

- `~/.bash_profile`, `~/.bashrc`, `~/.zshrc`, `~/.gitconfig`, `~/.tmux.conf`, `~/.profile`
- Zprezto runcoms (`~/.zprezto/runcoms/z*`)

Rollback by restoring from the timestamped backup directory.
