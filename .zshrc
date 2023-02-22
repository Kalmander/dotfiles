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

export FZF_DEFAULT_COMMAND="rg --files --hidden -g !'**/thumbnails_seekbar/**' -g !'**/backups/backup/**'"

# Aliases
alias icat="kitty +kitten icat"
alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
alias how2='npx how2 -s'
alias cal='calcurse -C ~/hrafnatinna/dagatal/calcurse_config -D ~/hrafnatinna/dagatal/calcurse_data && python ~/hrafnatinna/dagatal/curse2vim.py'
alias zz='nvim $HOME/.zshrc'
alias zzs='source $HOME/.zshrc'
alias cvim='nvim $HOME/.config/nvim/init.lua'
alias leitner='nvim $HOME/hrafnatinna/leitner_kanban.md'
alias cpv='nvim $HOME/.config/mpv'
alias bc='bc -l'

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
export LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;40:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.swp=00;90:*.tmp=00;90:*.dpkg-dist=00;90:*.dpkg-old=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:"

source $HOME/.config/broot/launcher/bash/br

LFCD="$GOPATH/src/github.com/gokcehan/lf/etc/lfcd.sh"  # source
LFCD="/path/to/lfcd.sh"                                #  pre-built binary, make sure to use absolute path
if [ -f "$LFCD" ]; then
	    source "$LFCD"
fi



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
