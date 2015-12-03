# Created by newuser for 4.3.17

autoload -U colors && colors
autoload -z edit-command-line
zle -N edit-command-line

HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt INC_APPEND_HISTORY
#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

echo

setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{5}%f%s%F{5}%F{3}:%F{5}(%F{2}%b%F{3}|%F{1}%a%F{5})%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}%f%s%F{5}%F{3}:%F{5}(%F{2}%b%F{5})%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}|%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
PROMPT='[$fg_bold[white]%*$reset_color] %{%F{cyan}%}%~%f%} $(vcs_info_wrapper)%% '
#RPROMPT=$'$(vcs_info_wrapper)'

#aliases
alias ls='ls --color=auto --group-directories-first'
alias kinits='kinit szamfirov@SKRILL.NET'
alias kiniti='kinit szamfirov@INTRA.NET'
alias k="${HOME}/kinit.sh"
alias ks="${HOME}/kinits.sh"
alias rssh='ssh -l root'
alias "ttplan"='terraform plan -var aws_access_key=$AWS_ACCESS_KEY -var aws_secret_key=$AWS_SECRET_KEY'
alias "ttapp"='terraform apply -var aws_access_key=$AWS_ACCESS_KEY -var aws_secret_key=$AWS_SECRET_KEY'

#edit command line
bindkey '^[e' edit-command-line

#move left/right through words
bindkey ';5D' emacs-backward-word
bindkey ';5C' emacs-forward-word
