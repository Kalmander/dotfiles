" Gert til að hafa tex syntax highlighting með vimwiki
" if exists('b:current_syntax')
"   unlet b:current_syntax
" endif
" syn include @tex syntax/tex.vim
" syn region markdownMath start="\\\@<!\$" end="\$" skip="\\\$" contains=@tex keepend
" syn region markdownMath start="\\\@<!\$\$" end="\$\$" skip="\\\$" contains=@tex keepend
" let b:current_syntax = 'markdown'



" Tekið úr wiki-ft eftir levarg til að fá concealing á wiki links
" Þarf virkilega að skilja betur virðist bara virka ef línan byrjar á 
" ákveðnum hlutum eins og bullet point
" Add syntax groups and clusters for links
for [s:group, s:type; s:contained] in [
      \ ['wikiLinkUrl',       'url',            'wikiConcealLink'],
      \ ['wikiLinkUrl',       'shortcite'],
      \ ['wikiLinkWiki',      'wiki',           'wikiConcealLinkWiki'],
      \ ['wikiLinkRef',       'ref_shortcut'],
      \ ['wikiLinkRef',       'ref_full',       'wikiConcealLinkRef'],
      \ ['wikiLinkRefTarget', 'ref_definition', 'wikiLinkUrl'],
      \ ['wikiLinkMd',        'md',             'wikiConcealLinkMd'],
      \ ['wikiLinkMdImg',     'md_fig',         'wikiConcealLinkMdImg'],
      \ ['wikiLinkDate',      'date'],
      \]
  let s:rx = wiki#link#{s:type}#matcher().rx
  execute 'syntax cluster wikiLink  add=' . s:group
  execute 'syntax match' s:group
        \ '/' . s:rx . '/'
        \ 'display contains=@NoSpell'
        \ . (empty(s:contained) ? '' : ',' . join(s:contained, ','))

  call filter(s:contained, 'v:val !~# ''Conceal''')
  execute 'syntax match' s:group . 'T'
        \ '/' . s:rx . '/'
        \ 'display contained contains=@NoSpell'
        \ . (empty(s:contained) ? '' : ',' . join(s:contained, ','))
endfor

" Proper matching of bracketed urls
syntax match wikiLinkUrl "<\l\+:\%(\/\/\)\?[^>]\+>"
      \ display contains=@NoSpell,wikiConcealLink

syntax match wikiConcealLinkUrl
      \ `\%(///\=[^/ \t]\+/\)\zs\S\+\ze\%([/#?]\w\|\S\{15}\)`
      \ cchar=~ contained transparent contains=NONE conceal
syntax match wikiConcealLinkWiki /\[\[\%(\/\|#\)\?\%([^\\\]]\{-}|\)\?/
      \ contained transparent contains=NONE conceal
syntax match wikiConcealLinkWiki /\]\]/
      \ contained transparent contains=NONE conceal
syntax match wikiConcealLinkMd /\[/
      \ contained transparent contains=NONE conceal
syntax match wikiConcealLinkMd /\]([^\\]\{-})/
      \ contained transparent contains=NONE conceal
syntax match wikiConcealLinkMdImg /!\[/
      \ contained transparent contains=NONE conceal
syntax match wikiConcealLinkMdImg /\]([^\\]\{-})/
      \ contained transparent contains=NONE conceal
syntax match wikiConcealLinkRef /[\]\[]\@<!\[/
      \ contained transparent contains=NONE conceal
syntax match wikiConcealLinkRef /\]\[[^\\\[\]]\{-}\]/
      \ contained transparent contains=NONE conceal

highlight default link wikiLinkUrl ModeMsg
" highlight default link wikiLinkWiki Underlined
" highlight default link wikiLinkMd Underlined
highlight default link wikiLinkMdImg MoreMsg
" highlight default link wikiLinkRef Underlined
" highlight default link wikiLinkRefTarget Underlined
highlight default link wikiLinkDate MoreMsg




" Tekið af netinu fyrir concealment á checkboxes
syntax match todoCheckbox '\v\s*(-? \[[ X\.!\*]\])' contains=finishedCheckbox,unfinishexCheckbox,flaggedCheckbox,starredCheckbox
syntax match finishedCheckbox '\v(-? \[[ \.]\])' conceal cchar=
syntax match unfinishexCheckbox '\v(-? \[X\])' conceal cchar=✔
syntax match unfinishexCheckbox '\v(-? \[x\])' conceal cchar=✗
hi link todoCheckbox Todo


" hi Pomodoro guifg=#fc5d7c
" match Pomodoro '🍅'
