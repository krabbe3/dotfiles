"""Describe a host Python env (Conda env or venv) so a Linux copy can be built.

Run with the env's own Python on the host:
    <env>/bin/python export_env.py <env prefix>

Prints JSON:
    python    "3.11"
    channels  conda channels the requested packages came from
    conda     requested conda packages, pinned to the installed version
    pip       pip requirements: name==version, or name @ git+URL@commit
    local     {name, version, path} of folders installed non-editable (pip install /path)
    editable  {name, version, path} of folders installed editable (pip install -e /path)
    skipped   [name, reason] for packages that cannot be mirrored
    hash      short hash of everything above
"""

import ast
import hashlib
import json
import os
import re
import subprocess
import sys

# conda tooling in a base env; useless in the mirror
CONDA_TOOLING = {"conda", "mamba", "conda-build", "conda-libmamba-solver", "libmamba", "libmambapy"}
# packages that only exist for macOS
MACOS_ONLY = re.compile(r"^(pyobjc.*|appnope|mlx|mlx-.*|tensorflow-macos|tensorflow-metal|libcxx|clang.*)$", re.I)


def spec_name(spec):
    return re.split(r"[\s=<>!~\[]", spec.strip(), maxsplit=1)[0].lower()


def requested_conda_specs(prefix):
    """Packages explicitly requested over the env's lifetime (conda-meta/history)."""
    names = {}
    path = os.path.join(prefix, "conda-meta", "history")
    if not os.path.exists(path):
        return names
    with open(path) as f:
        for line in f:
            m = re.match(r"# (install|update|remove) specs: (.*)", line)
            if not m:
                continue
            try:
                specs = ast.literal_eval(m.group(2))
            except (ValueError, SyntaxError):
                continue
            for s in specs:
                name = spec_name(s)
                if m.group(1) == "remove":
                    names.pop(name, None)
                else:
                    names[name] = s
    return names


def conda_packages(prefix):
    if not os.path.isdir(os.path.join(prefix, "conda-meta")):
        return []
    conda = os.environ.get("CONDA_EXE") or "conda"
    out = subprocess.run([conda, "list", "--json", "-p", prefix], capture_output=True, text=True)
    if out.returncode != 0:
        sys.exit("export_env: 'conda list' failed: " + out.stderr.strip())
    return json.loads(out.stdout)


def main():
    prefix = os.path.realpath(sys.argv[1])
    py = "%d.%d" % sys.version_info[:2]
    skipped = []

    # conda: requested packages, pinned to what is installed
    installed = {p["name"].lower(): p for p in conda_packages(prefix)}
    conda, channels = [], []
    for name in sorted(requested_conda_specs(prefix)):
        pkg = installed.get(name)
        if name == "python" or name in CONDA_TOOLING or pkg is None or pkg.get("channel") == "pypi":
            continue
        if MACOS_ONLY.match(name):
            skipped.append([name, "macOS only"])
            continue
        conda.append("%s=%s" % (pkg["name"], pkg["version"]))
        ch = pkg.get("channel") or "conda-forge"
        if ch not in channels:
            channels.append(ch)

    # pip: everything pip installed, classified by where it came from
    out = subprocess.run([sys.executable, "-m", "pip", "inspect"], capture_output=True, text=True)
    if out.returncode != 0:
        sys.exit("export_env: 'pip inspect' failed (needs pip >= 22.2): " + out.stderr.strip())
    pip, local, editable = [], [], []
    for dist in json.loads(out.stdout)["installed"]:
        if dist.get("installer") != "pip":
            continue
        name = dist["metadata"]["name"]
        version = dist["metadata"]["version"]
        if name.lower() in ("pip", "setuptools", "wheel"):
            continue
        if MACOS_ONLY.match(name):
            skipped.append([name, "macOS only"])
            continue
        direct = dist.get("direct_url")
        if not direct:
            pip.append("%s==%s" % (name, version))
        elif "vcs_info" in direct:
            vcs = direct["vcs_info"]
            req = "%s @ %s+%s@%s" % (name, vcs["vcs"], direct["url"], vcs["commit_id"])
            if direct.get("subdirectory"):
                req += "#subdirectory=" + direct["subdirectory"]
            pip.append(req)
        elif direct["url"].startswith("file://"):
            path = direct["url"][len("file://"):]
            if "dir_info" in direct and os.path.isdir(path):
                entry = {"name": name, "version": version, "path": path}
                (editable if direct["dir_info"].get("editable") else local).append(entry)
            elif "dir_info" in direct:
                skipped.append([name, "source folder not found: " + path])
            else:
                skipped.append([name, "installed from a local file: " + path])
        else:
            pip.append("%s @ %s" % (name, direct["url"]))

    spec = {
        "python": py,
        "channels": channels or ["conda-forge"],
        "conda": conda,
        "pip": sorted(pip, key=str.lower),
        "local": sorted(local, key=lambda e: e["path"]),
        "editable": sorted(editable, key=lambda e: e["path"]),
        "skipped": skipped,
    }
    spec["hash"] = hashlib.sha256(json.dumps(spec, sort_keys=True).encode()).hexdigest()[:12]
    json.dump(spec, sys.stdout, indent=2)
    print()


if __name__ == "__main__":
    main()
