alias ls='`if ! command -v gls; then echo "ls"; fi` --color=auto --group-directories-first'
alias rssh='ssh -l root'
alias "ttplan"='terraform plan -var aws_access_key=$AWS_ACCESS_KEY -var aws_secret_key=$AWS_SECRET_KEY'
alias "ttapp"='terraform apply -var aws_access_key=$AWS_ACCESS_KEY -var aws_secret_key=$AWS_SECRET_KEY'
alias sshadd='~/work/add-ssh-keys.sh'
alias ssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias tmux='TERM=xterm-256color tmux'

alias pull='git pull origin $(git pwb)'
alias push='git push origin $(git pwb)'
alias master='git checkout master; git pull origin master'
alias main='git checkout main; git pull origin main'
alias gs='git status'

alias k='kubectl'
alias tf='terraform_default_to_recursive'
alias terraform='terraform_default_to_recursive'
alias share-terminal='ttyd -R -p 12345 -t rendererType=webgl tmux attach -t main || tmux new -s main'

cleanup_unused_docker_images() {
    CURRENT_RUNNING_CONTAINERS=$(docker ps -a --format {{.Image}} | grep "^$(basename $(pwd))*" | xargs)
    EXCLUDE_PATTERN=$(echo $CURRENT_RUNNING_CONTAINERS | sed -e 's/ /\\|/g')
    DOCKER_IMAGES_TO_REMOVE=$(docker images -f "reference=$(basename $PWD)*" --format {{.Repository}} | sort -u | grep -v ${EXCLUDE_PATTERN:=default_value})
    [ ! -z "$DOCKER_IMAGES_TO_REMOVE" ] && \
        echo $DOCKER_IMAGES_TO_REMOVE | xargs docker rmi -f
}

devcontainer() {
    # Don't run devcontainer if no .devcontainer folder is present
    [ `find ${PWD} -type d -name .devcontainer -maxdepth 1 | wc -l` -eq 0 ] && return
    # Rancher SSH auth socket (for SSH agent forwarding)
    SSH_AUTH_SOCK=$(rdctl shell printenv SSH_AUTH_SOCK)
    rdctl shell sudo chmod 775 $SSH_AUTH_SOCK
    # Cleanup unused docker images
    cleanup_unused_docker_images

    DEVCONTAINER_USER=vscode
    DEVCONTAINER_USER_HOME=/home/${DEVCONTAINER_USER}
    DEVCONTAINER_PROJECT_NAME=$(basename $PWD)
    DEVCONTAINER_PROJECT_DIR=/workspaces/${DEVCONTAINER_PROJECT_NAME}
    DEVCONTAINER_BUILD_CONTEXT=
    CONTAINER_SUFFIX=$(echo $RANDOM | md5sum | head -c 20; echo)
    CONTAINER_IMAGE_NAME=${DEVCONTAINER_PROJECT_NAME}-${CONTAINER_SUFFIX}
    if [ -f .devcontainer/Dockerfile ]; then
        BUILD_CONTEXT=$(cat .devcontainer/devcontainer.json | jq -r .build.context)
        [ "${BUILD_CONTEXT}" != "null" ] && DEVCONTAINER_BUILD_CONTEXT="${BUILD_CONTEXT}"
        docker build -t ${CONTAINER_IMAGE_NAME} -f .devcontainer/Dockerfile .devcontainer/${DEVCONTAINER_BUILD_CONTEXT} || echo Failed to build docker image;
    else
        CONTAINER_IMAGE_NAME=$(cat .devcontainer/devcontainer.json | jq -r .image)
    fi
    docker run --rm -it \
        -v ~/.config:${DEVCONTAINER_USER_HOME}/.config \
        -v ~/.git-credentials:${DEVCONTAINER_USER_HOME}/.git-credentials-to-be-copied:ro \
        -v ~/.gitconfig:${DEVCONTAINER_USER_HOME}/.gitconfig \
        -v ~/.vim:${DEVCONTAINER_USER_HOME}/.vim:ro \
        -v ~/.vimrc:${DEVCONTAINER_USER_HOME}/.vimrc:ro \
        -v ~/.zlogin:${DEVCONTAINER_USER_HOME}/.oh-my-zsh/custom/zlogin.zsh:ro \
        -v ~/.zshrc:${DEVCONTAINER_USER_HOME}/.zshrc:ro \
        -v $(pwd):${DEVCONTAINER_PROJECT_DIR} \
        -v $SSH_AUTH_SOCK:/tmp/ssh-agent.sock \
        -e DEVCONTAINER_PROJECT_DIR=${DEVCONTAINER_PROJECT_DIR} \
        -e EDITOR=vim \
        -e SSH_AUTH_SOCK=/tmp/ssh-agent.sock \
        -e ZSH=${DEVCONTAINER_USER_HOME}/.oh-my-zsh \
        -u ${DEVCONTAINER_USER} \
        --workdir ${DEVCONTAINER_PROJECT_DIR} \
        ${@} \
        ${CONTAINER_IMAGE_NAME} \
        zsh
}

devcontainer_cli() {
    FORCE_ARGS=
    case "$1" in
        -f) FORCE_ARGS="--remove-existing-container";;
    esac

    # Don't run devcontainer if no .devcontainer folder is present
    [ `find ${PWD} -type d -name .devcontainer -maxdepth 1 | wc -l` -eq 0 ] && return
    # Rancher SSH auth socket (for SSH agent forwarding)
    SSH_AUTH_SOCK=$(rdctl shell printenv SSH_AUTH_SOCK)
    rdctl shell sudo chmod 775 $SSH_AUTH_SOCK

    # Default to "vscode" as a user if there isn't one explicitly defined
    DEVCONTAINER_USER=$(cat .devcontainer/devcontainer.json | grep -v "^\/\|^\#" | jq -r '. | .remoteUser // "vscode"')
    DEVCONTAINER_USER_HOME=/home/${DEVCONTAINER_USER}

    /usr/local/bin/devcontainer up \
        $FORCE_ARGS \
        --build-no-cache \
        --mount "type=bind,source=$SSH_AUTH_SOCK,target=/tmp/ssh-agent.sock" \
        --mount "type=bind,source=${HOME}/.config,target=${DEVCONTAINER_USER_HOME}/.config" \
        --mount "type=bind,source=${HOME}/.gitconfig,target=${DEVCONTAINER_USER_HOME}/.gitconfig" \
        --mount "type=bind,source=${HOME}/.git-credentials,target=${DEVCONTAINER_USER_HOME}/.git-credentials" \
        --mount "type=bind,source=${HOME}/.zshrc,target=${DEVCONTAINER_USER_HOME}/.zshrc" \
        --dotfiles-repository "https://github.com/szamfirov/dotfiles" \
        --workspace-folder .
    /usr/local/bin/devcontainer exec \
        --remote-env "EDITOR=vim" \
        --remote-env "SHELL=zsh" \
        --remote-env "SSH_AUTH_SOCK=/tmp/ssh-agent.sock" \
        --remote-env "ZSH=${DEVCONTAINER_USER_HOME}/.oh-my-zsh" \
        --workspace-folder . \
        /bin/zsh
}
