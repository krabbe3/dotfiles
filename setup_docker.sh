#/!usr/bin/env bash

# Dont link DS_Store files
find . -name ".DS_Store" -exec rm {} \;

###### INSTALL PACKAGES ######
# install nvim in the whole container
mkdir -p /opt
curl -L https://github.com/neovim/neovim-releases/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz -o /opt/nvim.tar.gz
mkdir -p /opt/nvim
tar xzvf /opt/nvim.tar.gz -C /opt/nvim --strip-components=1
rm /opt/nvim.tar.gz
ln -sf /opt/nvim/bin/nvim /bin/nvim

###### CREATE SOFTLINKS ######
PROGRAMS=(nvim zsh tmux)
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
