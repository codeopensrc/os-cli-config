#!/bin/bash

CODE_DIR=$HOME/all/code
if [[ $USER = "root" ]]; then CODE_DIR=$HOME/code; fi
CLI_CONFIG_DIR=$CODE_DIR/cli-config

git -C $CODE_DIR clone https://github.com/codeopensrc/os-cli-config.git $CLI_CONFIG_DIR

bash $CLI_CONFIG_DIR/kc.sh load
bash $CLI_CONFIG_DIR/kc.sh link

## tpm for tmux
mkdir -p $HOME/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
$HOME/.tmux/plugins/tpm/bin/install_plugins

## vim-plug for vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -es -u $HOME/.vimrc -i NONE -c "PlugInstall" -c "qa"
