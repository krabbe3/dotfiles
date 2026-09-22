# SSH

SSH config for TU Ilmenau HPC cluster, Makalu compute nodes, and remote services.

## Structure

```
ssh/
└── .ssh/
    └── config    # SSH client configuration
```

## Hosts

| Alias | Target | Purpose |
|-------|--------|---------|
| `hpc` | `cslogin.tu-ilmenau.de` | HPC login node (primary gateway) |
| `m69` | `makalu69.rz.tu-ilmenau.de` | Makalu compute node (via `ProxyJump hpc`) |
| `ems-admin` | `cslogin.tu-ilmenau.de` (user: admems) | EMS admin access for data movement |
| `llm-tunnel` | `makalu69.rz.tu-ilmenau.de` | LLM service tunnel (via `ProxyJump hpc`, keepalive configured) |

## GitHub Over SSH (Port 443)

Reroutes `git@github.com` to `ssh.github.com:443` for environments that block standard SSH port 22.

## Port Forwards

| Host | Forward | Purpose |
|------|---------|---------|
| `m69` | `19432 → localhost:19432` | Local port forward for remote services |

## Security

- `ForwardAgent yes` on all hosts (deploy key forwarding)
- `setup_full.sh` sets `~/.ssh/config` permissions to `600`
- `llm-tunnel` uses `ExitOnForwardFailure yes` with 30s keepalive

## Usage

```bash
# Jump to HPC login
ssh hpc

# Jump through to Makalu compute node
ssh m69

# Forward agent for git operations on remote
ssh hpc  # then: git push (uses forwarded deploy keys)
```
