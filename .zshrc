export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git zsh-autosuggestions vi-mode)

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

bindkey -v

export PATH="$PATH:$HOME/.local/bin"
export SSH_FILE_NAME=id_ed25519
export PATH=/home/karthik-kalidas/.opencode/bin:$PATH
