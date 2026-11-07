# Dune AI Sandbox

A Docker sandbox for coding agents (pi, Claude Code, antigravity). The agent runs
arbitrary commands inside a container while you keep control of your git history.

Two modes:

- **Live (default):** the agent edits your real working tree, which you have open in
  nvim at the same time. `.git` is mounted read-only, so the agent can read history
  but cannot commit, branch, stash or install git hooks. You review with `git diff` and commit.
- **Isolated (`-i`):** the agent works in a throwaway shallow clone and commits there.
  Its commits come back to the host as branch `dune/agent-latest`. Good for long
  unattended runs that should not touch your working tree.

## Live Mode

```Plaintext
Host                                         Container (dune-<project>-agent)
nvim (you) ──┐                          ┌── agent
             ▼                          ▼
        /home/you/proj   ◄── same path, rw ──►   /home/you/proj
        /home/you/proj/.git ◄── same path, ro ──► /home/you/proj/.git
```

- **Same files, same time.** Edits show up in nvim on focus/buffer switch (`autoread` + `checktime` in
  `nvim/.../autocommands.lua`, `focus-events` in `.tmux.conf`). If you have unsaved edits in a file the
  agent changed, nvim warns (W12) instead of overwriting.
- **Same path as on the host.** Editable installs (`pip install -e .`) from your host env work in the
  container, and paths in tracebacks match your machine.
- **Read-only git.** `git status/diff/log/blame` work; `add/commit/stash/checkout -b/config` fail.
  For git worktrees the main repo's git dir is mounted read-only.
- **Your commits stay yours.** Review with `dune diff` (below) and commit yourself. Tip: `git add` your own work before handing a task over; `git diff` then shows only the agent's changes.
- **Ownership check.** Root in the container must map to your user: true for rootless Docker on Linux
  and Colima on macOS. With rootful Docker, `dune mentat` refuses to start (override: `DUNE_ALLOW_ROOTFUL=1`).
- Outside a git repo, live mode mounts the current folder with no history to fall back on.

## Snapshots: Review And Undo (`dune snap / diff / undo`)

Snapshots are taken on the host, where `.git` is writable; the agent cannot create or delete them.
Each one stores all files (tracked and untracked, gitignored ones excluded) as a commit object under
`refs/dune/<repo>/snap-<time>`. Your branch, `HEAD`, staging area and files are not touched, the
snapshots do not show up in `git log`, and `git push` does not send them.

In live mode, `dune mentat` snapshots automatically:

- at session start (`session start`)
- every 3 minutes while files change (`auto`; interval: `DUNE_SNAP_INTERVAL` in seconds)
- at exit (`session end`), then prints how to review and undo the session

```Plaintext
dune snap [-m <msg>]          Snapshot now (skipped when nothing changed)
dune snap -l                  List snapshots, newest first, with changes between them
dune diff [<snap>] [--stat]   What changed since <snap> (default: start of the last session)
dune diff -t [<snap>]         Same, in nvim (fugitive difftool, one tab per file)
dune undo [<snap>] [-- <paths>]
                              Restore files to <snap> (default: newest snapshot that differs).
                              Shows what will be reverted and asks; -y skips the question.
                              Snapshots the current state first, so 'dune undo 1' takes it back.
```

`<snap>` is a name (`snap-20261107-143012`) or a number from `dune snap -l` (1 = newest; numbers shift
when new snapshots are added, names do not).

Not covered: gitignored files (`.env`, data dirs, build output). Snapshots older than 7 days are
pruned once there are more than 50 (`DUNE_SNAP_DAYS`, `DUNE_SNAP_KEEP`).

Typical session:

```bash
dune mentat                 # pane 1: sandbox (snapshot "session start")
nvim .                      # pane 2: you, same files; agent edits reload on focus
dune diff -t                # review what changed this session
dune undo -- src/model.py   # throw away the agent's changes to one file
git commit                  # keep the rest
```

## Isolated Mode (`dune mentat -i`)

```Plaintext
Host Repository (HEAD)
       │
       ▼ (Ephemeral shallow clone: git clone --depth 1, remotes stripped)
~/.cache/dune-clones/<project>-<timestamp>/  ◄── Symlink: <project>-active
       │
       ▼ (Bind mount, same path)
Container: agent runs commands, installs packages, makes commits
       │
       ├─► Mid-flight: `dune spice` pulls active commits (to dune/agent-latest) to host anytime
       │
       ▼ (User exits container: exit / Ctrl+D)
Host Branch: dune/agent-latest (git fetch ... HEAD:dune/agent-latest --force)
```

- Clones strictly at HEAD with `--depth 1` and removes the origin remote: the agent cannot see past history or push.
- Uncommitted host edits and gitignored files are not in the clone.
- On exit, uncommitted work is auto-committed and fetched to `dune/agent-latest`; the clone and the active symlink are deleted.

## Shared Features

- AI-Ready Base Image: pi, Claude Code and antigravity, Neovim (via your dotfiles), git, fzf, ripgrep, Node 22.
- Same Python as the host: the active Conda env or venv is mounted read-only at the same path, with a session venv on top for the agent's installs (Linux hosts; see below).
- Persistent Cache Mounts: pip and Neovim state are kept across sessions in `dune/data/`.
- `$DUNE_MODE` (`live` / `isolated`) is set in the container; the agent instructions in `config/pi/agent/AGENTS.md` use it.

## Commands

```Plaintext
dune mentat [-i] [-p <python_version>] [-r]
                                     Launch the AI sandbox on the current project (live mode)
    -i, --isolated                Shallow clone instead; agent commits go to dune/agent-latest
    -p, --py, --python <version>  Specify Python version (default: auto-detected from the active
                                  host Conda env, otherwise 3.10)
    -r, --rebuild                 Force clean image rebuild (--no-cache)

dune spice                           (isolated mode) Fetch in-flight commits to dune/agent-latest

dune snap [-m <msg>] [-l]            Snapshot all files / list snapshots (see Snapshots)
dune diff [-t] [<snap>]              Changes since a snapshot (default: session start)
dune undo [-y] [<snap>] [-- <paths>] Restore files to a snapshot

dune ghola <template> [session_name] [conda_env]
                                     Resurrect workspace layout (editor/git/explorer) via tmuxinator
dune ghola -k [session_name]         Kill the tmux session for this project
```

## Environment Passthrough

Container environment is assembled in layers (later files override earlier ones):

1. `sandboxes/mentat/.env` — global sandbox defaults (copy from `.env.example`, e.g. `KISSKI_API_KEY`)
2. Project `.env` — the `.env` in the folder you start `dune mentat` from (in isolated mode also copied into the clone, gitignored there)

Additionally, a `DUNE_DATA_MOUNTS` variable in either `.env` adds extra bind mounts at runtime, comma-separated. Entries without a `:mode` suffix default to `:ro`, and entries with a single path are mapped to the same path inside the container.

The compose file also exports a read-only GitLab PAT (`GITLAB_READ_TOKEN` in the sandbox `.env`) for university GitLab, and mounts the pi agent configuration from `sandboxes/mentat/config/pi/` to `/root/.pi` inside the container.

### Python Environment Passthrough

If a Python env is active when you start `dune mentat` (`$VIRTUAL_ENV`, else `$CONDA_PREFIX`), the
sandbox uses it:

1. The env's Python version selects the base image `dune-python:<ver>`, unless overridden with `-p`.
2. The env is bind-mounted read-only at the same path (a venv also gets its base Python mounted).
3. `sandboxes/mentat/entrypoint.sh` creates a **session venv** on top (`python -m venv --system-site-packages`):
   - `python`, `pip` resolve to it; all packages of your env are visible, including editable installs.
   - `pip install` by the agent goes into the session venv. Your host env is never changed.
   - When the session ends, the session venv is gone and you get a list of what was installed.
   - The env's own `bin/` comes after it on `PATH`, so its CLI tools work. Those tools use the host
     interpreter directly; run them as `python -m <tool>` to also see session installs.

| Host env | Interpreter in the container |
|----------|------------------------------|
| Conda env | the env's own Python |
| venv on a Conda / pyenv / uv Python | the venv's base Python (mounted), venv packages added |
| venv on the system Python (`/usr`) | the image's Python of the same version, venv packages added |
| macOS host (any env) | the image's Python; macOS binaries cannot run in the Linux container |
| no env | the image's Python (3.10 or `-p`) |

## Project Dependencies

The sandbox does **not** auto-install project dependencies. The Python available in the container is:

1. The active host env, when launched with one — see [Python Environment Passthrough](#python-environment-passthrough). It already carries every third-party package you use on the host.
2. Otherwise the base image's Python, which preinstalls `black`, `pip-tools` and `ipython`. Install whatever you need manually inside the container.

### Making the project itself importable

- **Live mode:** nothing to do. The project is mounted at the same path as on the host, so an editable
  install (`pip install -e .`) in the host env points at the right place.
- **Isolated mode:** the clone lives at a different path, so set `PYTHONPATH` to the clone root (or its `src/`):

```bash
export PYTHONPATH=$PWD          # or $PWD/src for src-layout projects
```

Packages missing from the env: `pip install <package>` inside the sandbox (session venv, gone at exit; listed when the session ends).

## Directory Layout

```Plaintext
dotfiles/dune/
├── bin/
│   ├── dune                  # entry-level dispatcher
│   ├── dune-mentat           # sandbox CLI entrypoint and lifecycle manager
│   ├── dune-spice            # mid-flight sync helper (isolated mode)
│   ├── dune-snap             # snap / diff / undo (host-side snapshots)
│   └── dune-ghola            # tmuxinator layout helper
├── sandboxes/
│   └── mentat/
│       ├── .env              # Global default sandbox environment (gitignored, copy .env.example)
│       ├── .env.example      # Template with KISSKI_API_KEY
│       ├── Dockerfile.mentat # Runtime image definition (agents, dotfiles, tools)
│       ├── docker-compose.yml# Container run configuration
│       ├── entrypoint.sh     # Container start: session venv on the host env, then zsh
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
