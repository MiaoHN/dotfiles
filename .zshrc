# ---------------------------------------------
# Automatically install zinit
# ---------------------------------------------

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ---------------------------------------------
# Custom alias
# ---------------------------------------------


alias ls="ls --color"
alias lg="lazygit"
alias c="clear"

# ---------------------------------------------
# Custom export
# ---------------------------------------------

export VISUAL=nvim
export EDITOR=nvim

# ---------------------------------------------
# Zinit plugins
# ---------------------------------------------

zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-autosuggestions
zinit light agkozak/zsh-z
zinit light hcgraf/zsh-sudo

# ---------------------------------------------
# Setup conda
# ---------------------------------------------

export CONDA_PATH="$HOME/.anaconda3"

if [ -d $CONDA_PATH ]; then
  __conda_setup="$('$CONDA_PATH/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  else
    if [ -f "$CONDA_PATH/etc/profile.d/conda.sh" ]; then
      . "$CONDA_PATH/etc/profile.d/conda.sh"
    else
      export PATH="$CONDA_PATH/bin:$PATH"
    fi
  fi
  unset __conda_setup
fi

# ---------------------------------------------
# Setup nvm
# ---------------------------------------------

export NVM_DIR="$HOME/.nvm"

if [ -d $NVM_PATH ]; then
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

eval "$(fzf --zsh)"

# Golang setup
export GOPATH="$HOME/go"
export PATH="$PATH:$(go env GOBIN):$(go env GOPATH)/bin"
