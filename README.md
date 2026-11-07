# Dotfiles — Lorenz Mohr

Personal development environment configuration. Managed via [GNU Stow](https://www.gnu.org/software/stow/) for symlink-based deployment.

## Table of Contents

- [Quick Install](#quick-install)
- [Private Config](#private-config)
- [Make Targets](#make-targets)
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
# Clone (submodules are also fetched by the setup script)
git clone --recurse-submodules git@<your-repo>.git ~/dotfiles
cd ~/dotfiles

# Optional: copy your private setup_local.sh into the repo root (see Private Config)
scp <other-machine>:dotfiles/setup_local.sh .

# Full setup (Linux or macOS)
./setup_full.sh
```

Or using Make:

```bash
make install
```

This will:

- Run from wherever the repo lives (it does not have to be `~/dotfiles`, but `.zshrc` and `.tmux.conf` expect it there)
- Fetch the git submodules (oh-my-zsh, tpm, zsh plugins)
- Auto-detect platform (Linux or macOS) and CPU (x86_64 or arm64)
- On Linux: Install Neovim `v0.11.5`, lazygit, GNU Stow, tmuxinator (optional, if Ruby `gem` exists) to `~/.local/bin`
- On macOS: Install Homebrew (if missing), then install tools via `brew`
- Move every file that would block a symlink to `backups/dotfile_bk_<timestamp>/`
- Symlink all config directories into `~` via `stow` (`ssh` with `--no-folding`, so `~/.ssh` stays a real dir)
- Set permissions on `~/.ssh` (`700`) and its config files (`600`)
- Run `setup_local.sh` if present, and list any `*.local` files that are still missing
- Validate setup (check tools + symlinks)

It is safe to run again: files already linked are skipped and nothing is reinstalled.

### Manual stow (pick your tools)

```bash
cd ~/dotfiles
stow nvim
stow zsh
stow tmux
stow --no-folding ssh   # keeps ~/.ssh a real directory
stow git
stow kitty
stow lazygit
```

---

## Private Config

This repo is public, so personal details are kept out of tracked files. Each tool
loads an untracked `*.local` file (gitignored) next to its tracked config, with a
tracked `.example` template beside it:

| File | Holds | Loaded by |
|------|-------|-----------|
| `ssh/.ssh/config.local` | HPC/compute hosts, usernames, port forwards | `Include ~/.ssh/config.local` |
| `git/.config/git/config.local` | `[user]` name/email, GitLab URL rewrite | `[include] path = ~/.config/git/config.local` |
| `zsh/.zshrc.local` | Machine-specific shell settings (e.g. HPC `PATH`) | sourced at the end of `.zshrc` |

All three are optional: a missing file is simply skipped.

**`setup_local.sh`** (repo root, gitignored, copied between machines by hand) writes
these files with your real values and links them. `setup_full.sh` runs it
automatically when present. It never overwrites an existing `*.local` file, so to
change a setting, edit the `*.local` file directly.

Without `setup_local.sh`, copy each `.example` to `.local`, fill it in, and run
`stow -R` for that package (`stow --no-folding -R ssh` for ssh).

Run it once per home directory (HPC login and compute nodes usually share one). On a
Mac without `/scratch`, the `missing zsh/.zshrc.local` notice is expected and harmless.

---

## Make Targets

| Target | Description |
|--------|-------------|
| `make install` | Run full setup (`setup_full.sh`) |
| `make docker` | Run minimal Docker setup (`setup_docker.sh`) |
| `make validate` | Check which dotfiles are symlinked |
| `make test` | Run shellcheck on setup scripts |
| `make clean` | Remove all dotfile symlinks (`stow -D`) |

---

## Docker Install

For containers (no host installs, no stow dependencies):

```bash
./setup_docker.sh
```

Or: `make docker`

Installs Neovim `v0.11.5` to `/opt` and symlinks `nvim`, `zsh`, `tmux` only.

---

## Directory Layout

```
dotfiles/
├── Makefile                   # Common setup tasks
├── setup_full.sh              # Full setup (Linux & macOS)
├── setup_docker.sh            # Minimal Docker container setup
├── setup_local.sh             # Private hosts/identity -> *.local files (gitignored)
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
├── dune/                      # AI agent sandbox (Docker; live or isolated mode)
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
| [`tmux/`](tmux/README.md) | Tmux | `.tmux.conf` + TPM | `Ctrl+s` prefix, `Ctrl+hjkl` pane nav, rose-pine theme, vim-tmux-navigator |
| [`kitty/`](kitty/README.md) | Kitty | `kitty.conf` | JetBrainsMono Nerd Font Mono, rose-pine color theme |
| [`git/`](git/README.md) | Git | `.config/git/config` | Pull-rebase, custom hooks; identity + GitLab URL rewrite in `config.local` |
| [`lazygit/`](lazygit/README.md) | Lazygit | `config.yml` | Git TUI companion |
| [`ssh/`](ssh/README.md) | SSH | `config` | GitHub over 443; private hosts (HPC, proxy jump, port forwards, LLM tunnel) in `config.local` |
| [`dune/`](dune/README.md) | Dune Sandbox | Docker + bash | Agent edits your files live while `.git` stays read-only, host-side snapshots (`dune diff` / `dune undo`), same Python env as the host, optional isolated clone mode, tmux workspace (`dune ghola`) |
| [`transcriber/`](transcriber/README.md) | Supernote Transcriber | Python + Ollama | `.note` → Markdown via `qwen3-vl:8b-instruct` vision model |
| [`scripts/`](scripts/README.md) | Misc Scripts | Bash | macOS LaTeX OCR (pix2tex) |

---

## Submodules

`setup_full.sh` runs `git submodule update --init --recursive` for you. Run it by hand if you only stow.

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

Full workstation setup for Linux and macOS. Handles:

- **Location independent** — `cd`s to its own directory, wherever the repo was cloned
- **Submodules** — `git submodule update --init --recursive`
- **Platform detection** — automatically selects Linux or macOS setup path
- **Linux**: Installs Neovim `v0.11.5`, lazygit `v0.53.0`, GNU Stow, tmuxinator (only if `gem` exists; needed just for `dune ghola -t`) to `~/.local`; picks x86_64 or arm64 downloads by `uname -m`
- **macOS**: Installs Homebrew (if missing), then `brew install neovim stow lazygit tmux tmuxinator`
- **Version pinning** — `NVIM_TARGET` and `LAZYGIT_TARGET` variables, `brew pin neovim` on macOS
- **Retry logic** — all curl downloads retry up to 3 times on failure
- **Dune launcher** — links `dune/bin/dune` → `~/.local/bin/dune`
- **Dotfile symlinks** — backs up anything in the way (see [Backup Strategy](#backup-strategy)), then `stow`s the 7 program directories (`nvim zsh ssh git kitty tmux lazygit`); `ssh` uses `--no-folding`
- **SSH permissions** — `~/.ssh` to `700`, `config` and `config.local` to `600`
- **Private config** — runs `setup_local.sh` if present, then lists missing `*.local` files
- **Validation** — verifies tools are installed and symlinks are correct
- **Re-runnable** — already-linked files are skipped, installed tools are not reinstalled

### `setup_docker.sh`

Minimal setup for Docker containers. Installs Neovim to `/opt`, symlinks `nvim`, `zsh`, `tmux` only. Uses `make docker` in `dune/sandboxes/mentat/Dockerfile.mentat`.

---

## Platform Notes

- **Supported platforms**: Linux (any distro, x86_64 & arm64), macOS (Intel & Apple Silicon)
- **Repo location**: the setup script works from anywhere, but `.zshrc` and `.tmux.conf` expect `~/dotfiles`
- **Neovim**: Pinned to `v0.11.5` for compatibility (treesitter branch + lspconfig config target this version)
- **macOS**: Uses Homebrew for package management; installs automatically if not present. `DISPLAY=:0` (XQuartz) is set only on macOS
- **Conda/Miniforge**: Shell init in `.zshrc` expects `~/miniforge3`
- **Docker**: `DOCKER_HOST` points at the rootless socket (`/run/user/$(id -u)/docker.sock`) only where that socket exists
- **SSH on Linux**: `IgnoreUnknown UseKeychain` keeps the macOS-only option from breaking the config
- **Per-machine differences** go in `*.local` files (see [Private Config](#private-config)), not in tracked files

---

## Backup Strategy

Before symlinking, `setup_full.sh` moves everything stow would collide with to `backups/dotfile_bk_<YYYYMMDDHHMMSS>/`, keeping the path relative to `~`. This covers:

- Any existing file a package would link: `~/.zshrc`, `~/.tmux.conf`, and also files inside existing dirs such as `~/.config/nvim/init.lua`
- `~/.gitconfig` (always, since it would override `~/.config/git/config`)
- Zprezto runcoms (`~/.zprezto/runcoms/z*`)

`~/.bashrc`, `~/.profile` and `~/.bash_profile` are left alone. Files already linked to this repo are skipped, so a re-run creates no new backup. See [`backups/README.md`](backups/README.md) for rollback.
