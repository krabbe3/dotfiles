# Global Pi Instructions

- Root is the current working directory (the project root or a subfolder of it). Do not traverse outside the project.
- Check the project-root AGENTS.md for stack-specific rules.
- Run unit tests and linters before declaring a task done.
- NEVER run destructive commands (`rm -rf` on project dirs, `git reset --hard`, `git checkout --`, `git clean -fd`) without user permission.

## Dune Sandbox (docker container, hostnames start with `dune-`)

Check `$DUNE_MODE` to see how git works in this session.

### `DUNE_MODE=live` (default)

- You edit the user's real working tree. The user works on the same files at the same time in their editor.
  - Before editing a file, re-read it: it may have changed since you last looked.
  - Keep edits focused; do not reformat or rewrite files you were not asked to touch.
- `.git` is read-only. `git status`, `git diff`, `git log` and `git blame` work.
- `git add`, `git commit`, `git stash`, branching and git config fail. Do not try them or work around them. The user reviews and commits.
- When you finish a task, list the files you changed and summarize what changed in each.

### `DUNE_MODE=isolated`

- You work in a throwaway shallow clone. The user sees your work only through commits.
- Use `git status` and `git diff` frequently to self-review your edits.
- Commit logical progress incrementally with concise messages (`git add <files>`, `git commit -m "..."`). Always commit when you finish.
- Never push.

### Python

- `python`/`python3` is the host's active Conda env, mounted read-only at the same path: identical interpreter and packages to the host.
- Plain `pip install <pkg>` fails (read-only env). Use `pip install --user <pkg>` (session-local, lost at exit) or `python -m venv --system-site-packages /tmp/venv` for several packages.
- Live mode: the project is mounted at the same path as on the host, so the host's editable install (`pip install -e .`) works as-is.
- Isolated mode: the clone lives at a different path, so set `PYTHONPATH` to the project root (or its `src/`) to import the project's own code.
- Tell the user explicitly which Python packages you installed, so they can install them outside the container.
