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
export LS_COLORS="ow=0:ca=0:st=0:tw=0:or=0;38;2;0;0;0;48;2;255;74;68:no=0:di=0;38;2;102;217;239:do=0;38;2;0;0;0;48;2;249;38;114:cd=0;38;2;249;38;114;48;2;51;51;51:sg=0:mi=0;38;2;0;0;0;48;2;255;74;68:mh=0:pi=0;38;2;0;0;0;48;2;102;217;239:so=0;38;2;0;0;0;48;2;249;38;114:ln=0;38;2;249;38;114:*~=0;38;2;122;112;112:bd=0;38;2;102;217;239;48;2;51;51;51:ex=1;38;2;249;38;114:fi=0:su=0:rs=0:*.d=0;38;2;0;255;135:*.c=0;38;2;0;255;135:*.h=0;38;2;0;255;135:*.a=1;38;2;249;38;114:*.z=4;38;2;249;38;114:*.m=0;38;2;0;255;135:*.p=0;38;2;0;255;135:*.r=0;38;2;0;255;135:*.o=0;38;2;122;112;112:*.t=0;38;2;0;255;135:*.gv=0;38;2;0;255;135:*.ts=0;38;2;0;255;135:*.hs=0;38;2;0;255;135:*.di=0;38;2;0;255;135:*.cs=0;38;2;0;255;135:*.hi=0;38;2;122;112;112:*.md=0;38;2;226;209;57:*.cc=0;38;2;0;255;135:*.jl=0;38;2;0;255;135:*.so=1;38;2;249;38;114:*.ll=0;38;2;0;255;135:*.py=0;38;2;0;255;135:*.el=0;38;2;0;255;135:*.ko=1;38;2;249;38;114:*.cr=0;38;2;0;255;135:*.nb=0;38;2;0;255;135:*.rs=0;38;2;0;255;135:*.pl=0;38;2;0;255;135:*.as=0;38;2;0;255;135:*.rm=0;38;2;253;151;31:*css=0;38;2;0;255;135:*.la=0;38;2;122;112;112:*.ex=0;38;2;0;255;135:*.gz=4;38;2;249;38;114:*.bz=4;38;2;249;38;114:*.td=0;38;2;0;255;135:*.7z=4;38;2;249;38;114:*.pp=0;38;2;0;255;135:*.pm=0;38;2;0;255;135:*.ps=0;38;2;230;219;116:*.bc=0;38;2;122;112;112:*.ui=0;38;2;166;226;46:*.xz=4;38;2;249;38;114:*.sh=0;38;2;0;255;135:*.cp=0;38;2;0;255;135:*.kt=0;38;2;0;255;135:*.ml=0;38;2;0;255;135:*.js=0;38;2;0;255;135:*.rb=0;38;2;0;255;135:*.go=0;38;2;0;255;135:*.lo=0;38;2;122;112;112:*.vb=0;38;2;0;255;135:*.fs=0;38;2;0;255;135:*.hh=0;38;2;0;255;135:*.mn=0;38;2;0;255;135:*.wv=0;38;2;253;151;31:*.psd=0;38;2;253;151;31:*.pid=0;38;2;122;112;112:*.flv=0;38;2;253;151;31:*.exs=0;38;2;0;255;135:*hgrc=0;38;2;166;226;46:*.eps=0;38;2;253;151;31:*.xmp=0;38;2;166;226;46:*.ppm=0;38;2;253;151;31:*.png=0;38;2;253;151;31:*.bz2=4;38;2;249;38;114:*.deb=4;38;2;249;38;114:*.c++=0;38;2;0;255;135:*.mpg=0;38;2;253;151;31:*.pps=0;38;2;230;219;116:*.mp4=0;38;2;253;151;31:*.otf=0;38;2;253;151;31:*.yml=0;38;2;166;226;46:*.odt=0;38;2;230;219;116:*.clj=0;38;2;0;255;135:*.awk=0;38;2;0;255;135:*.php=0;38;2;0;255;135:*.lua=0;38;2;0;255;135:*.sxi=0;38;2;230;219;116:*.elm=0;38;2;0;255;135:*.epp=0;38;2;0;255;135:*.bak=0;38;2;122;112;112:*.sql=0;38;2;0;255;135:*.csx=0;38;2;0;255;135:*.pdf=0;38;2;230;219;116:*.mov=0;38;2;253;151;31:*.zip=4;38;2;249;38;114:*.git=0;38;2;122;112;112:*.inl=0;38;2;0;255;135:*.idx=0;38;2;122;112;112:*.pbm=0;38;2;253;151;31:*.vcd=4;38;2;249;38;114:*.xlr=0;38;2;230;219;116:*.bmp=0;38;2;253;151;31:*.erl=0;38;2;0;255;135:*.mkv=0;38;2;253;151;31:*.ps1=0;38;2;0;255;135:*.mid=0;38;2;253;151;31:*.def=0;38;2;0;255;135:*.kex=0;38;2;230;219;116:*.ltx=0;38;2;0;255;135:*.xls=0;38;2;230;219;116:*.asa=0;38;2;0;255;135:*.cpp=0;38;2;0;255;135:*.dmg=4;38;2;249;38;114:*.vob=0;38;2;253;151;31:*.bat=1;38;2;249;38;114:*.bcf=0;38;2;122;112;112:*.tif=0;38;2;253;151;31:*.pod=0;38;2;0;255;135:*.vim=0;38;2;0;255;135:*.fsi=0;38;2;0;255;135:*.bst=0;38;2;166;226;46:*.htc=0;38;2;0;255;135:*.ico=0;38;2;253;151;31:*.blg=0;38;2;122;112;112:*.rpm=4;38;2;249;38;114:*.dot=0;38;2;0;255;135:*.zsh=0;38;2;0;255;135:*.xml=0;38;2;226;209;57:*.cfg=0;38;2;166;226;46:*.bib=0;38;2;166;226;46:*.inc=0;38;2;0;255;135:*.ogg=0;38;2;253;151;31:*.jar=4;38;2;249;38;114:*.ods=0;38;2;230;219;116:*.ppt=0;38;2;230;219;116:*.tar=4;38;2;249;38;114:*.tmp=0;38;2;122;112;112:*.tbz=4;38;2;249;38;114:*.rst=0;38;2;226;209;57:*.pyc=0;38;2;122;112;112:*.xcf=0;38;2;253;151;31:*.doc=0;38;2;230;219;116:*TODO=1:*.fnt=0;38;2;253;151;31:*.wav=0;38;2;253;151;31:*.pyo=0;38;2;122;112;112:*.h++=0;38;2;0;255;135:*.tsx=0;38;2;0;255;135:*.m4a=0;38;2;253;151;31:*.sty=0;38;2;122;112;112:*.pkg=4;38;2;249;38;114:*.tgz=4;38;2;249;38;114:*.odp=0;38;2;230;219;116:*.rar=4;38;2;249;38;114:*.mir=0;38;2;0;255;135:*.sbt=0;38;2;0;255;135:*.dox=0;38;2;166;226;46:*.sxw=0;38;2;230;219;116:*.hxx=0;38;2;0;255;135:*.iso=4;38;2;249;38;114:*.jpg=0;38;2;253;151;31:*.pyd=0;38;2;122;112;112:*.dll=1;38;2;249;38;114:*.m4v=0;38;2;253;151;31:*.ilg=0;38;2;122;112;112:*.zst=4;38;2;249;38;114:*.svg=0;38;2;253;151;31:*.bsh=0;38;2;0;255;135:*.fsx=0;38;2;0;255;135:*.ipp=0;38;2;0;255;135:*.pas=0;38;2;0;255;135:*.csv=0;38;2;226;209;57:*.dpr=0;38;2;0;255;135:*.swf=0;38;2;253;151;31:*.pro=0;38;2;166;226;46:*.mli=0;38;2;0;255;135:*.txt=0;38;2;226;209;57:*.cgi=0;38;2;0;255;135:*.ttf=0;38;2;253;151;31:*.log=0;38;2;122;112;112:*.tcl=0;38;2;0;255;135:*.wma=0;38;2;253;151;31:*.bag=4;38;2;249;38;114:*.cxx=0;38;2;0;255;135:*.avi=0;38;2;253;151;31:*.hpp=0;38;2;0;255;135:*.ini=0;38;2;166;226;46:*.fls=0;38;2;122;112;112:*.com=1;38;2;249;38;114:*.kts=0;38;2;0;255;135:*.htm=0;38;2;226;209;57:*.arj=4;38;2;249;38;114:*.tml=0;38;2;166;226;46:*.fon=0;38;2;253;151;31:*.wmv=0;38;2;253;151;31:*.bbl=0;38;2;122;112;112:*.pgm=0;38;2;253;151;31:*.aif=0;38;2;253;151;31:*.apk=4;38;2;249;38;114:*.aux=0;38;2;122;112;112:*.out=0;38;2;122;112;112:*.gvy=0;38;2;0;255;135:*.toc=0;38;2;122;112;112:*.ind=0;38;2;122;112;112:*.nix=0;38;2;166;226;46:*.rtf=0;38;2;230;219;116:*.bin=4;38;2;249;38;114:*.gif=0;38;2;253;151;31:*.tex=0;38;2;0;255;135:*.mp3=0;38;2;253;151;31:*.swp=0;38;2;122;112;112:*.img=4;38;2;249;38;114:*.exe=1;38;2;249;38;114:*.ics=0;38;2;230;219;116:*.epub=0;38;2;230;219;116:*.xlsx=0;38;2;230;219;116:*.tiff=0;38;2;253;151;31:*.bash=0;38;2;0;255;135:*.dart=0;38;2;0;255;135:*.opus=0;38;2;253;151;31:*.psd1=0;38;2;0;255;135:*.lock=0;38;2;122;112;112:*.mpeg=0;38;2;253;151;31:*.yaml=0;38;2;166;226;46:*.orig=0;38;2;122;112;112:*.html=0;38;2;226;209;57:*.rlib=0;38;2;122;112;112:*.psm1=0;38;2;0;255;135:*.lisp=0;38;2;0;255;135:*.conf=0;38;2;166;226;46:*.toml=0;38;2;166;226;46:*.java=0;38;2;0;255;135:*.less=0;38;2;0;255;135:*.tbz2=4;38;2;249;38;114:*.hgrc=0;38;2;166;226;46:*.fish=0;38;2;0;255;135:*.h264=0;38;2;253;151;31:*.jpeg=0;38;2;253;151;31:*.json=0;38;2;166;226;46:*.docx=0;38;2;230;219;116:*.diff=0;38;2;0;255;135:*.make=0;38;2;166;226;46:*.flac=0;38;2;253;151;31:*.pptx=0;38;2;230;219;116:*.webm=0;38;2;253;151;31:*.purs=0;38;2;0;255;135:*.swift=0;38;2;0;255;135:*passwd=0;38;2;166;226;46:*.class=0;38;2;122;112;112:*.cmake=0;38;2;166;226;46:*.ipynb=0;38;2;0;255;135:*.mdown=0;38;2;226;209;57:*.toast=4;38;2;249;38;114:*.cache=0;38;2;122;112;112:*.patch=0;38;2;0;255;135:*.xhtml=0;38;2;226;209;57:*shadow=0;38;2;166;226;46:*.scala=0;38;2;0;255;135:*README=0;38;2;0;0;0;48;2;230;219;116:*.cabal=0;38;2;0;255;135:*.dyn_o=0;38;2;122;112;112:*.shtml=0;38;2;226;209;57:*.matlab=0;38;2;0;255;135:*.groovy=0;38;2;0;255;135:*LICENSE=0;38;2;182;182;182:*.ignore=0;38;2;166;226;46:*.flake8=0;38;2;166;226;46:*INSTALL=0;38;2;0;0;0;48;2;230;219;116:*TODO.md=1:*COPYING=0;38;2;182;182;182:*.dyn_hi=0;38;2;122;112;112:*.config=0;38;2;166;226;46:*.gradle=0;38;2;0;255;135:*TODO.txt=1:*Makefile=0;38;2;166;226;46:*.gemspec=0;38;2;166;226;46:*Doxyfile=0;38;2;166;226;46:*setup.py=0;38;2;166;226;46:*.desktop=0;38;2;166;226;46:*.cmake.in=0;38;2;166;226;46:*.fdignore=0;38;2;166;226;46:*.markdown=0;38;2;226;209;57:*.rgignore=0;38;2;166;226;46:*configure=0;38;2;166;226;46:*README.md=0;38;2;0;0;0;48;2;230;219;116:*.DS_Store=0;38;2;122;112;112:*.kdevelop=0;38;2;166;226;46:*COPYRIGHT=0;38;2;182;182;182:*Dockerfile=0;38;2;166;226;46:*INSTALL.md=0;38;2;0;0;0;48;2;230;219;116:*.gitconfig=0;38;2;166;226;46:*.gitignore=0;38;2;166;226;46:*README.txt=0;38;2;0;0;0;48;2;230;219;116:*SConscript=0;38;2;166;226;46:*CODEOWNERS=0;38;2;166;226;46:*.localized=0;38;2;122;112;112:*SConstruct=0;38;2;166;226;46:*.scons_opt=0;38;2;122;112;112:*.travis.yml=0;38;2;230;219;116:*Makefile.am=0;38;2;166;226;46:*.gitmodules=0;38;2;166;226;46:*LICENSE-MIT=0;38;2;182;182;182:*.synctex.gz=0;38;2;122;112;112:*MANIFEST.in=0;38;2;166;226;46:*INSTALL.txt=0;38;2;0;0;0;48;2;230;219;116:*Makefile.in=0;38;2;122;112;112:*configure.ac=0;38;2;166;226;46:*.applescript=0;38;2;0;255;135:*appveyor.yml=0;38;2;230;219;116:*CONTRIBUTORS=0;38;2;0;0;0;48;2;230;219;116:*.fdb_latexmk=0;38;2;122;112;112:*.clang-format=0;38;2;166;226;46:*.gitattributes=0;38;2;166;226;46:*CMakeCache.txt=0;38;2;122;112;112:*LICENSE-APACHE=0;38;2;182;182;182:*CMakeLists.txt=0;38;2;166;226;46:*CONTRIBUTORS.md=0;38;2;0;0;0;48;2;230;219;116:*requirements.txt=0;38;2;166;226;46:*CONTRIBUTORS.txt=0;38;2;0;0;0;48;2;230;219;116:*.sconsign.dblite=0;38;2;122;112;112:*package-lock.json=0;38;2;122;112;112:*.CFUserTextEncoding=0;38;2;122;112;112"

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
