# Dune AI Sandbox

An ephemeral, isolated development environment designed for autonomous coding agents and interactive experimentation. It leverages local shallow Git clones and local Docker to let agents execute arbitrary code, manage dependencies, and create rollback checkpoints without exposing your host commit history or risking your host working tree.

## Architecture Overview

```Plaintext
Host Repository (HEAD)
       │
       ▼ (Ephemeral shallow clone: git clone --depth 1, remotes stripped)
/tmp/.dune-clones/<project>-<timestamp>/  ◄── Symlink: <project>-active
       │
       ▼ (Bind mount)
Container Workspace (/workspace)
       │  - Agent runs commands, installs packages, makes commits
       │
       ├─► Mid-flight: `dune spice` pulls active commits (to dune/agent-latest) to host anytime
       │
       ▼ (User exits container: exit / Ctrl+D)
Host Git Object Store
       │
       ▼ (git fetch ... HEAD:dune/agent-latest --force)
Host Branch: dune/agent-latest (Ready for review/merge)
```

## Key Features

- Complete History Isolation: Clones strictly at HEAD with `--depth 1` and removes the origin remote. The agent cannot inspect past repository history or push to remotes.
- Continuous Checkpoints: The agent can commit freely to Git. Commits remain isolated within the container until synced or reviewed. On exit, uncommitted work is auto-committed as a snapshot before syncing.
- Mid-Flight Syncing: A stable symlink (`/tmp/.dune-clones/<project>-active`) allows `dune spice` to pull commits into the host branch while the container is still running.
- Single Review Reference: Upon sync or exit, commits are fetched to a single host branch pointer: `dune/agent-latest`.
- Clean Host State: The ephemeral directory and active symlink in `/tmp/.dune-clones/` are automatically deleted via an exit trap. Your active host working tree remains completely untouched.
- AI-Ready Base Image: The Docker image preinstalls the pi coding agent, Neovim (via your dotfiles), git, fzf, ripgrep, Node 22, and graphify.
- Identical Python via Conda Passthrough: When a Conda env is active on the host, `dune mentat` mounts it at the same path (read-only) and prepends it to the container's `PATH`. The container then runs the exact same Python interpreter and packages as the host. Requires Conda on the host — without an active Conda env, the container falls back to the base image's Python.
- Persistent Cache Mounts: Dedicated bind mounts for pip and Neovim state keep build artifacts across multiple invocations (`dune/data/`).
- Plannotator Support: A free host port in 19400–19600 is auto-assigned per session and forwarded into the container (`PLANNOTATOR_REMOTE=1`).

## Commands

```Plaintext
dune mentat [-p <python_version>] [-r]   Launch isolated AI sandbox (shallow clone + dev container)
    -p, --py, --python <version>  Specify Python version (default: auto-detected from the active
                                  host Conda env, otherwise 3.10)
    -r, --rebuild                 Force clean image rebuild (--no-cache)

dune spice                           Fetch in-flight commits from active sandbox to dune/agent-latest

dune ghola <template> [session_name] [conda_env]
                                     Resurrect workspace layout (editor/git/explorer) via tmuxinator
dune ghola -k [session_name]         Kill the tmux session for this project
```

## Environment Passthrough

Container environment is assembled in layers (later files override earlier ones):

1. `sandboxes/mentat/.env` — global sandbox defaults (copy from `.env.example`, e.g. `KISSKI_API_KEY`)
2. Project `.env` — injected from the repo root if present

Additionally, a `DUNE_DATA_MOUNTS` variable in either `.env` adds extra bind mounts at runtime, comma-separated. Entries without a `:mode` suffix default to `:ro`, and entries with a single path are mapped to the same path inside the container.

The compose file also exports a read-only GitLab PAT (`GITLAB_READ_TOKEN` in the sandbox `.env`) for university GitLab, and mounts the pi agent configuration from `sandboxes/mentat/config/pi/` to `/root/.pi` inside the container.

### Conda Environment Passthrough

If `dune mentat` is started with a host Conda env active (`CONDA_PREFIX` set), that env is passed through to the container:

1. The env's Python version (major.minor) is used to select the base image `dune-python:<ver>`, unless overridden with `-p`.
2. `$CONDA_PREFIX` is bind-mounted at the same path, read-only.
3. `$CONDA_PREFIX/bin` is prepended to `PATH` at container start.

Result: `python`/`python3` in the container resolves to the host env's interpreter, and all installed packages are identical to the host — the agent runs in exactly the same Python environment you use on the host. This behavior **requires Conda** (e.g., Miniconda/Miniforge) installed on the host with the env activated before launching `dune mentat`. If no Conda env is active, the container uses the base image's Python (default 3.10, or the `-p` version).

## Project Dependencies

The sandbox does **not** auto-install project dependencies. The Python available in the container is:

1. The active host Conda env, when launched with one — see [Conda Environment Passthrough](#conda-environment-passthrough). It already carries every third-party package you use on the host.
2. Otherwise the base image's Python, which preinstalls `black`, `pip-tools`, `ipython`, and `graphify`. Install whatever you need manually inside the container.

### Making the project itself importable

If you develop the project on the host with `pip install -e .`, the editable install is only a pointer into the *host's* project path. That path does not exist in the container, and the read-only Conda mount means the env cannot be reinstalled there — so the project's own code is not importable as-is. Set `PYTHONPATH` to the project root (or its `src/` directory; the clone is mounted at `/workspace`):

```bash
export PYTHONPATH=/workspace          # or /workspace/src for src-layout projects
```

Add this to your shell rc or export it before the command that needs it.

To add packages that are missing from the env without touching the host env (the mount is read-only), install into the container's user site:

```bash
pip install --user <package>          # session-local, gone when the container exits
```

## Directory Layout

```Plaintext
dotfiles/dune/
├── bin/
│   ├── dune                  # entry-level dispatcher
│   ├── dune-mentat           # sandbox CLI entrypoint and lifecycle manager
│   ├── dune-spice            # mid-flight sync helper
│   └── dune-ghola            # tmuxinator layout helper
├── sandboxes/
│   └── mentat/
│       ├── .env              # Global default sandbox environment (gitignored, copy .env.example)
│       ├── .env.example      # Template with KISSKI_API_KEY
│       ├── Dockerfile.mentat # Runtime image definition (pi agent, dotfiles, graphify)
│       ├── docker-compose.yml# Container run configuration
│       └── config/pi/        # Pi agent configuration mounted into the container
└── data/                     # Host-cached runtime state (gitignored)
    ├── pip-cache/
    └── nvim/
        ├── share/
        └── state/
```

## Installation & Setup

1. Copy `dune/sandboxes/mentat/.env.example` to `dune/sandboxes/mentat/.env` and fill in your API keys.
2. Add `dune/bin` to your shell's `PATH`.
3. `dune mentat` will build the Docker image on first use for the selected Python version; pass `-r` to force a clean rebuild.
