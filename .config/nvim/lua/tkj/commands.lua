-- Opnar netrw án hiks
vim.api.nvim_create_user_command('SE', 'silent E', {})

-- gerir :H til að opna help í venjulegum buffer
vim.cmd([[
function! s:help(subject)
  let buftype = &buftype
  let &buftype = 'help'
  let v:errmsg = ''
  let cmd = "help " . a:subject
  silent! execute  cmd
  if v:errmsg != ''
    let &buftype = buftype
    return cmd
  else
    call setbufvar('#', '&buftype', buftype)
  endif
  set buflisted 
endfunction
command! -nargs=? -bar -complete=help H execute <SID>help(<q-args>)
]])

vim.cmd([[
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
]])

vim.cmd([[
command! -nargs=? Filter let @a='' | execute 'g/<args>/y A' | new | setlocal bt=nofile | put! a
]])
