#!/bin/bash

CLI_CONFIG_DIR=$HOME/all/code
if [[ $USER = "root" ]]; then CLI_CONFIG_DIR=$HOME/code; fi

git clone https://gitlab.codeopensrc.com/os/cli-config.git $CLI_CONFIG_DIR

bash $CLI_CONFIG_DIR/kc.sh load
bash $CLI_CONFIG_DIR/kc.sh link


## tpm for tmux
mkdir -p $HOME/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
$HOME/.tmux/plugins/tpm/bin/install_plugins

## vim-plug for vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -es -u vimrc -i NONE -c "PlugInstall" -c "qa"
