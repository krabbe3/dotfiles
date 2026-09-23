# Globel Pi Instructions

- Root is `/workspace`. Do not traverse outside it.
- Check the project-root AGENTS.md for stack-specific rules – if none exists, ask.
- Git Workflow
  - USE `git status` and `git diff` frequently to inspect and self-review your edits.
  - COMMIT logical progress incrementally with concise messages (`git add <files>`, `git commit -m "..."`).
  - NEVER run destructive commands: no `git reset --hard`, `git checkout --`, `git clean -fd`, or push without user permission
- Run unit tests/linters and inspect `git diff` before declaring a task done.
- Dune Sandbox (docker container, hostnames start with `dune-`)
  - When running inside a dune-mentat sandbox, `python`/`python3` is the host's active Conda env, mounted read-only at the same path — identical interpreter and packages to the host.
  - Plain `pip install <pkg>` fails (read-only env). Use `pip install --user <pkg>` (session-local, lost at exit) or `python -m venv [--system-site-packages] /tmp/venv` for multiple packages.
  - The project's own code is NOT importable via the host's `pip install -e .` (that pointer references a host-only path). Set `PYTHONPATH=/workspace` (or the src dir) instead.
  - State to the user explicitly which python packages you have installed, so he can do it outside of the container
