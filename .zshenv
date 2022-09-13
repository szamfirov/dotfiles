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
    CONTAINER_SUFFIX=$(echo $RANDOM | md5sum | head -c 20; echo)
    CONTAINER_IMAGE_NAME=${DEVCONTAINER_PROJECT_NAME}-${CONTAINER_SUFFIX}
    docker build -t ${CONTAINER_IMAGE_NAME} .devcontainer/ || echo Failed to build docker image;
    docker run --rm -it \
        -v ~/.config:${DEVCONTAINER_USER_HOME}/.config \
        -v ~/.git-credentials:${DEVCONTAINER_USER_HOME}/.git-credentials-to-be-copied:ro \
        -v ~/.gitconfig:${DEVCONTAINER_USER_HOME}/.gitconfig:ro \
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
