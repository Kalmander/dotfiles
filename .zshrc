# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# >>> Oh My Zsh >>>
ZSH="$HOME/.oh-my-zsh"

#Theme
# ZSH_THEME=""
# Powerlevel 10k (líklega ekki nota sama tíma og starship)
ZSH_THEME="powerlevel10k/powerlevel10k"

#Plugins
plugins=(zsh-autosuggestions)
# plugins+=(zsh-vi-mode)
plugins+=(colored-man-pages)

source $ZSH/oh-my-zsh.sh
# <<< Oh My Zsh <<<
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#757575'

# vildi samþykkja autosuggest með ctrl+; sem er 
# einn af þessum venses keycode tökkum svo ég lét kitty
# senda F10 þegar ég ýti á ctrl+; og stilly svo hér 
# F10 (sem hefur þennan keycode) á autosuggest-accept
bindkey '\x1b[21~' autosuggest-accept

#Star Ship
# eval "$(starship init zsh)"


# # >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('$HOME/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "$HOME/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="$HOME/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<


# jó stilla environment variables frekar 
# í /etc/environment
# export EDITOR='nvim'
export VISUAL='nvim'
export ZVM_VI_EDITOR='nvim'
zvm_vi_yank () {
	zvm_yank
	printf %s "${CUTBUFFER}" |  wl-copy -n
	zvm_exit_visual_mode
}
my_zvm_vi_yank() {
  zvm_vi_yank
  echo -en "${CUTBUFFER}" | wl-copy -n

}

my_zvm_vi_delete() {
  zvm_vi_delete
  echo -en "${CUTBUFFER}" | wl-copy -n
}

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
alias lf=ld

export FZF_DEFAULT_COMMAND="rg --files --hidden -g !'**/thumbnails_seekbar/**' -g !'**/backups/backup/**'"

# Aliases
alias icat="kitty +kitten icat"
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
alias how2='npx how2 -s'
alias cal='calcurse -C ~/hrafnatinna/dagatal/calcurse_config -D ~/hrafnatinna/dagatal/calcurse_data && python ~/hrafnatinna/dagatal/curse2vim.py'
alias zz='nvim $HOME/.zshrc'
alias zzs='source $HOME/.zshrc'
alias hh='nvim $HOME/.config/hypr/hyprland.conf'
alias cvim='nvim $HOME/.config/nvim/init.lua'
alias leitner='nvim $HOME/hrafnatinna/leitner_kanban.md'
alias cpv='nvim $HOME/.config/mpv'
alias bc='bc -l'
alias mpdmpd='mpd && mpDris2 & ncmpcpp'
alias ls='exa'
alias ll='exa -l'

function nman() {
  nvim -c "Man $1" +only
}

function y() {
  python ~/scripts/master_ytdl_script.py $1	
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# alias pip="python -m pip"
# ow (other writable) í ls er unreadable með venjulega græna bakgruninum (42) sem ég breytti í 40 (sem er svart)
# Eftirfarandi LS_COLORS er molokai þemað í forritinu vivid (sem var á pacman)
export LS_COLORS=$(vivid generate mittokai)

# source $HOME/.config/broot/launcher/bash/br

LFCD="$GOPATH/src/github.com/gokcehan/lf/etc/lfcd.sh"  # source
LFCD="/path/to/lfcd.sh"                                #  pre-built binary, make sure to use absolute path
if [ -f "$LFCD" ]; then
	    source "$LFCD"
fi

PATH=$PATH:~/.local/bin/


# Fish like navigation
function my-redraw-prompt() {
  {
    builtin echoti civis
    builtin local f
    for f in chpwd "${chpwd_functions[@]}" precmd "${precmd_functions[@]}"; do
      (( ! ${+functions[$f]} )) || "$f" &>/dev/null || builtin true
    done
    builtin zle reset-prompt
  } always {
    builtin echoti cnorm
  }
}

function my-cd-rotate() {
  () {
    builtin emulate -L zsh
    while (( $#dirstack )) && ! builtin pushd -q $1 &>/dev/null; do
      builtin popd -q $1
    done
    (( $#dirstack ))
  } "$@" && my-redraw-prompt
}

function my-cd-up()      { builtin cd -q .. && my-redraw-prompt; }
function my-cd-back()    { my-cd-rotate +1; }
function my-cd-forward() { my-cd-rotate -0; }

builtin zle -N my-cd-up
builtin zle -N my-cd-back
builtin zle -N my-cd-forward

() {
  builtin local keymap
  for keymap in emacs viins vicmd; do
    builtin bindkey '^[^[[A'  my-cd-up
    builtin bindkey '^[[1;3A' my-cd-up
    builtin bindkey '^[[1;9A' my-cd-up
    builtin bindkey '^[^[[D'  my-cd-back
    builtin bindkey '^[[1;3D' my-cd-back
    builtin bindkey '^[[1;9D' my-cd-back
    builtin bindkey '^[^[[C'  my-cd-forward
    builtin bindkey '^[[1;3C' my-cd-forward
    builtin bindkey '^[[1;9C' my-cd-forward
  done
}

setopt auto_pushd
# Fish navigation end

[[ -s "$HOME/.qfc/bin/qfc.sh" ]] && source "$HOME/.qfc/bin/qfc.sh"
# export DMENU='rofi -config $HOME/.config/rofi/alt_config.rasi -dmenu'
export DMENU='rofi -dmenu'
