# Backups

Automated backup directory created by `setup_full.sh`.

## Behavior

Before stowing, `setup_full.sh` moves every file in `$HOME` that stow would collide
with into a timestamped folder, keeping its path relative to `$HOME`:

```
backups/
└── dotfile_bk_YYYYMMDDHHMMSS/
    ├── .zshrc
    ├── .tmux.conf
    ├── .gitconfig               # always moved: it would override ~/.config/git/config
    ├── .config/nvim/init.lua    # files inside existing config dirs, too
    └── .zprezto/runcoms/z*      # zprezto runcoms (if present)
```

- Only real conflicts are moved: files that are already symlinks into this repo are left alone, so re-running the setup creates no new backup.
- `~/.bashrc`, `~/.profile` and `~/.bash_profile` are **not** touched (there is no bash config in this repo).
- Nothing is deleted; the folder is only created when something was moved.

The `backups/dot*` pattern is gitignored to avoid committing host-specific state.

## Rollback

```bash
# Restore a previous config
stow -D -t ~ zsh                                  # remove the symlink first
cp backups/dotfile_bk_YYYYMMDDHHMMSS/.zshrc ~/.zshrc
```
