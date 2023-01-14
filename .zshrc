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
# plugins=(git zsh-autosuggestions)
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


export EDITOR='nvim'
export VISUAL='nvim'
export ZVM_VI_EDITOR='nvim'
zvm_vi_yank () {
	zvm_yank
	printf %s "${CUTBUFFER}" |  wl-copy -n
	zvm_exit_visual_mode
}
# my_zvm_vi_yank() {
#   zvm_vi_yank
#   echo -en "${CUTBUFFER}" | wl-copy -n
#
# }
#
# my_zvm_vi_delete() {
#   zvm_vi_delete
#   echo -en "${CUTBUFFER}" | wl-copy -n
# }
#
# my_zvm_vi_change() {
#   zvm_vi_change
#   echo -en "${CUTBUFFER}" | wl-copy -n
# }
#
# my_zvm_vi_change_eol() {
#   zvm_vi_change_eol
#   echo -en "${CUTBUFFER}" | wl-copy -n
# }
#
my_zvm_vi_put_after() {
  CUTBUFFER=$(wl-paste)
  zvm_vi_put_after
  zvm_highlight clear # zvm_vi_put_after introduces weird highlighting for me
}

my_zvm_vi_put_before() {
  CUTBUFFER=$(wl-paste)
  zvm_vi_put_before
  zvm_highlight clear # zvm_vi_put_before introduces weird highlighting for me
}
#
zvm_after_lazy_keybindings() {
#   zvm_define_widget my_zvm_vi_yank
#   zvm_define_widget my_zvm_vi_delete
#   zvm_define_widget my_zvm_vi_change
#   zvm_define_widget my_zvm_vi_change_eol
  zvm_define_widget my_zvm_vi_put_after
  zvm_define_widget my_zvm_vi_put_before
#
#   zvm_bindkey visual 'y' my_zvm_vi_yank
#   zvm_bindkey visual 'd' my_zvm_vi_delete
#   zvm_bindkey visual 'x' my_zvm_vi_delete
#   zvm_bindkey vicmd  'C' my_zvm_vi_change_eol
#   zvm_bindkey visual 'c' my_zvm_vi_change
  zvm_bindkey vicmd  'p' my_zvm_vi_put_after
  zvm_bindkey vicmd  'P' my_zvm_vi_put_before
}


LFCD="$HOME/.config/lf/lfcd.sh"
if [ -f "$LFCD" ]; then
        source "$LFCD"
fi

export FZF_DEFAULT_COMMAND="rg --files --hidden -g !'**/thumbnails_seekbar/**' -g !'**/backups/backup/**'"

# Aliases
alias icat="kitty +kitten icat"
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
alias how2='npx how2 -s'


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
