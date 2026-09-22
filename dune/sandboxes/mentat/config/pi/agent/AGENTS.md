# Globel Pi Instructions

- Root is `/workspace`. Do not traverse outside it.
- Check the project-root AGENTS.md for stack-specific rules – if none exists, ask.
- Git Workflow
  - USE `git status` and `git diff` frequently to inspect and self-review your edits.
  - COMMIT logical progress incrementally with concise messages (`git add <files>`, `git commit -m "..."`).
  - NEVER run destructive commands: no `git reset --hard`, `git checkout --`, `git clean -fd`, or push.
- Run unit tests/linters and inspect `git diff` before declaring a task done.
