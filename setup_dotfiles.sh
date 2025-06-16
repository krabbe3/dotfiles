#!/usr/bin/env bash

# set -e          # Exit on error
# set -o pipefail # Exit on pipe error
# set -x          # Enable verbosity

# Dont link DS_Store files
find . -name ".DS_Store" -exec rm {} \;

# PROGRAMS=(nvim vim zsh ssh git)
PROGRAMS=(nvim zsh ssh git kitty tmux lazygit)
OLD_DOTFILES="backups/dotfile_bk_$(date -u +"%Y%m%d%H%M%S")"
mkdir $OLD_DOTFILES

function backup_if_exists() {
    if [ -f $1 ];
    then
      mv $1 $OLD_DOTFILES
    fi
    if [ -d $1 ];
    then
      mv $1 $OLD_DOTFILES
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

for program in ${PROGRAMS[@]}; do
  stow -v --target=$HOME $program
  echo "Configuring $program"
done
echo "Finished softlinking files!"

# ensure correct permissions on ssh config
if [ -f "$HOME/.ssh/config" ]; then
    chmod 600 "$HOME/.ssh/config"
    echo "Set permissions on ~/.ssh/config"
fi

# install nvim 0.10.4 from prebuild release into ~/.local/opt
if [ ! -d "$HOME/.local/opt/nvim" ]; then
    echo "Installing Neovim v0.10.4..."
    wget -P ~/.local/opt https://github.com/neovim/neovim-releases/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz
    tar xzvf ~/.local/opt/nvim-linux-x86_64.tar.gz -C ~/.local/opt/
    rm -rf ~/.local/opt/nvim-linux-x86_64.tar.gz
    mv ~/.local/opt/nvim-linux-x86_64 ~/.local/opt/nvim
    ln -fs ~/.local/opt/nvim/bin/nvim ~/.local/bin/nvim
    echo "Installed and symlinked nvim"
else
    echo "Neovim already installed at ~/.local/opt/nvim - skipping"
fi
