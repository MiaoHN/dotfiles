#!/bin/bash

# $1: src, $2: tgt, $3: bak
setup() {
	if [ -L $1 ]; then
		rm $1
		echo -e "\033[37mremove symbolic '$1'\033[0m"
	elif [ -f $1 ] || [ -d $1 ]; then
		mv $1 $3 -r
		echo -e "\033[37mmove '$1' to '$3'\033[0m"
	fi
	ln -s $2 $1
	echo -e "\033[32msuccessfully setup '$1'\033[0m"
}

CURRENT_DIR=$(
	cd "$(dirname "$0")"
	pwd
)

mkdir -p ./.backup
setup ~/.vimrc $CURRENT_DIR/.vimrc ./backup/.vimrc
setup ~/.condarc $CURRENT_DIR/.condarc ./backup/.condarc
setup ~/.zshrc $CURRENT_DIR/.zshrc ./backup/.zshrc
setup ~/.config/nvim $CURRENT_DIR/nvim ./backup/nvim
