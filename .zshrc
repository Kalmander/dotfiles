# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# >>> Oh My Zsh >>>
ZSH="/home/kalman/.oh-my-zsh"

#Theme
# ZSH_THEME=""
# Powerlevel 10k (líklega ekki nota sama tíma og starship)
ZSH_THEME="powerlevel10k/powerlevel10k"

#Plugins
plugins=(git zsh-autosuggestions)
plugins+=(zsh-vi-mode)

source $ZSH/oh-my-zsh.sh
# <<< Oh My Zsh <<<


#Star Ship
# eval "$(starship init zsh)"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/kalman/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/kalman/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/kalman/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/kalman/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


eval "$(zoxide init zsh)"
export PAGER=nvimpager


# Aliases
# alias texs="nvim ~/Dropbox/Latex/"
# alias nvim="VIMRUNTIME=~/repos/neovim/runtime ~/repos/neovim/build/bin/nvim"
# alias tvim="nvim --cmd 'let g:sonokai_transparent_background = 2'"
alias icat="kitty +kitten icat"
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
