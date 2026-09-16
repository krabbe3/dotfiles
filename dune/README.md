# Dune AI Sandbox

An ephemeral, isolated development environment designed for autonomous coding agents and interactive experimentation. It leverages local shallow Git clones and rootless Docker to allow agents to execute arbitrary code, manage dependencies, and create rollback checkpoints without exposing your host commit history or risking your host working tree.

## Architecture Overview

```Plaintext
Host Repository (HEAD)
       │
       ▼ (Ephemeral shallow clone: git clone --depth 1, remotes stripped)
/tmp/.dune-clones/<project>-<timestamp>/
       │
       ▼ (Bind mount)
Container Workspace (/workspace)
       │  - Agent runs commands, installs packages, makes commits
       ▼ (User exits container)
Host Git Object Store
       │
       ▼ (git fetch ... HEAD:dune/agent-latest --force)
Host Branch: dune/agent-latest (Ready for review/merge)
```

## Key Features

- Complete History Isolation: Clones strictly at HEAD with --depth 1 and purges the origin remote. The agent cannot inspect past repository history or push to remote remotes.
- Autonomous Checkpoints: The agent can commit freely to Git. Commits remain isolated within the container until review.
- Single Review Reference: Upon exit, all commits made inside the container are force-fetched to a single host branch pointer: dune/agent-latest. No branch proliferation or dangling tags.
- Clean Host State: The ephemeral directory in /tmp/.dune-clones/ is automatically deleted via exit trap. Your active host working tree remains completely untouched.
- Environment Passthrough: Merges default container variables with any existing project .env file automatically.
- Persistent Cache Mounts: Dedicated bind mounts for pip and Neovim state cache build artifacts across multiple invocations.

## Directory Layout

Place the files in your dotfiles repository:

```Plaintext
dotfiles/dune/
├── bin/
│   └── dune-ai                 # CLI entrypoint and lifecycle manager
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

When you exit the container (exit or Ctrl-D), dune-ai checks whether commits were created inside the sandbox. If new commits exist, they are written to dune/agent-latest on your host.

1. Review the Changes

Compare the agent's work against the commit you started from:

```Bash
git diff HEAD..dune/agent-latest
```

View the individual commit messages and per-commit patches:

```Bash
git log -p HEAD..dune/agent-latest
```

2. Merge into Your Branch

To keep the agent's commit history intact:

```Bash
git merge dune/agent-latest
git branch -d dune/agent-latest
```

To collapse all agent work into a single clean commit on your branch:

```Bash
git merge --squash dune/agent-latest
git commit -m "feat: implement feature via dune agent"
git branch -d dune/agent-latest
```

3. Discard the Work

If the agent's run was unsatisfactory, discard the review branch entirely:

```Bash
git branch -D dune/agent-latest
```
