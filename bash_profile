export EDITOR=/usr/bin/vim
export PATH=$PATH:$HOME/.local/bin

if [ -f ~/.bashrc ]; then
    TERM=xterm-color
    . ~/.bashrc
    TERM=screen-256color
fi
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
