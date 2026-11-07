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

- `python`/`pip` come from a session venv built on the host's active env (Conda env or venv), which is mounted read-only at the same path: same interpreter and packages as on the host.
- `pip install <pkg>` works and goes into the session venv; the host env is never changed. Installs are lost when the session ends, and the user sees a list of them at exit.
- Run tools as modules (`python -m pytest`, `python -m black`): the host env's own scripts (`pytest`, ...) do not see packages you installed in the session.
- Live mode: the project is mounted at the same path as on the host, so the host's editable install (`pip install -e .`) works as-is.
- Isolated mode: the clone lives at a different path, so set `PYTHONPATH` to the project root (or its `src/`) to import the project's own code.
- Tell the user explicitly which Python packages you installed and why, so they can add them to the host env.
