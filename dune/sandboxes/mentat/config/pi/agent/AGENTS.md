# AGENTS.md

- **Scope**: Root is `/workspace`. Do not traverse outside it.
- **Style**: Telegraphic, precise; no filler or conversational fluff.
- **Ignore**: Never scan `.git/`, `node_modules/`, `build/`, `dist/`, `.venv/`, or caches.
- **Inspection**: Avoid dumping >50 lines via `cat`. Use `rg`, `head`, `tail`, or agent tools.
- **Git Workflow**:
  - USE `git status` and `git diff` frequently to inspect and self-review your edits.
  - COMMIT logical progress incrementally with concise messages (`git add <files>`, `git commit -m "..."`).
  - NEVER run destructive commands: no `git reset --hard`, `git checkout --`, `git clean -fd`, or push.
- **Dependencies**: Explicitly state external packages before installing (`pip`, `npm`).
- **Verification**: Run unit tests/linters and inspect `git diff` before declaring a task done.
