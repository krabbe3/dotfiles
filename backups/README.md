# Backups

Automated backup directory created by `setup_full.sh`.

## Behavior

Each run of `setup_full.sh` timestamps existing dotfiles before overwriting:

```
backups/
└── dotfile_bk_YYYYMMDDHHMMSS/
    ├── .bash_profile
    ├── .bashrc
    ├── .zshrc
    ├── .gitconfig
    ├── .tmux.conf
    ├── .profile
    └── z*    # zprezto runcoms (if present)
```

The `backups/dot*` pattern is gitignored to avoid committing host-specific state.

## Rollback

```bash
# Restore a previous config
cp backups/dotfile_bk_YYYYMMDDHHMMSS/.zshrc ~/.zshrc
```
