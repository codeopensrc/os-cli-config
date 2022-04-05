#!/bin/bash

export EDITOR=/usr/bin/vim
export GPG_TTY=$(tty)
export GOPATH=$HOME/.local/go

ADDED_PATHS=$HOME/.local/bin
ADDED_PATHS=$ADDED_PATHS:/usr/local/go/bin
ADDED_PATHS=$ADDED_PATHS:$GOPATH/bin

export PATH=$PATH:$ADDED_PATHS

if [ -f ~/.bash_profile2 ]; then 
    . ~/.bash_profile2
fi

if [ -f ~/.bash_secret ]; then 
    chmod 600 ~/.bash_secret
    . ~/.bash_secret
fi

if [ -f ~/.bashrc ]; then
    TERM=xterm-color
    . ~/.bashrc

    if [[ $(uname) == "Darwin" ]]; then
        alias ls="ls -G"
        LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:"

        CLICOLOR=1
        export CLICOLOR
    fi

    LS_COLORS=$LS_COLORS'ow=34;40';
    export LS_COLORS;

    if [[ $USER == "root" ]]; then
        ## Change username to red
        PS1=${PS1/01;32m\\]\\u/01;31m\\]\\u\\[\\033[01;32m\\]}
    fi

    if [[ $TMPUSER == "demo" ]]; then
        PS1=${PS1/01;32m\\]\\u@\\h/01;33m\\]demo\\[\\033[01;32m\\]}
    fi

    TERM=screen-256color
fi

## k8s autocompletion
if [[ -f $HOME/.local/bin/kubectl ]] || [[ -f /usr/local/bin/kubectl ]] || [[ -f /usr/bin/kubectl ]]; then
    source <(kubectl completion bash)
fi

## Both effectively do the same thing, disable default CTRL-s from freezing terminal output
stty -ixon
#stty stop ''; stty start '';



#### WINDOWS WSL
#
#export DOCKER_HOST=localhost:2375
##if [ -z "$SSH_AUTH_SOCK" ]; then
##   # Check for a currently running instance of the agent
##   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
##   if [ "$RUNNING_AGENT" = "0" ]; then
##        # Launch a new instance of the agent
##        ssh-agent -s &> .ssh/ssh-agent
##        ssh-add ~/.ssh/id_rsa
##   fi
##   eval `cat .ssh/ssh-agent`
##   if [ "$RUNNING_AGENT" = "0" ]; then ssh-add ~/.ssh/id_rsa; fi
##fi


#### LINUX -- Older

##source $HOME/code/secrets/tokens.sh
##source $HOME/code/secrets/lin-tokens.sh
##source $HOME/code/secrets/env.sh
##source $HOME/.bash_aliases
##export PATH="/opt/chefdk/embedded/bin:$PATH"



#### DARWIN / OSX

##source $HOME/code/secrets/tokens.sh
##source $HOME/code/secrets/osx-tokens.sh
##source $HOME/code/secrets/env.sh
##source $HOME/.bash_aliases
##
##BREW_PREFIX=`brew --prefix`
##
### Get rid of/alias to docker images soon
##export PATH=$PATH:/Applications/mongodb/bin
##export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.4/bin
##export PATH=$PATH:/Users/USER/Library/Android/sdk/platform-tools/
##
##export ANDROID_HOME=$HOME/Library/Android/sdk
###export ANDROID_HOME=/usr/local/opt/android-sdk
##export PYTHONPATH=$BREW_PREFIX/lib/python2.7/site-packages:$PYTHONPATH
##
##export CLICOLOR=1
##export LSCOLORS=gxFxCxDxBxegedabagaced
