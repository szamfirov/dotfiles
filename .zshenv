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

devcontainer_cli() {
    FORCE_ARGS=
    case "$1" in
        -f) FORCE_ARGS="--remove-existing-container";;
    esac

    # Don't run devcontainer if no .devcontainer folder is present
    [ `find ${PWD} -type d -name .devcontainer -maxdepth 1 | wc -l` -eq 0 ] && return
    # Rancher SSH auth socket (for SSH agent forwarding)
    if $(command -v rdctl > /dev/null); then
        SSH_AUTH_SOCK=$(rdctl shell printenv SSH_AUTH_SOCK)
        rdctl shell sudo chmod 775 $SSH_AUTH_SOCK
    else
        eval $(ssh-agent -s)
        ssh-add
    fi

    # Default to "vscode" as a user if there isn't one explicitly defined
    DEVCONTAINER_USER=$(cat .devcontainer/devcontainer.json | grep -v "^\/\|^\#" | jq -r '. | .remoteUser // "vscode"')
    DEVCONTAINER_USER_HOME=/home/${DEVCONTAINER_USER}

    devcontainer up \
        $FORCE_ARGS \
        --build-no-cache \
        --mount "type=bind,source=$SSH_AUTH_SOCK,target=/tmp/ssh-agent.sock" \
        --mount "type=bind,source=${HOME}/.config,target=${DEVCONTAINER_USER_HOME}/.config" \
        --mount "type=bind,source=${HOME}/.gitconfig,target=${DEVCONTAINER_USER_HOME}/.gitconfig" \
        --mount "type=bind,source=${HOME}/.git-credentials,target=${DEVCONTAINER_USER_HOME}/.git-credentials" \
        --mount "type=bind,source=${HOME}/.zshrc,target=${DEVCONTAINER_USER_HOME}/.zshrc" \
        --dotfiles-repository "https://github.com/szamfirov/dotfiles" \
        --workspace-folder .

    devcontainer exec \
        --remote-env "EDITOR=vim" \
        --remote-env "SHELL=zsh" \
        --remote-env "SSH_AUTH_SOCK=/tmp/ssh-agent.sock" \
        --remote-env "ZSH=${DEVCONTAINER_USER_HOME}/.oh-my-zsh" \
        --workspace-folder . \
        /bin/zsh
}
