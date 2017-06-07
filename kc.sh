#!/bin/bash

INITIALIFS=$IFS;

# Technique for future reference to "expose" a running container to dif port
# docker exec -it <containterid> ssh -R5432:localhost:5432 <user>@<hostip>

source $HOME/code/secrets/variables.sh

if [ "$1" = "load" ]; then
    sudo cp $HOME/code/configs/kc.sh /usr/local/bin/kc && sudo chmod +x /usr/local/bin/kc
    echo "Loaded"
    exit;
fi

if [ "$1" = "link" ]; then
    (cd $HOME &&
    ln -s $HOME/code/configs/vimrc .vimrc &&
    ln -s $HOME/code/configs/bash_aliases .bash_aliases &&
    ln -s $HOME/code/configs/$(uname)/bash_profile .bash_profile &&
    ln -s $HOME/code/configs/$(uname)/tmux.conf .tmux.conf)
    exit;
fi

if [ "$1" = "rmlinks" ]; then
    (cd $HOME && rm .vimrc .bash_aliases .bash_profile .tmux.conf)
    exit;
fi

if [ "$1" = "config" ]; then
    if [[ $2 = "atom" ]]; then atom $HOME/code/configs ;
    else vim $HOME/code/configs/kc.sh ; fi
    exit;
fi

if [ "$1" = "linkmod" ]; then
    rm -rf ./node_modules/$2
    ln -s ~/code/mods/$2 ./node_modules/$2
    exit;
fi

if [ "$1" = "sync" ]; then
    if [ "$3" = "nh" ] ; then DIRECTION="$2 $NH:$4" ; fi
    if [ "$3" = "main" ] ; then DIRECTION="$2 $MAIN:$4" ; fi

    if [ "$2" = "nh" ] ; then DIRECTION="$NH:$3 $4" ; fi
    if [ "$2" = "main" ] ; then DIRECTION="$MAIN:$3 $4" ; fi
    rsync -avuz -e ssh $DIRECTION
    exit;
fi

if [ "$1" = "ss" ] ; then shift 1; python -m SimpleHTTPServer $@; exit; fi

if [ "$1" = "start" ]; then
	if [ "$2" = "vpn" ] ; then sudo openvpn --config $HOME/code/vpn/no-route.ovpn; fi
	if [ "$2" = "route" ] ; then sudo openvpn --config $HOME/code/vpn/route.ovpn; fi
    exit;
fi

############# SSH STUFF ##########
############# SSH STUFF ##########
if [ "$1" = "nh" ] ; then shift 1; ssh $NH $@; exit; fi
if [ "$1" = "git" ] ; then shift 1; ssh $GITMAIN $@; exit; fi
if [ "$1" = "main" ] ; then shift 1; ssh $MAIN $@; exit; fi
if [ "$1" = "vpn" ] ; then shift 1; ssh $VPNSERVER $@; exit; fi

if [[ $1 = "copykey" ]]; then
    REMOTE=""
    if [[ -z $2 ]] ; then echo "Specifiy location to copy key to {nh|git|main}."; exit ; fi
    if [ "$2" = "nh" ] ; then REMOTE="ssh $NH" ; fi
    if [ "$2" = "git" ] ; then echo "addkey $(cat ~/.ssh/id_rsa.pub)" | ssh $GITMAIN; exit; fi
    if [ "$2" = "main" ] ; then REMOTE="ssh $MAIN" ; fi
    if [ -z "$REMOTE" ] ; then REMOTE="ssh $2" ; fi
    cat $HOME/.ssh/id_rsa.pub | $REMOTE "cat >> ~/.ssh/authorized_keys"
    exit;
fi

if [[ $1 = "tunnel" ]]; then

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
if [ "$1" = "clone" ]; then
    if [ ! "$2" = "nh" ] && [ ! "$2" = "main" ]  && [ ! "$2" = "bit" ] && [ ! "$2" = "server" ]; then
        echo "Please specify 'nh', 'main', 'bit', or 'server' as 2nd arg"; exit;
    fi
    if [ "$2" = "nh" ] ; then URL=$NH:/opt/git/$3.git ; fi
    if [ "$2" = "main" ] ; then URL=$GITMAIN:$3.git ; fi
    if [ "$2" = "bit" ] ; then URL=$BIT:JestrJ/$3.git ; fi
    if [ "$2" = "server" ] ; then URL=$BITSERVER/JestrJ/$3.git ; fi

    FOLDER=$4
    if [ -z "$FOLDER" ] ; then FOLDER=$3 ; fi
    git clone $URL $FOLDER
    exit;
fi

if [ "$1" = "initrepo" ]; then
    if [ ! "$2" = "nh" ] && [ ! "$2" = "main" ] ; then echo "Please specify 'nh' or 'main' as 2nd arg" ; exit; fi
    git init
    git add -A && git commit -m "Init"
    $0 pushrepo $2 $3
    exit;
fi

if [ "$1" = "pushrepo" ]; then
    REPO=${PWD##*/}
    REPONAME=$3
    if [ ! "$2" = "nh" ] && [ ! "$2" = "main" ] ; then echo "Please specify 'nh' or 'main' as 2nd arg" ; exit; fi

    if [ -z "$REPONAME" ] ; then REPONAME=$REPO ; fi
    if [ "$2" = "nh" ] ; then URL=$NH:/opt/git/ LOC=/opt/git; fi
    if [ "$2" = "main" ] ; then URL=$GITMAIN: LOC=/home/git; fi

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
    echo -n "Tag as v$MAJOR.$MINOR.$PATCH ? (y/n): "
    read YN
    if [ "$YN" = y ]; then git tag -a v$MAJOR.$MINOR.$PATCH ; fi
    exit;
fi


if [ "$1" = "diff" ]; then
    if [ "$2" = "origin" ] ; then git diff master..origin/master ;
    elif [ "$2" = "local" ] ; then git diff origin/master..master ;
    else git diff ; fi
    exit;
fi

if [ "$1" = "seturl" ]; then
    REPONAME=$3
    if [[ -z $REPONAME ]] ; then REPONAME=${PWD##*/} ; fi
    if [ "$2" = "nh" ] ; then git remote set-url origin $NH:/opt/git/$REPONAME.git ; fi
    if [ "$2" = "main" ] || [ "$2" = "git" ] ; then git remote set-url origin $GITMAIN:$REPONAME.git ; fi
    if [ "$2" = "bit" ] ; then git remote set-url origin $BIT:JestrJ/$REPONAME.git ; fi
    if [ "$2" = "server" ] ; then git remote set-url origin $BITSERVER/JestrJ/$REPONAME.git ; fi
    exit;
fi

if [ "$1" = "fetch" ]; then
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
    echo "========= NH Repos ========="
    $0 nh "cd git && ls -l"
    echo "======== Main Repos ========"
    $0 main "cd git && ls -l"
    exit;
fi
############# END GIT STUFF ##########
############# END GIT STUFF ##########

############# DOCKER STUFF ##########
############# DOCKER STUFF ##########
if [ "$1" = "rmc" ]; then
	docker rm $(docker ps -aqf status=exited)
    exit;
fi

if [ "$1" = "rmi" ]; then
    docker rmi $(docker images -f 'dangling=true' -q)
    exit;
fi

if [[ $1 = "rmm" ]]; then
    MACHINES=$(docker-machine ls | grep -v 'NAME' | awk '{ print $1 }')
    docker-machine rm $MACHINES
    exit;
fi

if [[ $1 = "destroy" ]]; then
    $0 rmm;
    terraform destroy;
    exit;
fi

if [[ $1 = "registry" ]]; then
    az acr repository list -n $2 -o json
    exit;
fi

if [[ $1 = "dlogin" ]]; then
    CMD="docker login $REGISTRY_NAME -u $REGISTRY_APP_ID -p $REGISTRY_PW"
    if [[ -z $2 ]]; then $CMD;
    else echo "$CMD" | docker-machine ssh $2; fi
    exit;
fi

if [[ $1 = "dpush" ]]; then
    if [[ -z $2 ]]; then echo "Please specify image name" exit; fi
    docker push $REGISTRY_NAME/$2
    exit;
fi

if [[ $1 = "dswarm" ]]; then
    if [[ $2 = "reset" ]]; then
        echo  export DOCKER_TLS_VERIFY=""
        echo  export DOCKER_HOST=""
        echo  export DOCKER_CERT_PATH=""
        echo  export DOCKER_MACHINE_NAME=""
    fi
    exit;
fi

if [[ $1 = "stack" ]]; then
    shift;
    while getopts "m:n:" flag; do
        # These become set during 'getopts'  --- $OPTIND $OPTARG
        case "$flag" in
            m) MACHINE=$OPTARG;;
            n) STACKNAME=$OPTARG;;
        esac
    done
    if [[ -z $STACKNAME ]]; then STACKNAME="default"; fi
    eval $(docker-machine env $MACHINE)
    docker stack deploy --compose-file docker-compose.yml $STACKNAME --with-registry-auth
    exit;
fi

if [[ $1 = "dmachine" ]]; then
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

if [[ $1 = "swarm" ]]; then

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
        if [[ $4 =  "azure" ]]; then
            knife ssh $4 $3 --ssh-user $AZURE_SSH_USER --identity-file ~/.ssh/id_rsa \
            --attribute cloud.public_ip
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

############# CONSUL STUFF ##########
############# CONSUL STUFF ##########

if [[ $2 = "consul" ]]; then
    wget https://releases.hashicorp.com/consul/0.8.1/consul_0.8.1_linux_amd64.zip
fi
############# END CONSUL STUFF ##########
############# END CONSUL STUFF ##########

if [[ $1 = "deploy" ]]; then
    if [[ -z $2 ]]; then echo "Please specify project folder name."; exit ; fi
    CMD="cd ~/apps/$2; git fetch; git reset --hard origin/master;"
    if [[ $3 = "build" ]]; then CMD="$CMD docker-compose build;"; fi
    if [[ $3 = "up" ]]; then CMD="$CMD docker-compose up --build -d;"; fi
    CMD="$CMD docker rmi \$(docker images -f 'dangling=true' -q);"
    REPO=$(echo $2 | tr '[:lower:]' '[:upper:]')
    MESSAGE="{\"text\": \"*$REPO* deployed:\n $(git show -q)\"}"
    ssh $NH $CMD
    curl -X POST --header "Content-Type: application/json" \
        $SLACK_DEPLOY_HOOK \
        -d ''"$MESSAGE"''
    exit;
fi

if [[ $1 = "deploysingle" ]]; then
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

    rsync -avuz --exclude=".git" --exclude="node_modules" --exclude="server/output" . root@$IP:~/$REPO
    exit;
fi


if [[ $1 = "build" ]]; then

    shift;
    while getopts "m:r:" flag; do
        # These become set during 'getopts'  --- $OPTIND $OPTARG
        case "$flag" in
            r) REGISTRY=$OPTARG;;
            m) MACHINE=$OPTARG;;
        esac
    done

    if [[ -z $MACHINE ]]; then echo "Please provide a docker machine"; exit ; fi
    if [[ $REGISTRY = 'hub' ]] || [[ -z $REGISTRY ]]; then LOGIN="-u $DOCKER_HUB_USER -p $DOCKER_HUB_PW" ; fi
    if [[ $REGISTRY = 'ree' ]]; then LOGIN="$REGISTRY_NAME -u $REGISTRY_APP_ID -p $REGISTRY_PW" ; fi

    LOGIN="docker login $LOGIN";
    REPO=${PWD##*/}

    CMD="cd ~/$REPO; docker-compose build; $LOGIN; docker-compose push;"
    CMD="$CMD docker rmi \$(docker images -f 'dangling=true' -q);"
    IP=$(docker-machine ip $MACHINE)

    rsync -avuz --exclude=".git" --exclude="node_modules" --exclude="server/output" . root@$IP:~/$REPO
    ssh root@$IP $CMD
    exit;
fi


if [[ $1 = "pg" ]] || [[ $1 = "mongo" ]]; then
    DB_TYPE=$1

    if [[ $2 = "dump" ]] || [[ $2 = "import" ]]; then
        CMD=$2
        if [[ $DB_TYPE = "mongo" ]]; then DB="mongo"; IMAGE="mongo"; fi
        if [[ $DB_TYPE = "pg" ]]; then DB="pg"; IMAGE="postgres:9.4"; fi

        shift; shift;
        while getopts "d:h:f:t:" flag; do
            # These become set during 'getopts'  --- $OPTIND $OPTARG
            case "$flag" in
                d) DB_NAME=$OPTARG;;
                f) DUMP_FILE=$OPTARG;;
                h) HOST=$OPTARG;;
                t) TABLES=$OPTARG;;
            esac
        done

        if [[ -z $HOST ]] || [[ -z $DB_NAME ]]; then echo "Please specify a host and database"; exit; fi

        if [[ ! -z $TABLES ]]; then
            IFS=","; read -ra TABLEARR <<< "$TABLES"; IFS=$INITIALIFS;
            for table in "${TABLEARR[@]}" ; do
                TABLESTR="$TABLESTR -t $table"
            done
        fi

        if [[ $CMD = "import" ]] && [[ -z $DUMP_FILE ]]; then echo "Please specify a dump file"; exit; fi
        if [[ $CMD = "import" ]]; then FILENAME=$(basename $DUMP_FILE); fi
        if [[ $CMD = "dump" ]]; then mkdir tempdbdump; fi

        NETWORK=$DB_TYPE"0"
        DOCKER="docker run -v $PWD/tempdbdump:/home/app/dumps --name backup_$DB \
            -u=$(id -u $(whoami)) --network $NETWORK --rm $IMAGE bash -c"

        if [[ $DB_TYPE = "mongo" ]]; then
            if [[ $CMD = "dump" ]]; then
                RUN_CMD="mongodump --host $HOST --db $DB_NAME --out /home/app/dumps/"
            fi
            if [[ $CMD = "import" ]]; then
                RUN_CMD="mongorestore --host $HOST -d $DB_NAME /home/app/dumps/$FILENAME/"
            fi
        fi

        if [[ $DB_TYPE = "pg" ]]; then
            if [[ $CMD = "dump" ]]; then
                RUN_CMD="pg_dump -h $HOST -d $DB_NAME -U postgres $TABLESTR | gzip > /home/app/dumps/$DB_NAME.gz"
            fi
            if [[ $CMD = "import" ]]; then
                RUN_CMD="gunzip -c /home/app/dumps/$FILENAME | psql -h $HOST -d $DB_NAME -U postgres"
            fi
        fi

        $DOCKER "$RUN_CMD"
        exit;
    fi

    if [[ $2 = "start" ]]; then
        VOLUME=$(docker volume inspect temp_"$DB_TYPE")
        CONTAINER=$(docker inspect "$DB_TYPE"_server)

        if [[ ! $CONTAINER = '[]' ]]; then echo "$DB_TYPE"_server "container already exists."; exit; fi

        if [[ $VOLUME = '[]' ]]; then
            echo "Creating blank volume"
            docker volume create --name temp_$DB_TYPE
        fi

        if [[ $DB_TYPE = "pg" ]]; then
            docker run -v temp_"$DB_TYPE":/var/lib/postgresql/data --network pg0 -d -p 172.17.0.1:5432:5432 \
             --name "$DB_TYPE"_server postgres:9.4
        fi

        if [[ $DB_TYPE = "mongo" ]]; then
            docker run -v temp_"$DB_TYPE":/data/db --network mongo0 -d -p 172.17.0.1:27017:27017 \
            --name "$DB_TYPE"_server mongo
        fi
        exit;
    fi

    if [[ $2 = "clean" ]]; then
        exit;
        shift; shift;
        while getopts "d:h:y:" flag; do
            # These become set during 'getopts'  --- $OPTIND $OPTARG
            case "$flag" in
                d) DB_NAME=$OPTARG;;
                h) HOST=$OPTARG;;
                y) IS_SURE=true;;
            esac
        done
        if [[ ! IS_SURE ]]; then echo "Use the -y flag if youre sure you wish to drop '$DB_NAME' from $HOST"; exit; fi
        # return run('docker', ['exec', settings.SERVER_NAME, "bash", "-c", `mongo ${config.DB_NAME} --eval "printjson(db.dropDatabase())"`],
        # return run('docker', ['exec', settings.SERVER_NAME, "bash", "-c", `dropdb ${config.DB_NAME} -U postgres `], {logStdOut: true, logStdErr: true})
    fi

    if [[ $DB_TYPE = "mongo" ]]; then shift && docker exec -it mongo_server mongo $@; fi
    if [[ $DB_TYPE = "pg" ]]; then shift && docker exec -it pg_server psql -U postgres $@; fi

    exit;
fi

echo "Require no args: [load | link | rmlinks | config | mongo | pg | ss | nh | \
    git | main | vpn | fetch | repos | rmc | rmi]"
echo "Require args: [linkmod | sync | start | copykey | clone | initrepo | pushrepo | \
    tag | diff | seturl | registry | dlogin | dpush | stack | deploy | db | mongodump | pgdump]"
