#!/bin/bash
set -euo pipefail

OS_NAME=`uname -s`

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
        exit 1
    fi

    if [ -f ${OS_NAME}/${FILE} ]; then
        FILE="${OS_NAME}/${FILE}"
    fi

    if [ -f ~/$1 ]; then
        rm ~/$1
    fi
    ln -s $FILE ~/$1
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
    if [ ! -f $(/usr/local/bin/brew --prefix)/etc/bash_completion ]; then
        echo "Installing bash-completion..."
        /usr/local/bin/brew install bash-completion
    else
        echo "bash-completion is already installed. Skipping..."
    fi
fi

# check if coreutils is installed (Only for MacOS)
if [ "$OS_NAME" = "Darwin" ]; then
    if ! $(command -v gls > /dev/null); then
        echo "Installing coreutils..."
        /usr/local/bin/brew install coreutils
    else
        echo "coreutils is already installed. Skipping..."
    fi
fi

# check if tmux is installed (Only for MacOS)
if [ "$OS_NAME" = "Darwin" ]; then
    if ! $(command -v tmux > /dev/null); then
        echo "Installing tmux..."
        /usr/local/bin/brew install tmux
    else
        echo "tmux is already installed. Skipping..."
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
    else
        replace $FILE
    fi
done
