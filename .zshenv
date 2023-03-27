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
    # Don't run devcontainer if no .devcontainer folder is present
    [ `find ${PWD} -type d -name .devcontainer -maxdepth 1 | wc -l` -eq 0 ] && return
    # Rancher SSH auth socket (for SSH agent forwarding)
    SSH_AUTH_SOCK=$(rdctl shell printenv SSH_AUTH_SOCK)
    rdctl shell sudo chmod 775 $SSH_AUTH_SOCK

    DEVCONTAINER_USER=$(cat .devcontainer/devcontainer.json | grep -v "^\/\|^\#" | jq -r '. | .remoteUser // "vscode"')
    DEVCONTAINER_USER_HOME=/home/${DEVCONTAINER_USER}
    DEVCONTAINER_PROJECT_DIR=/workspaces/$(basename $PWD)

    #node ~/work/projects/devcontainer-cli/devcontainer.js up \
    /usr/local/bin/devcontainer up \
        --build-no-cache \
        --mount "type=bind,source=$SSH_AUTH_SOCK,target=/tmp/ssh-agent.sock" \
        --mount "type=bind,source=${HOME}/.config,target=${DEVCONTAINER_USER_HOME}/.config" \
        --dotfiles-repository "https://github.com/szamfirov/dotfiles" \
        --workspace-folder .
    #node ~/work/projects/devcontainer-cli/devcontainer.js exec \
    /usr/local/bin/devcontainer exec \
        --remote-env "DEVCONTAINER_PROJECT_DIR=${DEVCONTAINER_PROJECT_DIR}" \
        --remote-env "SSH_AUTH_SOCK=/tmp/ssh-agent.sock" \
        --remote-env "EDITOR=vim" \
        --remote-env "ZSH=${DEVCONTAINER_USER_HOME}/.oh-my-zsh" \
        --workspace-folder . \
        /bin/zsh
}
