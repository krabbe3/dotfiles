# Dune AI Sandbox

An ephemeral, isolated development environment designed for autonomous coding agents and interactive experimentation. It leverages local shallow Git clones and rootless Docker to allow agents to execute arbitrary code, manage dependencies, and create rollback checkpoints without exposing your host commit history or risking your host working tree.

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
       ├─► Mid-flight: `dune sync` pulls active commits (to dune/agent-latest) to host anytime
       │
       ▼ (User exits container: exit / Ctrl+D)
Host Git Object Store
       │
       ▼ (git fetch ... HEAD:dune/agent-latest --force)
Host Branch: dune/agent-latest (Ready for review/merge)
```

## Key Features

- Complete History Isolation: Clones strictly at HEAD with --depth 1 and purges the origin remote. The agent cannot inspect past repository history or push to remotes.
- Continuous Checkpoints: The agent can commit freely to Git. Commits remain isolated within the container until synced or reviewed.
- Mid-Flight Syncing: A stable symlink (/tmp/.dune-clones/<project>-active) allows pulling commits into host Git branches while the container remains running.
- Single Review Reference: Upon sync or exit, commits are fetched to a single host branch pointer: dune/agent-latest.
- Clean Host State: The ephemeral directory and active symlink in /tmp/.dune-clones/ are automatically deleted via exit trap. Your active host working tree remains completely untouched.
- Environment Passthrough: Merges default container variables with any existing project .env file automatically.
- Persistent Cache Mounts: Dedicated bind mounts for pip and Neovim state cache build artifacts across multiple invocations.

## Directory Layout

Place the files in your dotfiles repository:

```Plaintext
dotfiles/dune/
├── bin/
│   ├── dune                    # entry-level dispatcher for dune
│   ├── dune-ai                 # CLI entrypoint and lifecycle manager
    └── dune-sync               # Mid-flight sync helper
├── sandboxes/
│   └── ai/
│       ├── .env                # Global default sandbox environment variables
│       ├── docker-compose.yml  # Container run configuration
│       └── Dockerfile.python   # Runtime image definition
└── data/                       # Host-cached runtime state (gitignored)
    ├── pip-cache/
    └── nvim/
```

## Installation & Setup

Add the executable script to your shell's search path.

In ~/.zshrc or ~/.bashrc:
```Bash
export PATH="$HOME/dotfiles/dune/bin:$PATH"
```

Make the script executable:
```Bash
chmod +x "$HOME/dotfiles/dune/bin/dune-ai"
```

## Configuration Files

`dotfiles/dune/sandboxes/ai/docker-compose.yml`
```YAML
services:
  dev:
    build:
      context: .
      dockerfile: Dockerfile.python
      args:
        PYTHON_VERSION: ${PYTHON_VERSION:-3.10}
    image: dune-python:${PYTHON_VERSION:-3.10}
    container_name: ${SANDBOX_NAME}
    working_dir: /workspace
    stdin_open: true
    tty: true
    env_file:
      - .env
      - ${PROJECT_ENV_FILE:-/dev/null}
    volumes:
      - ${TARGET_PROJECT}:/workspace
      - ../../data/pip-cache:/root/.cache/pip
      - ../../data/nvim/share:/root/.local/share/nvim
      - ../../data/nvim/state:/root/.local/state/nvim
```

`dotfiles/dune/sandboxes/ai/Dockerfile.python`
```Dockerfile
ARG PYTHON_VERSION=3.10
FROM python:${PYTHON_VERSION}-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    zsh \
    curl \
    ripgrep \
    fd-find \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Git defaults for agent-generated commits
RUN git config --system --add safe.directory /workspace \
    && git config --system --add safe.directory /root/dotfiles \
    && git config --system user.name "Dune Agent" \
    && git config --system user.email "agent@dune.local"

ENV SHELL=/bin/zsh
WORKDIR /workspace

CMD ["/bin/zsh"]
```

`dotfiles/dune/sandboxes/ai/.env`
```Bash
YOUR_API_KEYS=
```

## CLI Usage

Run dune ai from the root of any target repository or folder:

```Bash
# Start an interactive container with Python 3.10 (default)
dune ai
# Specify a custom Python version
dune ai --py 3.12
# Force a clean rebuild of the base Docker image
dune ai --rebuild
```

## Review & Integration Workflow

1. Work Inside the Container

Commit early and often as rollback checkpoints inside the sandbox:

```Bash
git add .
git commit -m "feat: parse schema structure"
```

2. Live Sync While Container is Running (Optional)

From a separate terminal or tmux pane on your host:

```Bash
dune sync
git diff HEAD..dune/agent-latest
git merge dune/agent-latest
```
The container continues running without interruption.

3. Exit & Final Ingestion

When finished inside the container:

```Bash
exit
```

The exit trap automatically ingests any remaining commits into branch `dune/agent-latest` and removes `/tmp` artifacts.

4. Merge or Discard on Host

    - Standard Merge:

    ```Bash
    git merge dune/agent-latest
    git branch -d dune/agent-latest
    ```

    - Squash Merge:

    ```Bash
    git merge --squash dune/agent-latest
    git commit -m "feat: complete feature via dune agent"
    git branch -d dune/agent-latest
    ```

    - Discard Work:

    ```Bash
    git branch -D dune/agent-latest
    ```
