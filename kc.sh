#!/bin/bash

INITIALIFS=$IFS;
if [[ $(uname) == "Darwin" ]]; then
    CLI_CONFIG_DIR=$( cd "$(dirname "$0")" ; pwd -P )
    if [[ -n $(which realpath) ]]; then
        ABS_SCRIPT_PATH=$(realpath $0)
    else
        ABS_SCRIPT_PATH=$CLI_CONFIG_DIR/kc.sh
    fi
else
    CLI_CONFIG_DIR=$(dirname $(readlink -f $0))
    ABS_SCRIPT_PATH=$(readlink -f $0)
fi

REVIEW_THIS() {
    printf "Attempted: $1\n"
    printf "This function needs to be reviewed again before use\n";
    exit
}

if [ "$1" = "load" ]; then
    if [[ $USER == "root" ]]; then
        if [[ ! -f "/usr/local/bin/kc" ]]; then
            ln -s $ABS_SCRIPT_PATH /usr/local/bin/kc
            chmod +x /usr/local/bin/kc
        fi
        echo "Loaded";
        exit
    fi

    mkdir -p $HOME/.local/bin
    if [[ ! -f "$HOME/.local/bin/kc" ]]; then
        echo "Not Found in $HOME/.local/bin"
        rm "$HOME/.local/bin/kc" ## Dangling links count as not found - rm in case
        ln -s $ABS_SCRIPT_PATH $HOME/.local/bin/kc
        chmod +x ~/.local/bin/kc
        echo "Linked $HOME/.local/bin/kc to $ABS_SCRIPT_PATH"
    fi

    if [[ ! $PATH =~ .*$HOME/\.local/bin.* ]]; then
        printf "\$HOME/.local/bin not in \$PATH \nCurrent \$PATH=$PATH \n"
        sed -i --follow-symlinks "1i export PATH=\$PATH:\$HOME\/.local\/bin" $HOME/.bash_profile
        printf "Added 'export PATH=\$PATH:\$HOME/.local/bin' to $HOME/.bash_profile\n"
        printf "Source the file by entering 'source \$HOME/.bash_profile'\n"
        exit
    fi;
    echo "Loaded";
    exit;
fi

if [ "$1" = "link" ]; then

    LN_OPTS="-sb"
    if [[ $(uname) == "Darwin" ]]; then LN_OPTS="-s"; fi

    (cd $HOME &&
    ln $LN_OPTS $CLI_CONFIG_DIR/bash_profile .bash_profile &&
    ln $LN_OPTS $CLI_CONFIG_DIR/vimrc .vimrc &&
    ln $LN_OPTS $CLI_CONFIG_DIR/bash_aliases .bash_aliases &&
    ln $LN_OPTS $CLI_CONFIG_DIR/tmux.conf .tmux.conf &&
    mkdir -p $CLI_CONFIG_DIR/backups &&
    mv .*~ $CLI_CONFIG_DIR/backups)
    echo "Linked dotfiles and backed up originals to $CLI_CONFIG_DIR/backups"
    exit;
fi

if [ "$1" = "rmlinks" ]; then
    FILES=(.vimrc .bash_aliases .bash_profile .tmux.conf)
    printf "Are you sure you want to rm the following links/files in $HOME?\n"
    printf "%s " "${FILES[@]}"
    printf "\n[y/n]: "
    read YN
    if [[ $YN == "y" ]] || [[ $YN == "Y" ]]; then
        printf "%s " "Removing files: ${FILES[@]}"
        printf "\n"
        (cd $HOME && rm ${FILES[@]})
    fi
    exit;
fi

if [ "$1" = "config" ]; then
    if [[ $2 = "atom" ]]; then atom $CLI_CONFIG_DIR ;
    else vim $CLI_CONFIG_DIR/kc.sh ; fi
    exit;
fi

if [ "$1" = "curl" ]; then
    shift;
    curl --limit-rate 2M "$@" -C -
    exit;

    # TODO: Download a sample 5M file, get average/max, then use that as base %.
    # Download at configurable speed - default 75%. Trying not to use full download bandwidth
    # BONUS: Detect remote filesize to download, if less than 20-30 just download really quick
    #wget -O /dev/null -q --show-progress
fi

if [ "$1" = "linkmod" ]; then
    REVIEW_THIS $1

    rm -rf ./node_modules/$2
    ln -s ~/code/mods/$2 ./node_modules/$2
    exit;
fi

if [ "$1" = "sync" ]; then
    # if [ "$3" = "main" ] ; then DIRECTION="$2 $MAIN:$4" ; fi
    #
    # if [ "$2" = "main" ] ; then DIRECTION="$MAIN:$3 $4" ; fi
    # rsync -avuz -e ssh $DIRECTION
    exit;
fi

if [ "$1" = "ss" ] ; then shift 1; python -m SimpleHTTPServer $@; exit; fi

if [ "$1" = "start" ]; then
    REVIEW_THIS $1

    if [ "$2" = "vpn" ] ; then sudo openvpn --config $HOME/code/vpn/no-route.ovpn; fi
    if [ "$2" = "route" ] ; then sudo openvpn --config $HOME/code/vpn/route.ovpn; fi # --mute-replay-warnings
    if [ "$2" = "consul" ] ; then
        docker run -d --name=dev-consul --net=host -e CONSUL_BIND_INTERFACE=docker0 -e 'CONSUL_LOCAL_CONFIG={"enable_script_checks": true}' consul;
    fi
    exit;
fi

############# SSH STUFF ##########
############# SSH STUFF ##########

if [[ "$1" = "sshconfig" ]]; then
    REVIEW_THIS $1

    ## General Idea
    # Edit your own sshconfig file so when sshing into a remote
    #  machine and (we're assuming tmux available) start a new tmux
    #  session with your local tmux conf that will use your local
    #  .vimrc file to edit files

    # Philosphy being you cant always have your own tmux/vimrc file on the
    #  the remote computer youre accessing (general purpose `deploy` user)

    ### This copys your vimrc remotely but good starter reference
    #Host *
    #   PermitLocalCommand yes
    #   LocalCommand bash -c 'scp -P %p %d/.vimrc %u@%n: &>/dev/null &'
fi


if [[ "$1" = "ssh" ]]; then
    REVIEW_THIS $1
    ## See sshconfig but just for one ssh connection
fi


# if [ "$1" = "git" ] ; then shift 1; ssh $GITMAIN $@; exit; fi
if [ "$1" = "main" ] ; then shift 1; ssh $MAIN $@; exit; fi
if [ "$1" = "vpn" ] ; then shift 1; ssh $VPNSERVER $@; exit; fi

### TODO: List keys and be able to choose from them by number
if [[ $1 = "getkey" ]]; then cat $HOME/.ssh/id_rsa.pub; fi
if [[ $1 = "getgpg" ]]; then gpg --export -a $GPGKEY ; fi

if [[ $1 = "copykey" ]]; then
    REVIEW_THIS $1

    REMOTE=""
    if [[ -z $2 ]] ; then echo "Specifiy location to copy key to {git|main}."; exit ; fi
    # if [ "$2" = "git" ] ; then echo "addkey $(cat ~/.ssh/id_rsa.pub)" | ssh $GITMAIN; exit; fi
    if [ "$2" = "main" ] ; then REMOTE="ssh $MAIN" ; fi
    if [ -z "$REMOTE" ] ; then REMOTE="ssh $2" ; fi
    cat $HOME/.ssh/id_rsa.pub | $REMOTE "cat >> ~/.ssh/authorized_keys"
    exit;
fi

if [[ $1 = "tunnel" ]]; then
    REVIEW_THIS $1

    if [[ $2 = "from" ]]; then
        # kc tunnel from kc@111.111.111.111 into localhost:22 from port 33
        ssh -R $8:$5 $3 -N
        exit
    fi

    if [[ $2 = "to" ]]; then
        # kc tunnel to 222.222.222.222 using port 8500 user kc
        ssh -L 3333:172.17.0.1:$6 $8@$3 -N
        exit
    fi
fi
############# END SSH STUFF ##########
############# END SSH STUFF ##########

############# GIT STUFF ##########
############# GIT STUFF ##########

if [[ "$1" = "gitconfig" ]]; then

    if [[ -f "$HOME/.gitconfig" ]]; then

        echo -n "Previous $HOME/.gitconfig found, OVERWRITE? (y/n): "
        read -n 1 OVERWRITE_GITCONFIG 
        echo
        if [ "$OVERWRITE_GITCONFIG" != y ]; then exit 0 ; fi

        echo "Saving existing $HOME/.gitconfig to $HOME/.gitconfig.bak"
        cp --backup=numbered $HOME/.gitconfig $HOME/.gitconfig.bak
    fi

    GPGSIGN="false"
    GPGSTRING="#signingkey = ''"
    if [[ -n $GPGKEY ]]; then GPGSIGN="true"; fi
    if [[ -n $GPGKEY ]]; then GPGSTRING="signingkey = $GPGKEY"; fi

    echo -n "git config --global user.name: "
    read GIT_USERNAME 
    echo -n "git config --global user.email: "
    read GIT_EMAIL

    cat <<-EOF > $HOME/.gitconfig
	[user]
	    email = $GIT_EMAIL
	    name = $GIT_USERNAME
	    $GPGSTRING
	[commit]
	    gpgsign = $GPGSIGN
	[credential]
	    helper = store
	[alias]
	    pretty = log --format='%C(auto)%h%d %cd - %s' --date=short
	    mmwps = push -o merge_request.create -o merge_request.target=master -o merge_request.merge_when_pipeline_succeeds
	    dmwps = push -o merge_request.create -o merge_request.target=dev -o merge_request.merge_when_pipeline_succeeds
	EOF

fi


if [ "$1" = "clone" ]; then
    REVIEW_THIS $1

    if [ ! "$2" = "main" ]; then
        echo "Please specify 'main' as 2nd arg"; exit;
    fi
    # if [ "$2" = "main" ] ; then URL=$GITMAIN:$3.git ; fi

    if [[ -z $URL ]]; then printf "Incorrect option\n"; exit; fi;

    FOLDER=$4
    if [ -z "$FOLDER" ] ; then FOLDER=$3 ; fi
    git clone $URL $FOLDER
    exit;
fi

if [ "$1" = "initrepo" ]; then
    REVIEW_THIS $1

    if [ ! "$2" = "main" ] ; then echo "Please specify 'main' as 2nd arg" ; exit; fi
    git init
    git add -A && git commit -m "Init"
    $0 pushrepo $2 $3
    exit;
fi

if [ "$1" = "pushrepo" ]; then
    REVIEW_THIS $1

    REPO=${PWD##*/}
    REPONAME=$3
    if [ ! "$2" = "main" ] ; then echo "Please specify 'main' as 2nd arg" ; exit; fi

    if [ -z "$REPONAME" ] ; then REPONAME=$REPO ; fi
    # if [ "$2" = "main" ] ; then URL=$GITMAIN: LOC=/home/git; fi

    $0 $2 "mkdir $LOC/$REPONAME.git && cd $LOC/$REPONAME.git && git --bare init"
    git remote add origin $URL$REPONAME.git
    if [ $? -ne 0 ] ; then $0 seturl $2 $REPONAME ; fi
    git push origin master
    echo ""
    echo "== New repo available: $REPONAME.git =="
    echo ""
    echo "== Provide below command to clone repo: =="
    echo "   git clone $URL$REPONAME.git"
    echo ""
    exit;
fi

if [ "$1" = "tag" ]; then
    CURVER=$(git describe --abbrev=0 --tags)
    PATCH=$(echo $CURVER | cut -d "." -f 3)
    MINOR=$(echo $CURVER | cut -d "." -f 2)
    MAJOR=$(echo $CURVER | cut -d "." -f 1 | sed  "s/v//g")

    case $2 in
        patch) PATCH=$(echo $PATCH + 1 | bc)
        ;;
        minor) MINOR=$(echo $MINOR + 1 | bc); PATCH=0
        ;;
        major) MAJOR=$(echo $MAJOR + 1 | bc); MINOR=0; PATCH=0;
        ;;
        *) echo $CURVER
    esac

    if [ -z "$2" ]; then exit ; fi
    echo -n "Tag as $MAJOR.$MINOR.$PATCH ? (y/n): "
    read YN
    if [ "$YN" = y ]; then git tag $MAJOR.$MINOR.$PATCH ; fi
    exit;
fi


if [ "$1" = "diff" ]; then
    #TODO: Use our current branch name, try to match with remote 
    if [ "$2" = "origin" ] ; then git diff master..origin/master ;
    elif [ "$2" = "local" ] ; then git diff origin/master..master ;
    else git diff ; fi
    exit;
fi

if [ "$1" = "seturl" ]; then
    REVIEW_THIS $1

    REPONAME=$3
    if [[ -z $REPONAME ]] ; then REPONAME=${PWD##*/} ; fi
    if [ "$2" = "origin" ] ; then git remote set-url origin $KC/$REPONAME.git ; fi
    exit;
fi

if [ "$1" = "fetch" ]; then
    REVIEW_THIS $1

    SEDSTART="Untracked|Changes|behind|ahead"
    SEDEND="no changes|nothing added|nothing to"

    DIRS_TO_CHECK=( $HOME/code/work/* $HOME/code/local/* $HOME/code/mods/* \
        $HOME/code/configs $HOME/code/scripts $HOME/code/install $HOME/code/cron )

    for dir in "${DIRS_TO_CHECK[@]}" ; do
        for f in "$dir" ; do
            echo "============= $f =============="
            (cd $f && git branch --set-upstream-to origin/master)>/dev/null 2>&1
            (cd $f && git fetch && git status) 2>&1 | sed -En "/$SEDSTART/,/$SEDEND/p" | sed -E "/use|nothing|^$/c\\"
        done
    done
    exit;
fi

if [ "$1" = "repos" ]; then
    REVIEW_THIS $1

    echo "======== Main Repos ========"
    $0 main "cd git && ls -l"
    exit;
fi
############# END GIT STUFF ##########
############# END GIT STUFF ##########

############# DOCKER STUFF ##########
############# DOCKER STUFF ##########
if [ "$1" = "mk" ]; then
    shift;
    eval $(minikube docker-env)
    if [[ "$1" = "build" ]]; then docker-compose build; exit; fi
    if [[ "$1" = "prune" ]]; then docker image prune; exit; fi
    if [[ "$1" = "ls" ]]; then docker images; exit; fi
    exit
fi

if [ "$1" = "rmi" ]; then
    shift;
    while getopts "i:b:fa" flag; do
        # These become set during 'getopts'  --- $OPTIND $OPTARG
        case "$flag" in
            i) IMAGE=$OPTARG;;
            a) ALL=true;;
            b) BEFORE=$OPTARG;;
            f) FORCE="-f";;
        esac
    done
    if [[ -z $IMAGE ]]; then echo "Please provide an image name using -i flag"; exit; fi
    if [[ -z $BEFORE ]] && [[ -z $ALL ]]; then echo "Please provide a reference image id to retrieve images created before id using -b or -a for ALL images. Applys only to images matching -i filter"; exit; fi

    if [[ -n $BEFORE ]]; then
        docker images -f "reference=$IMAGE" -f "before=$BEFORE"
    elif [[ -n $ALL ]]; then
        docker images -f "reference=$IMAGE"
    fi

    echo -n "Remove the above images? [Y/N]: "
    read ANSWER
    if [[ $ANSWER = "y" ]] || [[ $ANSWER = "Y" ]]; then

        if [[ -n $BEFORE ]]; then
            docker rmi $(docker images -f "reference=$IMAGE" -f "before=$BEFORE" -q) $FORCE
        elif [[ -n $ALL ]]; then
            docker rmi $(docker images -f "reference=$IMAGE" -q) $FORCE
        fi

    fi
    exit;
fi

if [[ $1 = "registry" ]]; then
    REVIEW_THIS $1

    az acr repository list -n $2 -o json
    exit;
fi

if [[ $1 = "dlogin" ]]; then
    REVIEW_THIS $1

    CMD="docker login $REGISTRY_NAME -u $REGISTRY_APP_ID -p $REGISTRY_PW"
    if [[ -z $2 ]]; then $CMD;
    else echo "$CMD" | docker-machine ssh $2; fi
    exit;
fi

if [[ $1 = "dpush" ]]; then
    REVIEW_THIS $1

    if [[ -z $2 ]]; then echo "Please specify image name" exit; fi
    docker push $REGISTRY_NAME/$2
    exit;
fi

if [[ $1 = "dswarm" ]]; then
    REVIEW_THIS $1

    if [[ $2 = "reset" ]]; then
        echo  export DOCKER_TLS_VERIFY=""
        echo  export DOCKER_HOST=""
        echo  export DOCKER_CERT_PATH=""
        echo  export DOCKER_MACHINE_NAME=""
    fi
    exit;
fi

if [[ $1 = "stack" ]]; then
    REVIEW_THIS $1

    #TODO: Check for docker-compose file if this is ever really "published" formally
    STACKNAME=$(docker-compose -f docker-compose.yml config | grep 'image.*/' | tail -1 | cut -d ":" -f 2 | cut -d "/" -f 2 | awk '{$1=$1};1')
    shift;
    while getopts "m:n:" flag; do
        # These become set during 'getopts'  --- $OPTIND $OPTARG
        case "$flag" in
            m) MACHINE=$OPTARG;;
            n) STACKNAME=$OPTARG;;
        esac
    done
    if [[ -z $MACHINE ]]; then echo "Please provide a machine with the -m flag"; exit; fi
    if [[ -z $STACKNAME ]]; then STACKNAME="default"; fi
    eval $(docker-machine env $MACHINE)
    docker stack deploy --compose-file docker-compose.yml $STACKNAME --with-registry-auth
    exit;
fi

if [[ $1 = "dmachine" ]]; then
    REVIEW_THIS $1

    if [[ -z $2 ]]; then echo "Please enter machine name"; exit; fi
    docker-machine create --driver digitalocean \
    --digitalocean-access-token=$DO_DOCKER_MACHINE_TOKEN \
    --digitalocean-ssh-key-fingerprint=$DO_FINGERPRINT \
    $2;
    IP=$(docker-machine ip $2)
    COMMAND="echo \"$IP $IP $2\" >> /etc/hosts; sed -i 's/$2.localdomain/$IP/' /etc/hosts; sudo reboot now;"
    echo $COMMAND | docker-machine ssh $2
    exit;
    # --azure-ssh-user ops \
    # --azure-subscription-id $AZURE_SUB_ID \
    # --azure-open-port 80 \
fi

if [[ $1 = "attach" ]]; then
    REVIEW_THIS $1

    shift;
    while getopts "i:m:" flag; do
        # These become set during 'getopts'  --- $OPTIND $OPTARG
        case "$flag" in
            i) IP=$OPTARG;;
            m) MACHINE=$OPTARG;;
        esac
    done

    if [[ -z $IP ]]; then echo "Please enter machine IP"; exit; fi
    if [[ -z $MACHINE ]]; then echo "Please provide name of machine node"; exit; fi

    docker-machine rm $MACHINE

    docker-machine create --driver generic --generic-ip-address=$IP \
    --generic-ssh-key ~/.ssh/id_rsa $MACHINE
fi

if [[ $1 = "swarm" ]]; then
    REVIEW_THIS $1

    if [[ $2 = "init" ]]; then

        shift; shift;
        while getopts "f:l:" flag; do
            # These become set during 'getopts'  --- $OPTIND $OPTARG
            case "$flag" in
                f) FOLLOWERS=$OPTARG;;
                l) LEADER=$OPTARG;;
            esac
        done

        if [[ -z $FOLLOWERS ]] || [[ -z $LEADER ]]; then exit; fi

        ADVT_IP=$(docker-machine ip $LEADER)":2377"
        IFS=","; read -ra FOLLOWERS <<< "$FOLLOWERS"; IFS=$INITIALIFS;
        TOKEN=$(docker-machine ssh $LEADER "docker swarm init --advertise-addr $ADVT_IP | grep -- --token;")

        for follower in "${FOLLOWERS[@]}" ; do
            docker-machine ssh $follower "set -e; docker swarm join \\
                $TOKEN
                $ADVT_IP";
        done
        exit
    fi

    if [[ $2 = "join" ]]; then

        shift; shift;
        while getopts "f:l:" flag; do
            # These become set during 'getopts'  --- $OPTIND $OPTARG
            case "$flag" in
                f) FOLLOWERS=$OPTARG;;
                l) LEADER=$OPTARG;;
            esac
        done

        if [[ -z $FOLLOWERS ]] || [[ -z $LEADER ]]; then exit; fi

        ADVT_IP=$(docker-machine ip $LEADER)":2377"
        IFS=","; read -ra FOLLOWERS <<< "$FOLLOWERS"; IFS=$INITIALIFS;
        TOKEN=$(docker-machine ssh $LEADER "docker swarm join-token worker | grep -- --token;")
        # TOKEN=$(docker-machine ssh $LEADER "docker swarm init --advertise-addr $ADVT_IP | grep -- --token;")

        for follower in "${FOLLOWERS[@]}" ; do
            docker-machine ssh $follower "set -e; docker swarm join \\
                $TOKEN
                $ADVT_IP";
        done
        exit
    fi
    exit;
fi
############# END DOCKER STUFF ##########
############# END DOCKER STUFF ##########

############# CHEF STUFF ##########
############# CHEF STUFF ##########

if [[ $1 = "chef" ]]; then
    REVIEW_THIS $1

    if [[ $2 = "server" ]]; then
        wget "https://packages.chef.io/files/stable/chef-server/12.15.0/ubuntu/14.04/chef-server-core_12.15.0-1_amd64.deb"
        exit;
    fi

    if [[ $2 = "bootstrap" ]]; then
        IP=$(docker-machine ip $3)
        if [[ $5 =  "azure" ]]; then
            knife bootstrap $IP --ssh-user $AZURE_SSH_USER --sudo --identity-file ~/.ssh/id_rsa --node-name $3 --run-list $4 \
                --json-attributes '{"cloud": {"public_ip": "$IP"}}'
        else
            knife bootstrap $IP --sudo --identity-file ~/.ssh/id_rsa --node-name $3 --run-list $4
        fi
        exit;
    fi

    if [[ $2 = "ssh" ]]; then
        if [[ $3 = "azure" ]]; then
            knife ssh $5 $4 --identity-file ~/.ssh/id_rsa -x $AZURE_SSH_USER \
            --attribute cloud.public_ip
        elif [[ $3 = "aws" ]]; then
            knife ssh $5 $4 --identity-file ~/.ssh/id_rsa -x root --attribute cloud.public_ipv4
        else
            knife ssh $4 $3 --identity-file ~/.ssh/id_rsa -x root -a ipaddress
        fi

        exit
    fi

    if [[ $2 = "del" ]]; then
        if [[ -z $3 ]]; then echo "Please specify a chef node"; exit; fi
        knife node delete $3 -y
        knife client delete $3 -y
        docker-machine ssh $3 'sudo rm /etc/chef/client.pem'
        exit;
    fi

    if [[ $2 = "delall" ]]; then
        MACHINES=($(docker-machine ls | grep -v 'NAME' | awk '{ print $1 }'))
        for machine in ${MACHINES[@]}; do
            $0 chef del $machine
        done
        exit;
    fi

    # .docker\machine\machines\MACHINE_NAME\id_rsa
    # https://docs.chef.io/attributes.html
    # node['hostname']
    # node['ipaddress']
    # node['domain']

    exit;
fi

############# END CHEF STUFF ##########
############# END CHEF STUFF ##########


if [[ $1 = "deploysingle" ]]; then
    REVIEW_THIS $1

    shift;
    while getopts "m:" flag; do
        # These become set during 'getopts'  --- $OPTIND $OPTARG
        case "$flag" in
            m) MACHINE=$OPTARG;;
        esac
    done

    if [[ -z $MACHINE ]]; then echo "Please provide a docker machine"; exit ; fi
    REPO=${PWD##*/}
    IP=$(docker-machine ip $MACHINE)

    rsync -avuz --exclude=".git" --exclude="node_modules" --exclude="server/output" --exclude="tempdbdump" . root@$IP:~/$REPO
    exit;
fi


if [[ $1 = "build" ]]; then
    REVIEW_THIS $1

    shift;
    while getopts "m:r:" flag; do
        # These become set during 'getopts'  --- $OPTIND $OPTARG
        case "$flag" in
            r) REGISTRY=$OPTARG;;
            m) MACHINE=$OPTARG;;
        esac
    done

    if [[ -z $MACHINE ]]; then echo "Please provide a docker machine using the -m flag"; exit ; fi
    if [[ -z $REGISTRY ]]; then echo "Please provide which credentials should be used using the -r flag [hub]"; exit ; fi
    if [[ $REGISTRY = 'hub' ]]; then CREDS="-u $DOCKER_HUB_USER -p $DOCKER_HUB_PW" ; fi

    LOGIN="docker login $CREDS";
    REPO=${PWD##*/}
    IMAGE=$(docker-compose -f docker-compose.yml config | grep 'image.*/' | tail -1 | cut -d ":" -f 2 | awk '{$1=$1};1')
    VER=$(docker-compose -f docker-compose.yml config | grep 'image.*/' | tail -1 | cut -d ":" -f 3 | awk '{$1=$1};1')
    CMD="cd ~/builds/$REPO; docker-compose build main; docker tag $IMAGE:$VER $IMAGE:latest;"
    CMD="$CMD $LOGIN; docker-compose push main; docker push $IMAGE:latest;"
    CMD="$CMD docker rmi \$(docker images -f 'dangling=true' -q);"
    IP=$(docker-machine ip $MACHINE)

    # rsync -avuz --exclude=".git" --exclude="node_modules" --exclude="tempdbdump" . root@$IP:~/builds/$REPO
    rsync -avuz --exclude=".git" --exclude="node_modules" --exclude="server/output/*" --exclude="tempdbdump" . root@$IP:~/builds/$REPO
    ssh root@$IP $CMD
    exit;
fi

if [[ $1 = "push" ]]; then
    REVIEW_THIS $1

    shift;
    while getopts "ta" flag; do
        # These become set during 'getopts'  --- $OPTIND $OPTARG
        case "$flag" in
            t) TAG_AS_LATEST=true;;
            a) AWS=true;;
        esac
    done

    REPO=${PWD##*/}
    IMAGE=$(docker-compose -f docker-compose.yml config | grep 'image.*/*[0-9]' | tail -1 | cut -d ":" -f 2 | awk '{$1=$1};1')
    VER=$(docker-compose -f docker-compose.yml config | grep 'image.*/*[0-9]' | tail -1 | cut -d ":" -f 3 | awk '{$1=$1};1')

    docker-compose build main
    docker-compose push main
    if [[ $TAG_AS_LATEST = "true" ]]; then
        docker tag $IMAGE:$VER $IMAGE:latest;
        docker push $IMAGE:latest;
    fi

    # Before we push to AWS again, we have to cut out project path
    # Before it was DOMAIN/image:ver, now its registry.*/owner/image:ver
    if [[ $AWS = "true" ]]; then
        #source $HOME/code/local/misc-secrets/variables.sh
        LOGIN=$(aws --profile default ecr get-login --no-include-email --region us-east-2)
        $LOGIN

        AWS_ECR_NUM="000000000"
        AWS_ECR_REGION="us-east-2"
        # Tag and push to amazon as well
        docker tag $IMAGE:$VER ${AWS_ECR_NUM}.dkr.ecr.${AWS_ECR_REGION}.amazonaws.com/$IMAGE:$VER;
        docker push ${AWS_ECR_NUM}.dkr.ecr.${AWS_ECR_REGION}.amazonaws.com/$IMAGE:$VER;
        docker tag $IMAGE:$VER ${AWS_ECR_NUM}.dkr.ecr.${AWS_ECR_REGION}.amazonaws.com/$IMAGE:latest;
        docker push ${AWS_ECR_NUM}.dkr.ecr.${AWS_ECR_REGION}.amazonaws.com/$IMAGE:latest;
    fi
    # CMD="$CMD docker rmi \$(docker images -f 'dangling=true' -q);"
    exit;
fi

if [[ $1 = "watch" ]]; then
    SERVICE_NAME=${PWD##*/}_dev_1
    SERVICE_NAME=${SERVICE_NAME//./}
    docker exec $SERVICE_NAME npm run watch
    exit;
fi

if [[ $1 = "exec" ]]; then
    SERVICE_NAME=${PWD##*/}_dev_1
    SERVICE_NAME=${SERVICE_NAME//./}
    docker exec -it $SERVICE_NAME bash
    exit;
fi

if [[ $1 = "pg" ]] || [[ $1 = "mongo" ]] || [[ $1 = "redis" ]]; then
    DB_TYPE=$1
    MONGO_IMAGE="mongo"
    PG_IMAGE="postgres:9.5"
    REDIS_IMAGE="redis:4.0.2"

    if [[ $2 = "dump" ]] || [[ $2 = "import" ]]; then
        CMD=$2
        if [[ $DB_TYPE = "mongo" ]]; then DB="mongo"; IMAGE=$MONGO_IMAGE; fi
        if [[ $DB_TYPE = "pg" ]]; then DB="pg"; IMAGE=$PG_IMAGE; fi
        if [[ $DB_TYPE = "redis" ]]; then DB="redis"; IMAGE=$REDIS_IMAGE; fi

        shift; shift;
        while getopts "cd:h:f:t:" flag; do
            # These become set during 'getopts'  --- $OPTIND $OPTARG
            case "$flag" in
                c) CREATE_DB=true;;
                d) DB_NAME=$OPTARG;;
                f) DUMP_FILE=$OPTARG;;
                h) HOST=$OPTARG;;
                t) TABLES=$OPTARG;;
            esac
        done

        if [[ -z $HOST ]] || [[ -z $DB_NAME ]]; then
            echo "Please specify a host and database using -h and -d flags"; exit;
        fi

        if [[ ! -z $TABLES ]]; then
            IFS=","; read -ra TABLEARR <<< "$TABLES"; IFS=$INITIALIFS;
            for table in "${TABLEARR[@]}" ; do
                TABLESTR="$TABLESTR -t $table"
            done
        fi

        if [[ $CMD = "import" ]] && [[ -z $DUMP_FILE ]]; then
            echo "Please specify a dump file using -f flag";
            echo "Note: File must be inside of a directory 'tempdbdump' inside current directory"
            exit;
        fi
        if [[ $CMD = "import" ]]; then FILENAME=$(basename $DUMP_FILE); fi
        if [[ $CMD = "dump" ]]; then mkdir tempdbdump; fi

        NETWORK=$DB_TYPE"0"
        if [[ $CMD = "dump" ]]; then
            DOCKER="docker run -v $PWD/tempdbdump:/dumps --name backup_$DB \
                -u=$(id -u $(whoami)) --network $NETWORK --rm $IMAGE bash -c"

            if [[ $DB_TYPE = "mongo" ]]; then
                RUN_CMD="mongodump --host $HOST --db $DB_NAME --out /dumps/"
            fi

            if [[ $DB_TYPE = "pg" ]]; then
                RUN_CMD="pg_dump -h $HOST -d $DB_NAME -U postgres $TABLESTR | gzip > /dumps/$DB_NAME.gz"
            fi

            if [[ $DB_TYPE = "redis" ]]; then
                RUN_CMD="redis-cli -h $HOST save && redis-cli -h $HOST --rdb /dumps/$DB_NAME.rdb"
            fi
        fi

        if [[ $CMD = "import" ]]; then
            DOCKER="docker run -v $PWD/tempdbdump:/dumps --name backup_$DB \
                 --network $NETWORK --rm $IMAGE bash -c"

                if [[ $DB_TYPE = "mongo" ]]; then
                    RUN_CMD="mongorestore --host $HOST --db $DB_NAME /dumps/$FILENAME/"
                fi

                if [[ $DB_TYPE = "pg" ]]; then
                    RUN_CMD="gunzip -c /dumps/$FILENAME | psql -h $HOST -d $DB_NAME -U postgres"
                    if [[ $CREATE_DB ]]; then RUN_CMD="createdb -h $HOST -U postgres $DB_NAME; $RUN_CMD"; fi
                    # exit
                fi

                if [[ $DB_TYPE = "redis" ]]; then
                    docker run -v $PWD/tempdbdump/$FILENAME:/data/dump.rdb \
                        -d --rm --name backup_$DB --network $NETWORK $IMAGE redis-server

                    docker exec backup_$DB bash -c "redis-cli --raw KEYS '*' | xargs redis-cli MIGRATE $HOST 6379 '' 0 5000 COPY KEYS";
                    echo 'redis-cli --raw KEYS "*" | xargs redis-cli MIGRATE $HOST 6379 "" 0 5000 COPY KEYS'
                    docker stop backup_$DB;
                    exit;
                fi
        fi
        $DOCKER "$RUN_CMD"
        exit;
    fi

    if [[ $2 = "start" ]]; then
        VOLUME=$(docker volume inspect temp_"$DB_TYPE")
        CONTAINER=$(docker inspect "$DB_TYPE"_server)

        if [[ ! $CONTAINER = '[]' ]]; then
            echo "$DB_TYPE"_server "container already exists, starting.";
            docker start "$DB_TYPE"_server
            exit;
        fi

        if [[ $VOLUME = '[]' ]]; then
            echo "Creating blank volume"
            docker volume create --name temp_$DB_TYPE
        fi

        if [[ $DB_TYPE = "pg" ]]; then
            docker run -v temp_"$DB_TYPE":/var/lib/postgresql/data --network pg0 -d -p 172.17.0.1:5432:5432 \
            --name "$DB_TYPE"_server $PG_IMAGE
        fi

        if [[ $DB_TYPE = "mongo" ]]; then
            ## Minikube cant connect to the docker bridge ip 172.17.0.1
            docker run -v temp_"$DB_TYPE":/data/db --network mongo0 -d -p 27017:27017 \
            --name "$DB_TYPE"_server $MONGO_IMAGE
        fi

        if [[ $DB_TYPE = "redis" ]]; then
            docker run -v temp_"$DB_TYPE":/data --network redis0 -d -p 172.17.0.1:6379:6379 \
            --name "$DB_TYPE"_server $REDIS_IMAGE
        fi
        exit;
    fi

    if [[ $2 = "clean" ]]; then
        exit;
        shift; shift;
        while getopts "d:h:y" flag; do
            # These become set during 'getopts'  --- $OPTIND $OPTARG
            case "$flag" in
                d) DB_NAME=$OPTARG;;
                h) HOST=$OPTARG;;
                y) IS_SURE=true;;
            esac
        done
        if [[ ! $IS_SURE ]]; then echo "Use the -y flag if youre sure you wish to drop '$DB_NAME' from $HOST"; exit; fi
        # return run('docker', ['exec', settings.SERVER_NAME, "bash", "-c", `mongo ${config.DB_NAME} --eval "printjson(db.dropDatabase())"`],
        # return run('docker', ['exec', settings.SERVER_NAME, "bash", "-c", `dropdb ${config.DB_NAME} -U postgres `], {logStdOut: true, logStdErr: true})
    fi

    if [[ $2 = "exec" ]]; then
        if [[ $DB_TYPE = "mongo" ]]; then shift; shift && docker exec -it mongo_server mongo $@; exit; fi
        if [[ $DB_TYPE = "pg" ]]; then shift; shift && docker exec -it pg_server psql -U postgres $@; exit; fi
        if [[ $DB_TYPE = "redis" ]]; then shift; shift && docker exec -it redis_server redis-cli $@; exit; fi
    fi

    if [[ $2 = "rm" ]]; then
        DB_NAME=$3
        if [[ -z $DB_NAME ]]; then
            echo "Please specify database"
            echo "Usage:"
            echo "$0 [pg|mongo] rm DATABASE_NAME"
            exit;
        fi
        if [[ $DB_TYPE = "mongo" ]]; then
            echo "Dropping $DB_NAME from mongo"
            docker exec mongo_server mongo $DB_NAME --eval "printjson(db.dropDatabase())"
            exit;
            # shift; shift && docker exec -it mongo_server mongo $@;
        fi

        if [[ $DB_TYPE = "pg" ]]; then
            echo "Dropping $DB_NAME from pg"
            docker exec pg_server dropdb $DB_NAME -U postgres
            exit;
            # shift; shift && docker exec -it pg_server psql -U postgres $@;
        fi

        echo "Available commands"
        echo "$(basename $0) rm [pg|mongo] DATABASE_NAME"
        exit;
    fi

    echo "Available commands"
    echo "$(basename $0) [pg|mongo] [exec|start|import|dump|rm]"
    exit;
fi




############# END  STUFF ##########
############# END  STUFF ##########
