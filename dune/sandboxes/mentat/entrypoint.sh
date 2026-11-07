#!/usr/bin/env bash
# Container start for dune-mentat: Python env setup, then an interactive shell
# (or the given command). Settings come from bin/dune-mentat:
#   DUNE_PY_MODE    env   = use the host env's own interpreter (mounted read-only)
#                   image = use the image's Python (macOS host, no env, or a
#                           venv whose base Python is the host's system Python)
#   DUNE_HOST_PY    host env interpreter (env mode)
#   DUNE_HOST_BIN   host env bin dir, put on PATH after the session venv
#   DUNE_HOST_SITE  ':'-separated host venv site-packages to add (venv envs)
set -uo pipefail

# project is mounted at its host path, which git would otherwise call dubious
git config --global --add safe.directory "*"

VENV="${DUNE_VENV:-$HOME/.dune-venv}"
case "${DUNE_PY_MODE:-image}" in
  env) BASE_PY="$DUNE_HOST_PY" ;;
  *)   BASE_PY="$(command -v python3)" ;;
esac

# Session venv on top of the host env: the agent's pip installs land here,
# the read-only host env stays untouched. Gone when the container exits.
SITE=""
if "$BASE_PY" -m venv --system-site-packages --without-pip "$VENV" >/dev/null 2>&1; then
  SITE="$("$VENV/bin/python" -c 'import sysconfig; print(sysconfig.get_path("purelib"))')"
  if [[ -n "${DUNE_HOST_SITE:-}" ]]; then
    # addsitedir also processes .pth files there (editable installs)
    "$VENV/bin/python" - "$DUNE_HOST_SITE" "$SITE/_dune_host_env.pth" <<'EOF'
import sys
dirs = [d for d in sys.argv[1].split(":") if d]
with open(sys.argv[2], "w") as f:
    f.write("import site; " + "; ".join("site.addsitedir(%r)" % d for d in dirs) + "\n")
EOF
  fi
  # pip/pip3 must install into the venv, not into the host env's own pip script
  for p in pip pip3; do
    printf '#!/bin/sh\nexec "%s/bin/python" -m pip "$@"\n' "$VENV" > "$VENV/bin/$p"
    chmod +x "$VENV/bin/$p"
  done
  export VIRTUAL_ENV="$VENV"
  export PATH="$VENV/bin:${DUNE_HOST_BIN:+$DUNE_HOST_BIN:}$PATH"
  echo "==> Python: $("$VENV/bin/python" -c 'import sys; print(sys.version.split()[0])') ($([[ "${DUNE_PY_MODE:-image}" == env ]] && echo "host env $DUNE_HOST_PY" || echo "image")), pip installs go to a session venv"
else
  echo "==> Warning: could not create the session venv; pip install will fail in the read-only env"
  [[ -n "${DUNE_HOST_BIN:-}" ]] && export PATH="$DUNE_HOST_BIN:$PATH"
fi

if [[ $# -gt 0 ]]; then
  "$@"
else
  /bin/zsh
fi
STATUS=$?

# Tell the user what the agent installed, so they can add it to the host env
if [[ -n "$SITE" ]]; then
  INSTALLED="$("$VENV/bin/python" -m pip list --path "$SITE" --format=freeze 2>/dev/null || true)"
  if [[ -n "$INSTALLED" ]]; then
    echo ""
    echo "==> Packages installed during this session (not in your host env, now gone):"
    while IFS= read -r pkg; do echo "      $pkg"; done <<< "$INSTALLED"
  fi
fi
exit "$STATUS"
