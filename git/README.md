# Git

Git configuration with a private, untracked identity file.

## Structure

```
git/
└── .config/git/
    ├── config                 # Tracked: shared settings
    ├── config.local           # Untracked: [user] + host-specific url rewrites
    ├── config.local.example   # Template for config.local
    └── hooks/                 # Custom git hooks (core.hooksPath)
```

On a new machine `setup_local.sh` (run by `setup_full.sh`) creates `config.local`. Without it: `cp git/.config/git/config.local.example git/.config/git/config.local` and fill in your name/email. `~/.config/git` is a symlink to the whole folder, so the file takes effect immediately.

`setup_full.sh` moves an existing `~/.gitconfig` to `backups/`, because it would override these settings.

## Config

```ini
[include]
    path = ~/.config/git/config.local
[push]
    autoSetupRemote = true
[pull]
    rebase = true
[core]
    hooksPath = ~/.config/git/hooks
```

## Key Settings

- **Pull rebase**: `git pull` defaults to rebase (cleaner history)
- **Auto-setup remote**: New branches auto-track on push
- **GitLab redirect** (in `config.local`): `https://<gitlab-host>/` URLs rewrite to SSH
- **Custom hooks**: Hooks loaded from `~/.config/git/hooks` (note: this disables per-repo `.git/hooks`)
