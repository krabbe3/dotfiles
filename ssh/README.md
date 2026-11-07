# SSH

SSH config for an HPC cluster, compute nodes, and remote services.

## Structure

```
ssh/
└── .ssh/
    ├── config                 # Tracked: generic settings + includes
    ├── config.local           # Untracked: private hosts (hostnames, users)
    └── config.local.example   # Template for config.local
```

On a new machine: `cp ssh/.ssh/config.local.example ssh/.ssh/config.local`, fill in real values, `chmod 600` it.

## Hosts (defined in `config.local`)

| Alias | Purpose |
|-------|---------|
| `hpc` | HPC login node (primary gateway) |
| `m69` | Compute node (via `ProxyJump hpc`) |
| `ems-admin` | Admin access for data movement |
| `llm-tunnel` | LLM service tunnel (via `ProxyJump hpc`, keepalive configured) |

## GitHub Over SSH (Port 443)

Reroutes `git@github.com` to `ssh.github.com:443` for environments that block standard SSH port 22.

## Port Forwards

| Host | Forward | Purpose |
|------|---------|---------|
| `m69` | `5398`, `3098` | OpenWebUI LLM web interface |
| `m69` | `8765` | Lichtblick ROS visualization |

## Security

- `ForwardAgent yes` only on `hpc` and `m69` (git operations with local keys)
- `IgnoreUnknown UseKeychain` keeps the macOS-only option from breaking Linux
- `setup_full.sh` sets `~/.ssh/config` permissions to `600`
- `llm-tunnel` uses `ExitOnForwardFailure yes` with 30s keepalive

## Usage

```bash
# Jump to HPC login
ssh hpc

# Jump through to compute node
ssh m69

# Forward agent for git operations on remote
ssh hpc  # then: git push (uses forwarded keys)
```
