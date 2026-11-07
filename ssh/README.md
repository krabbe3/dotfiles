# SSH

SSH config for an HPC cluster, compute nodes, and remote services.

The public repo only holds generic settings. Hostnames, usernames and port
forwards live in an untracked `config.local`, so they never reach GitHub.

## Structure

```
ssh/
└── .ssh/
    ├── config                 # Tracked: generic settings + includes
    ├── config.local           # Untracked (*.local is gitignored): private hosts
    └── config.local.example   # Tracked template for config.local
```

The tracked `config` loads, in order:

1. `IgnoreUnknown UseKeychain`: lets the macOS-only `UseKeychain` option sit in the shared config without breaking Linux
2. `Include ~/.colima/ssh_config`: Colima VM on macOS (ignored if missing)
3. `Include ~/.ssh/config.local`: your private hosts (ignored if missing)
4. `Host github.com`: GitHub over port 443

## Setup On A New Machine

`config.local` is not in git, so every machine needs it once. More precisely, every
home directory: HPC login and compute nodes usually share one. Two ways:

- **Recommended:** copy your private `setup_local.sh` into the repo root (it is gitignored), then run
  `./setup_full.sh`. That runs `setup_local.sh` at the end, which writes `config.local` and links it.
- **By hand:**
  ```bash
  cp ssh/.ssh/config.local.example ssh/.ssh/config.local   # fill in real values
  chmod 600 ssh/.ssh/config.local
  stow --no-folding -R -t ~ ssh
  ```

To change a host later, edit `~/dotfiles/ssh/.ssh/config.local` directly. Nothing
needs re-running, because `~/.ssh/config.local` is a symlink to that file.

Check it works:

```bash
ssh -G hpc | grep -i '^hostname'   # should print the real login host
```

## How It Is Linked

Stow links the files one by one (`--no-folding`), so `~/.ssh` stays a real
directory. Only `config`, `config.local` and `config.local.example` are symlinks into
the repo. Keys, `known_hosts` and `authorized_keys` stay in `~/.ssh` and never end up
in the repo folder.

`setup_full.sh` sets `~/.ssh` to `700` and `config` / `config.local` to `600`.

Machines set up by older versions of the script may have `~/.ssh` itself as a
symlink into the repo (`ls -ld ~/.ssh` shows `lrwx... -> dotfiles/...`). In that case
your keys are physically inside the repo folder. `setup_local.sh` detects this and
moves them into a real `~/.ssh` first.

## Hosts (defined in `config.local`)

| Alias | Purpose |
|-------|---------|
| `hpc` | HPC login node (primary gateway) |
| `m69` | Compute node (via `ProxyJump hpc`) |
| `ems-admin` | Admin access for data movement |
| `llm-tunnel` | LLM service tunnel (via `ProxyJump hpc`, keepalive configured) |
| `<gitlab-host>` | University GitLab (key added to agent / macOS keychain) |

## Port Forwards (`m69`)

| Forward | Purpose |
|---------|---------|
| `5398`, `3098` | OpenWebUI LLM web interface |
| `8765` | Lichtblick ROS visualization |

## Security

- **Agent forwarding** is on only for `hpc` and `m69`, where you run git with your local keys. `ProxyJump` does not need it.
- **X11 forwarding** on `m69` is `ForwardX11 yes` (untrusted mode).
  - Untrusted mode refuses new X11 connections after 20 min; set `ForwardX11Timeout 0` to remove that limit.
  - Some apps need trusted mode (GLX/OpenGL apps like rviz, clipboard). For those, add `ForwardX11Trusted yes` under `m69` in `config.local`, or connect with `kssh m69`, which uses `ssh -Y`.
  - Trusted mode lets root on the remote host read your keystrokes and screen.
- `llm-tunnel` uses `ExitOnForwardFailure yes` with a 30 s keepalive.

## Usage

```bash
ssh hpc          # HPC login node
ssh m69          # compute node, jumped through hpc (port forwards + X11)
ssh llm-tunnel   # tunnel only
```
