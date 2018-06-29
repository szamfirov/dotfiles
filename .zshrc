autoload -U colors && colors
autoload -z edit-command-line
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

#aliases
alias ls='`if ! command -v gls; then echo "ls"; fi` --color=auto --group-directories-first'
alias rssh='ssh -l root'
alias "ttplan"='terraform plan -var aws_access_key=$AWS_ACCESS_KEY -var aws_secret_key=$AWS_SECRET_KEY'
alias "ttapp"='terraform apply -var aws_access_key=$AWS_ACCESS_KEY -var aws_secret_key=$AWS_SECRET_KEY'
alias sshadd='~/work/add-ssh-keys.sh'
alias tmux='TERM=xterm-256color tmux'

alias pull='git pull origin $(git pwb)'
alias push='git push origin $(git pwb)'
alias master='git checkout master; git pull origin master'
alias gs='git status'

#edit command line
bindkey '^[e' edit-command-line

#move left/right through words
bindkey '[D' emacs-backward-word
bindkey '[C' emacs-forward-word

bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

export PATH="$HOME/.pyenv/bin:$HOME/work/git:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

ANSIBLE_VAULT_PASSWORD_FILE="$HOME/.vault_pass"
export ANSIBLE_VAULT_PASSWORD_FILE
export EDITOR=vim

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
