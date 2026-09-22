# Git

Git configuration with TU Ilmenau integration.

## Structure

```
git/
├── .gitconfig          # Main git config
└── hooks/              # Custom git hooks (path: /home/lomo3746/.config/git/hooks)
```

## Config

```ini
[user]
    email = lorenz.mohr@tu-ilmenau.de
    name = Lorenz Mohr
[push]
    autoSetupRemote = true
[pull]
    rebase = true
[url "git@gitlab.tu-ilmenau.de:"]
    insteadOf = https://gitlab.tu-ilmenau.de/
[core]
    hooksPath = /home/lomo3746/.config/git/hooks
```

## Key Settings

- **Pull rebase**: `git pull` defaults to rebase (cleaner history)
- **Auto-setup remote**: New branches auto-track on push
- **GitLab redirect**: `https://gitlab.tu-ilmenau.de/` URLs rewrite to `git@gitlab.tu-ilmenau.de:` (SSH)
- **Custom hooks**: Hooks loaded from `/home/lomo3746/.config/git/hooks`
