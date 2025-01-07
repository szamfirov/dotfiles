alias ls='`if ! command -v gls; then echo "ls"; fi` --color=auto --group-directories-first'
alias rssh='ssh -l root'
alias "ttplan"='terraform plan -var aws_access_key=$AWS_ACCESS_KEY -var aws_secret_key=$AWS_SECRET_KEY'
alias "ttapp"='terraform apply -var aws_access_key=$AWS_ACCESS_KEY -var aws_secret_key=$AWS_SECRET_KEY'
alias sshadd='~/work/add-ssh-keys.sh'
alias ssh='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
#alias tmux='TERM=xterm-256color tmux'

alias pull='git pull origin $(git pwb)'
alias push='git push origin $(git pwb)'
alias master='git checkout master; git pull origin master'
alias main='git checkout main; git pull origin main'
alias gs='git status'

alias k='kubectl'
alias tf='terraform_default_to_recursive'
alias terraform='terraform_default_to_recursive'
alias share-terminal='ttyd -R -p 12345 -t rendererType=webgl tmux attach -t main || tmux new -s main'

devcontainer_cli() {
    FORCE_ARGS=
    case "$1" in
        -f) FORCE_ARGS="--remove-existing-container";;
    esac

    GIT_ROOT=$(git rev-parse --show-toplevel)
    DEVCONTAINER_FILE=$(find ${GIT_ROOT} \( -type f -name devcontainer.json -o -type f -name .devcontainer.json \) -maxdepth 2)

    # Don't run devcontainer if no devcontainer.json file is present
    [ -z "$DEVCONTAINER_FILE" ] && return

    # Rancher SSH auth socket (for SSH agent forwarding)
    #export SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock
    #if ! $(command -v rdctl > /dev/null); then
    #    eval $(ssh-agent -s)
    #    ssh-add
    #fi

    # Default to "vscode" as a user if there isn't one explicitly defined
    DEVCONTAINER_USER=$(cat ${DEVCONTAINER_FILE} | grep -v "^\/\|^\#" | jq -r '. | .remoteUser // "vscode"')
    DEVCONTAINER_USER_HOME=/home/${DEVCONTAINER_USER}

    devcontainer up \
        $FORCE_ARGS \
        --build-no-cache \
        --workspace-mount-consistency consistent \
        --mount "type=bind,source=${HOME}/.config,target=${DEVCONTAINER_USER_HOME}/.config" \
        --mount "type=bind,source=${HOME}/.gitconfig,target=${DEVCONTAINER_USER_HOME}/.gitconfig" \
        --mount "type=bind,source=${HOME}/.git-credentials,target=${DEVCONTAINER_USER_HOME}/.git-credentials" \
        --mount "type=bind,source=${HOME}/.ssh,target=${DEVCONTAINER_USER_HOME}/.ssh" \
        --mount "type=bind,source=${HOME}/.zshrc,target=${DEVCONTAINER_USER_HOME}/.zshrc" \
        --remote-env "EDITOR=vim" \
        --remote-env "SHELL=zsh" \
        --remote-env "ZSH=${DEVCONTAINER_USER_HOME}/.oh-my-zsh" \
        --dotfiles-repository "https://github.com/szamfirov/dotfiles" \
        --update-remote-user-uid-default on \
        --workspace-folder $GIT_ROOT
        #--mount "type=bind,source=${SSH_AUTH_SOCK},target=/tmp/ssh-agent.sock" \
        #--remote-env "SSH_AUTH_SOCK=/tmp/ssh-agent.sock" \

    devcontainer exec \
        --remote-env "EDITOR=vim" \
        --remote-env "SHELL=zsh" \
        --remote-env "ZSH=${DEVCONTAINER_USER_HOME}/.oh-my-zsh" \
        --workspace-folder $GIT_ROOT \
        zsh || \
    devcontainer exec \
        --remote-env "EDITOR=vim" \
        --remote-env "SHELL=zsh" \
        --remote-env "ZSH=${DEVCONTAINER_USER_HOME}/.oh-my-zsh" \
        --workspace-folder $GIT_ROOT \
        bash
        #--remote-env "SSH_AUTH_SOCK=/tmp/ssh-agent.sock" \
}
