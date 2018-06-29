#!/bin/bash
set -euo pipefail

OS_NAME=`uname -s`

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
        exit 1
    fi

    if [ -f ${OS_NAME}/${FILE} ]; then
        FILE="${OS_NAME}/${FILE}"
    fi
    cp $FILE ~/$1
    echo "Copied ${FILE}."
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

# check if fzf is installed
if [ ! -f ~/.fzf.bash -o ! -f ~/.fzf.zsh ]; then
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
else
    echo "fzf is already installed. Skipping..."
fi

# check if pyenv is installed
if [ ! -d ~/.pyenv ]; then
    echo "Installing pyenv..."
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
else
    echo "pyenv is already installed. Skipping..."
fi

# populate config files
for FILE in .gitconfig .tmux.conf .vimrc .zshrc; do
    if [ -f ~/${FILE} ]; then
        confirm "Overwriting '${HOME}/${FILE}'. Are you sure? [y/N]" && replace $FILE
    fi
done