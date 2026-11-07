#!/usr/bin/env bash
set -euo pipefail

# Run from the dotfiles directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Dont link DS_Store files
find . -name ".DS_Store" -exec rm -f {} +

# Fetch zsh/tmux plugin submodules (oh-my-zsh, tpm, ...)
if [ -e .git ] && command -v git >/dev/null 2>&1; then
    echo "==> Updating git submodules..."
    git submodule update --init --recursive
fi

###### VERSION REQUIREMENTS ######
NVIM_TARGET="v0.11.5"
LAZYGIT_TARGET="v0.53.0"
TREE_SITTER_TARGET="v0.25.4"

###### DIRECTORIES & PATH ######
mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"
export PATH="$HOME/.local/bin:$PATH"

###### PLATFORM DETECTION & INSTALL PACKAGES ######
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "==> macOS detected. Using Homebrew..."

    # Install Homebrew if not present
    if ! command -v brew >/dev/null 2>&1; then
        echo "==> Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL --retry 3 --retry-delay 2 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH (Apple Silicon)
        if [ -d "$HOME/.linuxbrew/bin" ]; then
            export PATH="$HOME/.linuxbrew/bin:$PATH"
        elif [ -d "$HOME/.homebrew/bin" ]; then
            export PATH="$HOME/.homebrew/bin:$PATH"
        elif [ -d "/opt/homebrew/bin" ]; then
            export PATH="/opt/homebrew/bin:$PATH"
        fi
    fi

    # Install required packages via Homebrew
    echo "==> Installing packages via Homebrew..."
    brew install neovim stow lazygit tmux tmuxinator node rust docker docker-compose docker-buildx colima

    # Initialize Colima (lightweight Docker daemon via VM, required on macOS)
    if ! colima status --json 2>/dev/null | grep -q '"running":true'; then
        echo "==> Starting Colima..."
        colima start --cpu 2 --memory 4 --disk 50
    fi

    # Fix Docker config for Colima (remove Docker Desktop keychain credential store)
    DOCKER_CONFIG="$HOME/.docker/config.json"
    if [ -f "$DOCKER_CONFIG" ] && grep -q '"credsStore"' "$DOCKER_CONFIG"; then
        echo "==> Removing credsStore from Docker config (Colima doesn't use keychain)..."
        if command -v jq >/dev/null 2>&1; then
            jq 'del(.credsStore)' "$DOCKER_CONFIG" > "$DOCKER_CONFIG.tmp" && mv "$DOCKER_CONFIG.tmp" "$DOCKER_CONFIG"
        else
            sed -i '' '/"credsStore"/d' "$DOCKER_CONFIG"
        fi
    fi

    # Link Docker CLI plugins (compose and buildx must live in ~/.docker/cli-plugins/)
    mkdir -p "$HOME/.docker/cli-plugins"
    ln -sfn "$(brew --prefix)/opt/docker-compose/bin/docker-compose" "$HOME/.docker/cli-plugins/docker-compose"
    ln -sfn "$(brew --prefix)/opt/docker-buildx/bin/docker-buildx" "$HOME/.docker/cli-plugins/docker-buildx"
    echo "==> Docker CLI plugins linked."

    # Pin neovim version to prevent updates
    brew pin neovim
    echo "==> Pinned neovim version: $(nvim --version | head -n 1 | awk '{print $2}')"

    # Install cargo packages (treesitter and texlab for nvim lsp mainly)
    if ! command -v tree-sitter >/dev/null 2>&1 && [ ! -x "$HOME/.cargo/bin/tree-sitter" ]; then
        echo "==> Installing tree-sitter CLI via Cargo..."
        export PATH="$HOME/.cargo/bin:$PATH"
        cargo install --locked "tree-sitter-cli@${TREE_SITTER_TARGET#v}"
        cargo install --locked texlab
        echo "==> cargo packages installed."
    else
        echo "==> cargo packages already installed, skipping."
    fi

elif [[ "$OSTYPE" == "linux"* ]]; then
    echo "==> Linux detected. Using manual downloads..."
    case "$(uname -m)" in
      x86_64)
        NVIM_URL="https://github.com/neovim/neovim-releases/releases/download/${NVIM_TARGET}/nvim-linux-x86_64.tar.gz"
        LAZYGIT_ARCH="x86_64" ;;
      aarch64|arm64)
        NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_TARGET}/nvim-linux-arm64.tar.gz"
        LAZYGIT_ARCH="arm64" ;;
      *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac

    # install nvim (v0.11.5 required; needs older glibc compat from neovim-releases)
    INSTALLED_NVIM="$HOME/.local/bin/nvim"
    CURRENT_NVIM=""
    if [ -x "$INSTALLED_NVIM" ]; then
        CURRENT_NVIM="$("$INSTALLED_NVIM" --version 2>/dev/null | head -n 1 | awk '{print $2}')"
    elif command -v nvim >/dev/null 2>&1; then
        CURRENT_NVIM="$(nvim --version 2>/dev/null | head -n 1 | awk '{print $2}')"
    fi

    if [ "$CURRENT_NVIM" != "$NVIM_TARGET" ]; then
        echo "==> Neovim '$CURRENT_NVIM' detected (required: $NVIM_TARGET). Installing to ~/.local..."
        curl -fsSL --retry 3 --retry-delay 2 "$NVIM_URL" -o "$HOME/.local/opt/nvim.tar.gz"

        rm -rf "$HOME/.local/opt/nvim"
        mkdir -p "$HOME/.local/opt/nvim"
        tar xzf "$HOME/.local/opt/nvim.tar.gz" -C "$HOME/.local/opt/nvim" --strip-components=1
        rm -f "$HOME/.local/opt/nvim.tar.gz"

        ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
        echo "==> Pinned Neovim $NVIM_TARGET installed to ~/.local/bin/nvim."
    else
        echo "==> Pinned Neovim $NVIM_TARGET already present in ~/.local, skipping."
    fi

    # install lazygit
    if ! command -v lazygit >/dev/null 2>&1 && [ ! -x "$HOME/.local/opt/lazygit/lazygit" ]; then
        echo "==> Installing lazygit..."
        curl -fsSL --retry 3 --retry-delay 2 "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_TARGET}/lazygit_${LAZYGIT_TARGET#v}_Linux_${LAZYGIT_ARCH}.tar.gz" -o "$HOME/.local/opt/lazygit.tar.gz"
        mkdir -p "$HOME/.local/opt/lazygit"
        tar xzf "$HOME/.local/opt/lazygit.tar.gz" -C "$HOME/.local/opt/lazygit"
        rm -f "$HOME/.local/opt/lazygit.tar.gz"
        ln -sf "$HOME/.local/opt/lazygit/lazygit" "$HOME/.local/bin/lazygit"
    else
        echo "==> lazygit already installed, skipping."
    fi

    # install stow
    if ! command -v stow >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/stow" ]; then
        echo "==> Compiling and installing GNU Stow..."
        curl -fsSL --retry 3 --retry-delay 2 https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz -o "$HOME/.local/opt/stow.tar.gz"
        mkdir -p "$HOME/.local/opt/stow"
        tar xzf "$HOME/.local/opt/stow.tar.gz" -C "$HOME/.local/opt/stow"
        rm -f "$HOME/.local/opt/stow.tar.gz"

        STOW_SRC_DIR=$(find "$HOME/.local/opt/stow" -maxdepth 1 -type d -name "stow-*" | head -n 1)
        if [ -n "$STOW_SRC_DIR" ]; then
            pushd "$STOW_SRC_DIR" >/dev/null
            ./configure --prefix="$HOME/.local"
            make
            make install
            popd >/dev/null
        fi
    else
        echo "==> GNU Stow already installed, skipping."
    fi

    #install tmuxinator
    # install tmuxinator
    if ! command -v tmuxinator >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/tmuxinator" ]; then
        if command -v gem >/dev/null 2>&1; then
            echo "==> Installing tmuxinator to ~/.local/bin..."
            mkdir -p "$HOME/.local/bin"
            gem install --no-document --user-install -n "$HOME/.local/bin" tmuxinator
        else
            echo "==> Warning: gem not found on host. Skipping tmuxinator install."
        fi
    else
        echo "==> tmuxinator already installed, skipping."
    fi

    # install tree-sitter CLI (via cargo due to glibc compatibility)
    if ! command -v tree-sitter >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/tree-sitter" ]; then
        echo "==> Installing tree-sitter CLI via cargo..."
        # Ensure Rust toolchain is available
        if ! command -v cargo >/dev/null 2>&1; then
            echo "==> Installing Rust toolchain..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        fi
        # Build and install specific version
        cargo install --locked "tree-sitter-cli@${TREE_SITTER_TARGET#v}"
        echo "==> tree-sitter CLI installed."
    else
        echo "==> tree-sitter CLI already installed, skipping."
    fi

    # install Node.js via nvm (nvm is a shell function, so check its install dir)
    if [ ! -s "$HOME/.nvm/nvm.sh" ]; then
        echo "==> Installing nvm..."
        curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    fi

    if ! command -v node >/dev/null 2>&1; then
        echo "==> Installing Node.js (LTS)..."
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        nvm install --lts
        nvm alias default lts/*
    else
        echo "==> Node.js already installed."
    fi
else
    echo "==> Warning: unsupported OS '$OSTYPE', skipping package installs."
fi

###### DUNE SANDBOX LAUNCHER ######
DUNE_BIN="$SCRIPT_DIR/dune/bin/dune"

if [ -f "$DUNE_BIN" ]; then
    echo "Configuring dune launcher..."
    chmod +x "$SCRIPT_DIR/dune/bin/"*
    mkdir -p "$HOME/.local/bin"
    ln -sf "$DUNE_BIN" "$HOME/.local/bin/dune"
    echo "Linked $DUNE_BIN -> ~/.local/bin/dune"
fi

# Initialize dune sandbox .env if not present
if [ ! -f "$SCRIPT_DIR/dune/sandboxes/mentat/.env" ]; then
    echo "Creating dune sandbox .env from template..."
    cp "$SCRIPT_DIR/dune/sandboxes/mentat/.env.example" "$SCRIPT_DIR/dune/sandboxes/mentat/.env"
    echo "Created dune/sandboxes/mentat/.env - edit to add API keys"
fi

###### CREATE SOFTLINKS ######
PROGRAMS=(nvim zsh ssh git kitty tmux lazygit)
OLD_DOTFILES="$SCRIPT_DIR/backups/dotfile_bk_$(date -u +"%Y%m%d%H%M%S")"

# Move $HOME/<path> into the backup dir, keeping its relative path
backup_path() {
    mkdir -p "$OLD_DOTFILES/$(dirname "$1")"
    mv "$HOME/$1" "$OLD_DOTFILES/$1"
    echo "  backed up ~/$1"
}

# Entries stow skips (--ignore below, stow defaults, package .stow-local-ignore)
stow_ignored() {
    case "$2" in
        README.*|LICENSE*|COPYING|.git|.gitignore|.gitmodules|.stow-local-ignore) return 0 ;;
    esac
    [ -f "$SCRIPT_DIR/$1/.stow-local-ignore" ] &&
        printf '%s\n' "$2" | grep -qxEf "$SCRIPT_DIR/$1/.stow-local-ignore"
}

# Back up everything in $HOME that stow would refuse to overwrite.
# Recurses only into real directories that both sides have.
backup_conflicts() {
    local pkg="$1" rel="$2" src name target
    for src in "$SCRIPT_DIR/$pkg/$rel".[!.]* "$SCRIPT_DIR/$pkg/$rel"*; do
        [ -e "$src" ] || continue
        name="${src##*/}"
        stow_ignored "$pkg" "$name" && continue
        target="$HOME/$rel$name"
        if [ "$target" -ef "$src" ]; then
            continue  # already linked to this repo
        elif [ -d "$src" ] && [ -d "$target" ] && [ ! -L "$target" ]; then
            backup_conflicts "$pkg" "$rel$name/"
        elif [ -e "$target" ] || [ -L "$target" ]; then
            backup_path "$rel$name"
        fi
    done
}

# ~/.gitconfig overrides ~/.config/git/config, so move it out of the way
[ -e "$HOME/.gitconfig" ] && backup_path ".gitconfig"
mkdir -p ~/.vim/undodir

if [ -d ~/.zprezto/runcoms ]; then
    for f in ~/.zprezto/runcoms/z*; do
        [ -e "$f" ] && backup_path ".zprezto/runcoms/${f##*/}"
    done
fi

for program in "${PROGRAMS[@]}"; do
    if [ -d "$program" ]; then
        echo "Configuring $program"
        backup_conflicts "$program" ""
        # keep ~/.ssh a real dir so keys/known_hosts never land in the repo
        FOLDING=()
        [ "$program" = "ssh" ] && FOLDING=(--no-folding)
        stow --ignore="README.*" ${FOLDING[@]+"${FOLDING[@]}"} -v --target="$HOME" "$program"
    fi
done
echo "Finished softlinking files!"

###### SSH PERMISSIONS ######
if [ -d "$HOME/.ssh" ]; then
    chmod 700 "$HOME/.ssh"
    for f in "$HOME/.ssh/config" "$HOME/.ssh/config.local"; do
        [ -f "$f" ] && chmod 600 "$f"
    done
    echo "Set permissions on ~/.ssh"
fi

###### MACHINE-LOCAL CONFIG ######
# Untracked *.local files hold private hosts/identity; templates sit next to them.
# setup_credentials.sh (gitignored, copied by hand) creates and links them.
if [ -f "$SCRIPT_DIR/setup_credentials.sh" ]; then
    echo "==> Running setup_credentials.sh..."
    DOTFILES="$SCRIPT_DIR" bash "$SCRIPT_DIR/setup_credentials.sh"
fi
while IFS= read -r example; do
    local_file="${example%.example}"
    [ -f "$local_file" ] || echo "  ! missing ${local_file#"$SCRIPT_DIR"/} (copy from ${example#"$SCRIPT_DIR"/} and fill in)"
done < <(find "$SCRIPT_DIR/ssh" "$SCRIPT_DIR/git" "$SCRIPT_DIR/zsh" -name '*.local.example' -not -path '*/.git/*')

###### VALIDATION ######
echo ""
echo "==> Validating setup..."
FAILED=0
for tool in nvim stow lazygit; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "  ✓ $tool found at $(command -v $tool)"
    else
        echo "  ✗ $tool not found!"
        FAILED=1
    fi
done

if [ -f "$HOME/.zshrc" ] && [ -L "$HOME/.zshrc" ]; then
    echo "  ✓ zshrc symlinked"
else
    echo "  ✗ zshrc not symlinked!"
    FAILED=1
fi

if [ -f "$HOME/.tmux.conf" ] && [ -L "$HOME/.tmux.conf" ]; then
    echo "  ✓ tmux.conf symlinked"
else
    echo "  ✗ tmux.conf not symlinked!"
    FAILED=1
fi

if [ $FAILED -eq 1 ]; then
    echo "==> Setup validation failed!"
    exit 1
else
    echo "==> All checks passed! Setup complete."
fi