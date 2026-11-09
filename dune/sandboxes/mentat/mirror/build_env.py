"""Build a Linux copy of a host Python env from the JSON written by export_env.py.

Runs inside the dune container (image Python, micromamba):
    python3 build_env.py <spec.json> <target prefix>

Packages that cannot be installed for Linux are dropped with a warning instead
of failing the build. Writes <prefix>/.dune-mirror.json when done.
"""

import json
import os
import shutil
import subprocess
import sys
import tempfile

MAMBA = os.environ.get("DUNE_MAMBA") or shutil.which("micromamba")


def run(cmd, quiet=False):
    print("+ " + " ".join(cmd), flush=True)
    return subprocess.run(cmd, stdout=subprocess.DEVNULL if quiet else None,
                          stderr=subprocess.DEVNULL if quiet else None).returncode == 0


def solvable(channels, specs):
    """Dry-run a solve; True if micromamba could create an env with these specs."""
    cmd = [MAMBA, "create", "-y", "--dry-run", "-p", "/tmp/dune-solve", "--override-channels"]
    for ch in channels:
        cmd += ["-c", ch]
    return run(cmd + specs, quiet=True)


def main():
    spec_path, prefix = sys.argv[1], sys.argv[2]
    with open(spec_path) as f:
        spec = json.load(f)
    if not MAMBA:
        sys.exit("build_env: micromamba not found in the image; rebuild it with 'dune mentat -r'")

    channels = spec["channels"]
    base = ["python=" + spec["python"], "pip"]
    conda = list(spec["conda"])
    warnings = [["%s (skipped on export)" % n, why] for n, why in spec["skipped"]]

    # conda packages: pinned versions first; per package fall back to unpinned, then drop
    if conda and not solvable(channels, base + conda):
        print("==> Full solve failed; checking packages one by one", flush=True)
        kept = []
        for s in conda:
            name = s.split("=")[0]
            if solvable(channels, base + [s]):
                kept.append(s)
            elif solvable(channels, base + [name]):
                kept.append(name)
                warnings.append([s, "version not available for Linux, using latest"])
            else:
                warnings.append([s, "not available for Linux"])
        conda = kept

    # start from a missing prefix: micromamba refuses to create an env in an
    # existing non-conda dir, so the prefix is a subdir of the mounted volume
    shutil.rmtree(prefix, ignore_errors=True)

    cmd = [MAMBA, "create", "-y", "-p", prefix, "--override-channels"]
    for ch in channels:
        cmd += ["-c", ch]
    if not run(cmd + base + conda):
        sys.exit("build_env: creating the env failed")

    py = os.path.join(prefix, "bin", "python")
    pip = [py, "-m", "pip", "install", "--no-input", "--disable-pip-version-check"]

    # pip packages: all at once, then one by one if that fails
    reqs = spec["pip"]
    if reqs and not run(pip + reqs):
        print("==> pip install failed; installing packages one by one", flush=True)
        for r in reqs:
            if not run(pip + [r]):
                warnings.append([r, "pip install failed"])

    # local folders: install from a copy (the mounted source is read-only)
    for e in spec["local"]:
        tmp = tempfile.mkdtemp(prefix="dune-src-")
        src = os.path.join(tmp, os.path.basename(e["path"]))
        shutil.copytree(e["path"], src, ignore=shutil.ignore_patterns(".git", "build", "*.egg-info", "__pycache__"))
        if not run(pip + [src]):
            warnings.append([e["name"], "local install failed: " + e["path"]])
        shutil.rmtree(tmp, ignore_errors=True)

    # editable folders: mounted at the same path, installed editable
    for e in spec["editable"]:
        if not run(pip + ["-e", e["path"]]):
            warnings.append([e["name"], "editable install failed: " + e["path"]])

    with open(os.path.join(prefix, ".dune-mirror.json"), "w") as f:
        json.dump({"hash": spec["hash"], "warnings": warnings}, f, indent=2)

    print("\n==> Linux copy of the env is ready: " + prefix)
    for what, why in warnings:
        print("    ! %s: %s" % (what, why))


if __name__ == "__main__":
    main()
