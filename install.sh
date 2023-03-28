#!/bin/bash
set -euo pipefail

OS_NAME=`uname -s`
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
FORCED=0

while getopts ":f" flag; do
    case "${flag}" in
        f) FORCED=1;;
    esac
done

# Check if this is executed from Google Cloud Shell
curl -f -q -H "Metadata-Flavor: Google" metadata/computeMetadata/v1/instance/description 2> /dev/null && OS_NAME="Cloud_Shell"

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

replace() {
    # replace file with the corresponding one for the OS
    FILE=$1
    if [ -z $FILE ]; then
        echo "No arguments provided! Nothing to replace."
        return
    fi

    if [ -f ${OS_NAME}/${FILE} ]; then
        FILE="${OS_NAME}/${FILE}"
    fi

    if [ -f ~/$1 -o -L ~/$1 ]; then
        rm ~/$1 || echo "Cannot remove file: ~/$1, manual action required." && return
    fi
    ln -s ${SCRIPT_DIR}/$FILE ${HOME}/$1
    echo "Created a symbolic link to ${FILE}."
}

# check if homebrew is installed (Only for MacOS)
if [ "$OS_NAME" = "Darwin" ]; then
    if ! $(command -v brew > /dev/null); then
        echo "Installing homebrew..."
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo "homebrew is already installed. Skipping..."
    fi
fi

# check if bash-completion is installed (Only for MacOS)
if [ "$OS_NAME" = "Darwin" ]; then
    # check if there is already installation in $(brew --prefix)/etc/bash_completion
    if [ ! -f $(brew --prefix)/etc/bash_completion ]; then
        echo "Installing bash-completion..."
        $(brew --prefix)/bin/brew install bash-completion
    else
        echo "bash-completion is already installed. Skipping..."
    fi
fi

# check if coreutils is installed (Only for MacOS)
if [ "$OS_NAME" = "Darwin" ]; then
    if ! $(command -v gls > /dev/null); then
        echo "Installing coreutils..."
        $(brew --prefix)/bin/brew install coreutils
    else
        echo "coreutils is already installed. Skipping..."
    fi
fi

# check if tmux is installed (Only for MacOS)
if [ "$OS_NAME" = "Darwin" ]; then
    if ! $(command -v tmux > /dev/null); then
        echo "Installing tmux..."
        $(brew --prefix)/bin/brew install tmux
    else
        echo "tmux is already installed. Skipping..."
    fi
fi

# check if fzf is installed
if [ ! -f ~/.fzf.bash ] && [ ! -f ~/.fzf.zsh ]; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
else
    echo "fzf is already installed. Skipping..."
fi

## check if pyenv is installed
#if [ ! -d ~/.pyenv ]; then
#    echo "Installing pyenv..."
#    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
#    git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
#else
#    echo "pyenv is already installed. Skipping..."
#fi

# check if the vim plugin folders exist
if [ ! -d ~/.vim/bundle ]; then
    mkdir -p ~/.vim/bundle
fi

# check if the pathogen vim plugin is installed
if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
    curl -fLSso ~/.vim/autoload/pathogen.vim --create-dirs https://tpo.pe/pathogen.vim
fi

# Check if the "plug" vim plugin is installed
if [ ! -f ~/.vim/autoload/plug.vim ]; then
    curl -fLSso ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# populate config files
for FILE in .gitconfig .tmux.conf .vimrc .zlogin .zsh_aliases .zshenv .zshrc; do
    if [ -f ~/${FILE} -o -L ~/${FILE} ] && [ $FORCED -eq 0 ]; then
        # Check if this is executed from a devcontainer
        if ! $(command -v devcontainer-info > /dev/null); then
            confirm "Overwriting '${HOME}/${FILE}'. Are you sure? [y/N]" && replace $FILE
        else
            replace $FILE
        fi
    else
        replace $FILE
    fi
done
