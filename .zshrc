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
    fmt* ) shift 1; command ~/bin/terraform_1.0.1 fmt --recursive "$@" ;;
    * ) command ~/bin/terraform_1.0.1 "$@" ;;
  esac
}

#aliases
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

export ANSIBLE_VAULT_PASSWORD_FILE="$HOME/.vault_pass"
export AWS_PROFILE=default
export GOPATH=~/work/gopath
export GOOGLE_APPLICATION_CREDENTIALS=
export GOOGLE_ENCRYPTION_KEY=

export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$HOME/.pyenv/bin:$HOME/work/git:$GOPATH/bin:$HOME/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
