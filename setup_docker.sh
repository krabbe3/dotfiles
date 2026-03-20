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
for program in ${PROGRAMS[@]}; do
  stow -v --target=/home/node $program
  echo "Configuring $program"
done
echo "Finished softlinking files!"
