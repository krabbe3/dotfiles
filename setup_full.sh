#!/usr/bin/env bash
set -euo pipefail

# Dont link DS_Store files
find . -name ".DS_Store" -exec rm -f {} +

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
    brew install neovim stow lazygit tmux tmuxinator node rust docker docker-compose docker-buildx miniforge colima

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

    # Initialize conda for shell integration (required for dune python env passthrough)
    if ! grep -q "conda initialize" ~/.zshrc 2>/dev/null; then
        eval "$(/opt/homebrew/bin/conda shell.zsh hook)" || eval "$(brew --prefix miniforge)/bin/conda shell.zsh hook"
    fi

    # Pin neovim version to prevent updates
    brew pin neovim
    echo "==> Pinned neovim version: $(neovim --version | head -n 1 | awk '{print $2}')"

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

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "==> Linux detected. Using manual downloads..."
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
        curl -fsSL --retry 3 --retry-delay 2 "https://github.com/neovim/neovim-releases/releases/download/${NVIM_TARGET}/nvim-linux-x86_64.tar.gz" -o "$HOME/.local/opt/nvim.tar.gz"
        
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
        curl -fsSL --retry 3 --retry-delay 2 "https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_TARGET}/lazygit_${LAZYGIT_TARGET#v}_Linux_x86_64.tar.gz" -o "$HOME/.local/opt/lazygit.tar.gz"
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

    # install Node.js via nvm
    if ! command -v nvm >/dev/null 2>&1; then
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
fi

cd "$HOME/dotfiles"

###### DUNE SANDBOX LAUNCHER ######
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
PROGRAMS=(nvim zsh ssh git kitty tmux lazygit supernote)
OLD_DOTFILES="backups/dotfile_bk_$(date -u +"%Y%m%d%H%M%S")"

mkdir -p "$OLD_DOTFILES"
backup_if_exists() {
    if [ -e "$1" ]; then
        mv "$1" "$OLD_DOTFILES"
    fi
}

# Clean common conflicts
backup_if_exists ~/.bash_profile
backup_if_exists ~/.bashrc
backup_if_exists ~/.zshrc
backup_if_exists ~/.gitconfig
backup_if_exists ~/.tmux.conf
backup_if_exists ~/.profile
mkdir -p ~/.vim/undodir

if [ -d ~/.zprezto/runcoms ]; then
    for f in ~/.zprezto/runcoms/z*; do
        [ -e "$f" ] && mv "$f" "$OLD_DOTFILES"
    done
fi

for program in "${PROGRAMS[@]}"; do
    if [ -d "$program" ]; then
        stow --ignore="README.*" -v --target="$HOME" "$program"
        echo "Configuring $program"
    fi
done
echo "Finished softlinking files!"

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

###### SSH CONFIG CHMOD ######
if [ -f "$HOME/.ssh/config" ]; then
    chmod 600 "$HOME/.ssh/config"
    echo "Set permissions on ~/.ssh/config"
fi
