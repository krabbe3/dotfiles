# Dune AI Sandbox

A Docker sandbox for coding agents (pi, Claude Code, antigravity). The agent runs
arbitrary commands inside a container while you keep control of your git history.

Two modes:

- **Live (default):** the agent edits your real working tree, which you have open in
  nvim at the same time. `.git` is mounted read-only, so the agent can read history
  but cannot commit, branch, stash or install git hooks. You review with `git diff` and commit.
- **Isolated (`-i`):** the agent works in a throwaway shallow clone and commits there.
  Its commits come back to the host as branch `dune/agent-<time>`. Good for long
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
~/.cache/dune-clones/<project>-<time>/
       │
       ▼ (Bind mount, same path)
Container: agent runs commands, installs packages, makes commits
       │
       ├─► Mid-flight: `dune spice` fetches the commits to the host anytime
       │
       ▼ (User exits container: exit / Ctrl+D)
Host branch dune/agent-<time>   (one per session; dune/agent-latest points to the newest)
```

- Clones strictly at HEAD with `--depth 1` and removes the origin remote: the agent cannot see past history or push.
- Uncommitted host edits and gitignored files are not in the clone.
- On exit, uncommitted work is auto-committed and the clone's commits are fetched to `dune/agent-<time>`;
  `dune/agent-latest` moves there too (unless you have it checked out). Then the clone is deleted.
- **If the fetch fails, the clone is kept** and its path printed. `dune spice` recovers it later.
- Several isolated sessions on the same repo do not interfere: each has its own clone and branch.
- Old session branches stay until you delete them: `git branch -D dune/agent-<time>`.

## Shared Features

- AI-Ready Base Image: pi, Claude Code and antigravity, Neovim (via your dotfiles), git, fzf, ripgrep, Node 22.
- Same Python as the host: the active Conda env or venv is mounted read-only at the same path (Linux) or rebuilt as a Linux copy (macOS), with a session venv on top for the agent's installs.
- Persistent Cache Mounts: pip and Neovim state are kept across sessions in `dune/data/`.
- `$DUNE_MODE` (`live` / `isolated`) is set in the container; the agent instructions in `config/pi/agent/AGENTS.md` use it.

## Commands

```Plaintext
dune mentat [-i] [-g] [-p <python_version>] [-r] [--rebuild-env]
                                     Launch the AI sandbox on the current project (live mode)
    -i, --isolated                Shallow clone instead; agent commits go to dune/agent-<time>
    -g, --gitlab                  Give the agent the GitLab token for this session (see below)
    --rebuild-env                 macOS: rebuild the Linux copy of the active env
    -p, --py, --python <version>  Specify Python version (default: the active host venv or
                                  Conda env, otherwise 3.10)
    -r, --rebuild                 Force clean image rebuild (--no-cache)

dune spice                           (isolated mode) Fetch commits of running or kept clones to
                                     dune/agent-<time>; move dune/agent-latest to the newest

dune snap [-m <msg>] [-l]            Snapshot all files / list snapshots (see Snapshots)
dune diff [-t] [<snap>]              Changes since a snapshot (default: session start)
dune undo [-y] [<snap>] [-- <paths>] Restore files to a snapshot

dune ghola [-t <template>] [-s <session>] [-e <env>] [-d]
                                     Open (or return to) the tmux workspace of this directory
dune ghola -k [session]              Kill the tmux session of this directory (or the named one)
```

## Workspace (`dune ghola`)

`dune ghola` opens a tmux session for the current directory, in plain tmux (no tmuxinator needed):

```Plaintext
window "agent":  ┌ agent (38%)      ┬ editor (38%) ┬ terminal (24%)        ┐
                 │ dune mentat      │ nvim .       │ tests, runs, scripts  │
window "git":    ┌ lazygit (50%)    ┬ review (50%)                         ┐
                 │ stage, commit    │ dune diff / undo / snap -l           │
```

- **agent window:** working side by side with the agent.
  - **agent:** the sandbox. No harness starts by itself: start `pi`, `claude` or `agy` when the container is up.
  - **editor:** nvim on the same files; agent edits reload when you switch to it.
  - **terminal:** your own shell on the host for tests, runs and scripts.
- **git window:** all version control in one place.
  - **lazygit:** stage and commit (only you can commit; `.git` is read-only for the agent).
  - **review:** a shell for reviewing agent work with `dune diff` / `dune diff -t`, `dune undo` and `dune snap -l`.
- Every pane activates the same Python env: `-e <conda env or venv path>`, else the active venv / conda
  env, else `./.venv`. Only `conda activate` runs per pane; `.zshrc` already set conda up.
- Pane sizes are percentages, so the layout fits any terminal (tmux >= 3.1 uses `-l N%`, older `-p N`).
- Session name: `<dir>-<hash of path>`, safe for tmux and unique per folder; `-s` overrides it.
- Running it again returns to the session; inside tmux it switches client instead of nesting.
- `-d` creates the session without attaching; `-k` kills it. Closing the session (or a pane) ends
  `dune mentat` cleanly: the session-end snapshot (live) or the fetch to `dune/agent-<time>` (isolated) still happens.
- `-t <template>` uses a tmuxinator template instead, e.g. `-t duncan`
  (`tmux/.config/tmuxinator/duncan.yml`, same layout with a fixed-size layout string).

## Environment Passthrough

Container environment is assembled in layers (later files override earlier ones):

1. `sandboxes/mentat/.env` — global sandbox defaults (copy from `.env.example`, e.g. `KISSKI_API_KEY`)
2. Project `.env` — the `.env` in the folder you start `dune mentat` from (in isolated mode also copied into the clone, gitignored there)

Additionally, a `DUNE_DATA_MOUNTS` variable in either `.env` adds extra bind mounts at runtime, comma-separated. Entries without a `:mode` suffix default to `:ro`, and entries with a single path are mapped to the same path inside the container.

### GitLab Token (`--gitlab`)

For private packages on the university GitLab, set in `sandboxes/mentat/.env` (gitignored):

```bash
DUNE_GITLAB_HOST=<gitlab host>
GITLAB_READ_TOKEN=<token with read_repository scope>
```

By default the token is **not** available in the sandbox: it is blanked in the container
environment and left out of the `.env` copied into isolated clones. With `dune mentat --gitlab`, the
agent gets it for that session, and git rewrites `https://<host>/`, `git@<host>:` and
`ssh://git@<host>/` URLs to use it, so `pip install git+https://...` / `git+ssh://...` work.
The token is then readable by the agent and via `docker inspect`; keep its scope read-only.

The pi agent configuration is mounted from `sandboxes/mentat/config/pi/` to `/root/.pi`.

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
| macOS host (Conda env / venv) | a Linux copy of the env, built once per package list (below) |
| no env | the image's Python (3.10 or `-p`) |

### macOS: Linux Copy Of The Env

A macOS env contains macOS binaries, which cannot run in the Linux container. On a Mac,
`dune mentat` therefore builds a Linux copy of the active env and uses it like the mounted env on Linux
(read-only, with the session venv on top):

1. `mirror/export_env.py` runs with the env's Python on the host and records:
   - conda packages you requested (`conda-meta/history`), pinned to the installed versions
   - pip packages: PyPI ones as `name==version`, git ones at the installed commit
   - folders installed with `pip install /path` (copied and installed) and `pip install -e /path`
     (mounted at the same path and installed editable)
2. `mirror/build_env.py` builds it with micromamba in the container, into a docker volume named after
   a hash of that list. Conda packages that do not exist for Linux fall back to the latest version or
   are dropped; failing pip packages are skipped. Each is reported at the end of the build.
3. The next `dune mentat` with the same package list starts right away. When the list changes (you
   install or update something), a new copy is built and the old volume is removed.

- The first build of an env takes a few minutes; conda packages are cached in the `dune-mamba-pkgs` volume.
- GitLab packages are installed with `GITLAB_READ_TOKEN` during the build, without `--gitlab`: the
  agent is not running then and never sees the token.
- `--rebuild-env` forces a rebuild (e.g. after changing code in a folder installed with `pip install /path`).
- macOS-only packages (`pyobjc*`, `appnope`, `mlx*`, ...) are skipped.
- The copy is re-solved for Linux, so it can differ in details; on Apple Silicon it is a `linux-aarch64`
  env, where a few conda-forge packages are missing.
- Needs an image with micromamba: run `dune mentat -r` once after updating.

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
│   ├── dune-spice            # fetch isolated sandbox commits to the host
│   ├── dune-snap             # snap / diff / undo (host-side snapshots)
│   └── dune-ghola            # tmux workspace (agent | editor | terminal, lazygit | review)
├── sandboxes/
│   └── mentat/
│       ├── .env              # Global default sandbox environment (gitignored, copy .env.example)
│       ├── .env.example      # Template: KISSKI_API_KEY, DUNE_GITLAB_HOST, GITLAB_READ_TOKEN
│       ├── Dockerfile.mentat # Runtime image definition (agents, dotfiles, tools)
│       ├── docker-compose.yml# Container run configuration
│       ├── entrypoint.sh     # Container start: session venv on the host env, then zsh
│       ├── mirror/           # macOS: export host env, build its Linux copy
│       └── config/           # Agent configs, mounted read-write (the agent may edit them)
│           ├── pi/           #   -> /root/.pi      (AGENTS.md, models.json, extensions, ...)
│           ├── claude/       #   -> /root/.claude
│           ├── claude.json   #   -> /root/.claude.json (gitignored, created as {} if missing)
│           └── gemini/       #   -> /root/.gemini  (antigravity)
└── data/                     # Host-cached runtime state (gitignored)
    ├── mirror/               # macOS: env export per copy (<volume>.json) and build markers
    ├── pip-cache/
    └── nvim/
        ├── share/
        └── state/
```

## Installation & Setup

1. `setup_full.sh` links `dune/bin/dune` to `~/.local/bin/dune` and creates `sandboxes/mentat/.env`
   from the template. Fill in `KISSKI_API_KEY`, and for GitLab packages `DUNE_GITLAB_HOST` and
   `GITLAB_READ_TOKEN` (see [GitLab Token](#gitlab-token---gitlab)).
2. Docker: Colima on macOS (installed and started by `setup_full.sh`); rootless Docker on Linux
   (set up separately; `dune mentat` refuses rootful Docker, see Live Mode).
3. `dune mentat` builds the image on first use for the selected Python version. After pulling changes
   to `Dockerfile.mentat` (e.g. micromamba for the macOS env copy), run `dune mentat -r` once.
4. For editing alongside the agent: the nvim reload autocommand and tmux `focus-events` are part of
   these dotfiles (`nvim/.../autocommands.lua`, `tmux/.tmux.conf`); reload tmux once with `Prefix + r`.

Agent configs under `sandboxes/mentat/config/` are writable by the agent, and some files there are
tracked (`AGENTS.md`, `settings.json`, `models.json`, `extensions/`, ...). Check
`git -C ~/dotfiles diff dune/` before committing or pushing, since this repo is public.
