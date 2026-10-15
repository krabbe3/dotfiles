#!/usr/bin/env bash
set -euo pipefail

# Ensure we run from the dotfiles directory where this script lives
cd "$(dirname "$0")"

# Remove DS_Store files if present
find . -name ".DS_Store" -exec rm -f {} +

###### VERSION REQUIREMENTS ######
NVIM_TARGET="v0.11.5"

###### INSTALL PACKAGES ######
mkdir -p /opt
rm -rf /opt/nvim /usr/local/bin/nvim

echo "==> Downloading Neovim $NVIM_TARGET..."
curl -fsSL --retry 3 --retry-delay 2 "https://github.com/neovim/neovim-releases/releases/download/${NVIM_TARGET}/nvim-linux-x86_64.tar.gz" -o /opt/nvim.tar.gz
mkdir -p /opt/nvim
tar xzf /opt/nvim.tar.gz -C /opt/nvim --strip-components=1
rm -f /opt/nvim.tar.gz
ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

echo "==> Neovim installed: $(nvim --version | head -n 1 | awk '{print $2}')"

###### CREATE SOFTLINKS ######
PROGRAMS=(nvim zsh tmux)

for program in "${PROGRAMS[@]}"; do
    if [ -d "$program" ]; then
        stow --ignore="README.*" -v --target="$HOME" "$program"
        echo "Configured $program"
    else
        echo "Warning: dotfile directory '$program' not found, skipping."
    fi
done

echo "Finished softlinking files!"
