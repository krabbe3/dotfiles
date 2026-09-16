#!/usr/bin/env bash
set -euo pipefail

# Dont link DS_Store files
find . -name ".DS_Store" -exec rm -f {} +

###### VERSION REQUIREMENTS ######
NVIM_TARGET="v0.11.5"

###### DIRECTORIES & PATH ######
mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"
export PATH="$HOME/.local/bin:$PATH"

###### INSTALL PACKAGES (LINUX / MAKALU) ######
if [[ "$(hostname -s)" =~ ^makalu[0-9]+$ ]]; then
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
        curl -fsSL "https://github.com/neovim/neovim-releases/releases/download/${NVIM_TARGET}/nvim-linux-x86_64.tar.gz" -o "$HOME/.local/opt/nvim.tar.gz"
        
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
        curl -fsSL https://github.com/jesseduffield/lazygit/releases/download/v0.53.0/lazygit_0.53.0_Linux_x86_64.tar.gz -o "$HOME/.local/opt/lazygit.tar.gz"
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
        curl -fsSL https://ftp.gnu.org/gnu/stow/stow-latest.tar.gz -o "$HOME/.local/opt/stow.tar.gz"
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
        stow -v --target="$HOME" "$program"
        echo "Configuring $program"
    fi
done
echo "Finished softlinking files!"

###### SSH CONFIG CHMOD ######
if [ -f "$HOME/.ssh/config" ]; then
    chmod 600 "$HOME/.ssh/config"
    echo "Set permissions on ~/.ssh/config"
fi
