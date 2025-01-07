autoload -U colors && colors
autoload -z edit-command-line
autoload -Uz compinit && compinit
autoload bashcompinit && bashcompinit
zle -N edit-command-line

HISTFILE=$HOME/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt INC_APPEND_HISTORY
#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

echo

setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{5}%f%s%F{5}%F{3}:%F{5}(%F{2}%b%F{3}|%F{1}%a%F{5})%f ' #'%F{5}(%F{2}%b%F{3}|%F{1}%a%F{5})%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}%f%s%F{5}%F{3}:%F{5}(%F{2}%b%F{5})%f ' #'%F{5}(%F{2}%b%F{5})%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}|%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
PROMPT='[$fg_bold[blue]%*$reset_color] $fg[cyan]%~$reset_color $(vcs_info_wrapper)
%% '

# make sure terraform binary is in place, e.g. /usr/local/bin/terraform -> ~/bin/terraform_1.4.2
terraform_default_to_recursive() {
  case $* in
    fmt* ) shift 1; command terraform fmt --recursive "$@" ;;
    * ) command terraform "$@" ;;
  esac
}

#edit command line
bindkey '^[e' edit-command-line

#move left/right through words
bindkey '[D' emacs-backward-word
bindkey '[C' emacs-forward-word

bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

export TERM=xterm-color
export EDITOR=vim
export GPG_TTY=$(tty)
export XDG_CONFIG_HOME="${HOME}/.config"

#export ANSIBLE_VAULT_PASSWORD_FILE="$HOME/.vault_pass"
#export AWS_PROFILE=default
export GOPATH=~/work/gopath
#export GOOGLE_APPLICATION_CREDENTIALS=
#export GOOGLE_ENCRYPTION_KEY=
#export DOCKER_SOCKET="unix://${HOME}/.rd/docker.sock"

export PATH="/usr/local/go/bin:/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin:$HOME/work/git:$HOME/miniconda3/bin:$GOPATH/bin:$HOME/bin:$PATH"

# devcontainer
if $(command -v devcontainer-info > /dev/null); then
    PROMPT='[$fg_bold[blue]%*$reset_color] $fg_bold[red]DEVCONTAINER$reset_color $fg[cyan]%~$reset_color $(vcs_info_wrapper)
%% '

    GIT_ROOT=$(git rev-parse --show-toplevel)
    DEVCONTAINER_FILE=$(find ${GIT_ROOT} \( -type f -name devcontainer.json -o -type f -name .devcontainer.json \) -maxdepth 2)

    POST_CREATE_CMD="$(cat ${DEVCONTAINER_FILE} | grep -v "^\/\/\|^\#" | jq -r .postCreateCommand)"
    eval $POST_CREATE_CMD

    if [ -f ${HOME}/.git-credentials-to-be-copied ]; then
        CURR_USER=$(whoami)
        sudo cp ${HOME}/.git-credentials-to-be-copied ${HOME}/.git-credentials
        sudo chown ${CURR_USER}: ${HOME}/.git-credentials
    fi

    [ -f ${ZSH}/oh-my-zsh.sh ] && source ${ZSH}/oh-my-zsh.sh

    if ! $(command -v vim > /dev/null); then
        sudo apt update && sudo apt install -y vim
    fi

    #if [ -d environments ]; then
    #    SERVICE_ACCOUNT=$(cat environments/root.yaml | yq '.service_account')
    #    echo Creating token for ${SERVICE_ACCOUNT}
    #    export GOOGLE_OAUTH_ACCESS_TOKEN=$(create-token ${SERVICE_ACCOUNT})
    #fi
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# The next line updates PATH for the Google Cloud SDK.
[ -f ~/work/google-cloud-sdk/path.zsh.inc ] && source ~/work/google-cloud-sdk/path.zsh.inc

# The next line enables shell command completion for gcloud.
[ -f ~/work/google-cloud-sdk/completion.zsh.inc ] && source ~/work/google-cloud-sdk/completion.zsh.inc

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
export PATH=$PATH:$HOME/.local/bin

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/svetlin/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/svetlin/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/svetlin/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/svetlin/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
