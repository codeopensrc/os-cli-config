#!/bin/bash

CODE_DIR=$HOME/all/code
if [[ $USER == root ]]; then CODE_DIR=$HOME/code; fi

function bashr() {
    source $HOME/.bash_aliases
    source $HOME/.bash_profile
}
function bashp() {
    vim $HOME/.bash_profile
}
function basha() {
    vim $HOME/.bash_aliases
}
function code() {
    cd $CODE_DIR
}

function tmuxcolors() {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}mcolor%-5i\x1b[0m" $i ;
        if ! (( ($i + 1 ) % 8 )); then echo ; fi ; 
    done
}


#### WINDOWS WSL

##function vscode() {
##    "/mnt/c/Program Files (x86)/Microsoft VS Code/bin/code" $1
##}



#### DARWIN / OSX

##function showall() {
##    defaults write com.apple.finder AppleShowAllFiles
##}
##
##function bulkrename() {
##    echo "Check and modify aliases before using"
##    return
##
##    for f in *$2*
##    do
##        mv $f $(echo $f | sed "$1")
##    done
##}
