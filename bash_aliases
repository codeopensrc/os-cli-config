#!/bin/bash

function bashp() {
    vim $HOME/code/configs/$(uname)/bash_profile
}

function basha() {
    vim $HOME/code/configs/bash_aliases
}

function bashar() {
    source $HOME/.bash_aliases
}

function bashreset() {
    source $HOME/.bash_profile
}

function work() {
    cd $HOME/code/work
}

function loc() {
    cd $HOME/code/local
}

function mods() {
    cd $HOME/code/mods
}

function code() {
    cd $HOME/code
}

function showall() {
    defaults write com.apple.finder AppleShowAllFiles
}

function repo() {
	cd $(find $HOME/code -maxdepth 2 -iname $@ -type d -exec echo '{}' \;)
}

function rename() {
    echo "Check and modify aliases before using"
    return
	for f in *$2*
	do
		mv $f $(echo $f | sed "$1")
	done
}
