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

terraform_default_to_recursive() {
  case $* in
    fmt* ) shift 1; command ~/bin/terraform_1.2.5 fmt --recursive "$@" ;;
    * ) command ~/bin/terraform_1.2.5 "$@" ;;
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

#export ANSIBLE_VAULT_PASSWORD_FILE="$HOME/.vault_pass"
#export AWS_PROFILE=default
export GOPATH=~/work/gopath
#export GOOGLE_APPLICATION_CREDENTIALS=
#export GOOGLE_ENCRYPTION_KEY=
export DOCKER_SOCKET="unix://${HOME}/.rd/docker.sock"

export PATH="$HOME/Library/Python/3.8/bin:/usr/local/go/bin:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$HOME/.pyenv/bin:$HOME/work/git:$GOPATH/bin:$HOME/bin:$HOME/.rd/bin:$PATH"

if $(command -v pyenv > /dev/null); then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# devcontainer
if $(command -v devcontainer-info > /dev/null); then
    PROMPT='[$fg_bold[blue]%*$reset_color] $fg_bold[red]DEVCONTAINER$reset_color $fg[cyan]%~$reset_color $(vcs_info_wrapper) %% '

    POST_CREATE_CMD="$(cat .devcontainer/devcontainer.json | jq -r .postCreateCommand)"
    eval $POST_CREATE_CMD

    if [ -f ${HOME}/.git-credentials-to-be-copied ]; then
        CURR_USER=$(whoami)
        sudo cp ${HOME}/.git-credentials-to-be-copied ${HOME}/.git-credentials
        sudo chown ${CURR_USER}: ${HOME}/.git-credentials
    fi

    [ -f ${ZSH}/oh-my-zsh.sh ] && source ${ZSH}/oh-my-zsh.sh

    [ -d ${DEVCONTAINER_PROJECT_DIR}/environments ] && \
        export GOOGLE_OAUTH_ACCESS_TOKEN=$(create-token --file $(find environments -name root.yaml))

    if ! $(command -v vim > /dev/null); then
        sudo apt update && sudo apt install -y vim
    fi
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# The next line updates PATH for the Google Cloud SDK.
[ -f ~/work/google-cloud-sdk/path.zsh.inc ] && source ~/work/google-cloud-sdk/path.zsh.inc

# The next line enables shell command completion for gcloud.
[ -f ~/work/google-cloud-sdk/completion.zsh.inc ] && source ~/work/google-cloud-sdk/completion.zsh.inc
