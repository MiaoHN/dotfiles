#!/bin/bash

setup() {
	src=$1
	tgt=$2
	bak=$3
	if [ ! -e "$tgt" ]; then
		echo "ERROR in setup: $tgt does not exist."
		return
	fi
	if [ -L $src ]; then
		rm $src
	elif [ -f $src ] || [ -d $src ]; then
		mv $src $bak
	fi
	ln -s $tgt $src
}

logo() {
	echo -e "\033[31m ____        _    __ _ _            \033[0m"
	echo -e "\033[32m|  _ \  ___ | |_ / _(_) | ___  ___  \033[0m"
	echo -e "\033[33m| | | |/ _ \| __| |_| | |/ _ \/ __| \033[0m"
	echo -e "\033[34m| |_| | (_) | |_|  _| | |  __/\__ \ \033[0m"
	echo -e "\033[35m|____/ \___/ \__|_| |_|_|\___||___/ \033[0m"
}

main() {
	current_dir=$(
		cd "$(dirname "$0")"
		pwd
	)

	backup_dir="$current_dir/.backup/"

	mkdir -p "$backup_dir"
	if [ "$1" == "all" ]; then
		files=("~/.vimrc" "~/.condarc" "~/.zshrc" "~/.tmux.conf" "~/.config/nvim" "~/.config/ranger")
	elif [ "$1" == "vim" ]; then
		files=("~/.vimrc")
	elif [ "$1" == "conda" ]; then
		files=("~/.condarc")
	elif [ "$1" == "zsh" ]; then
		files=("~/.zshrc")
	elif [ "$1" == "tmux" ]; then
		files=("~/.tmux.conf")
	elif [ "$1" == "nvim" ]; then
		files=("~/.config/nvim")
	elif [ "$1" == "ranger" ]; then
		files=("~/.config/ranger")
	else
		files=()
		echo "Nothing to setup"
	fi

	for filepath in ${files[@]}; do
		echo "Setup" $filepath
		filepath=$(eval echo "$filepath")
		fname=$(basename $filepath)
		setup $filepath $current_dir/$fname $backup_dir/$fname
	done

	logo
	echo "Author: MiaoHN"
	echo "Github: https://github.com/MiaoHN"
	echo "Backup dir: $backup_dir"
}

main $@
