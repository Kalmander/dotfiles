vim.opt_local.keymap = "icelandic"
vim.keymap.set({"x", "o"}, "iq", ":<c-u>normal! g_vF]2l<cr>", {silent=true})
vim.keymap.set("n", "<leader>gp", "mygg/mynd:<CR><cmd>noh<cr>2w<cmd>silent !vimiv -s statusbar.show false -f <cfile><CR>`y<cmd>echo <CR>", { silent = true, buffer = 0 })

local filename = vim.api.nvim_buf_get_name(0)
if filename:match("kanban") then
	vim.keymap.set("n", "o", "o<esc>Di- [ ] ", { noremap = true, silent = true, buffer = 0 })
	vim.keymap.set("n", "O", "O<esc>Di- [ ] ", { noremap = true, silent = true, buffer = 0 })
	vim.keymap.set("n", "[[", "<Plug>Markdown_MoveToPreviousHeader|j", { noremap = true, silent = true, buffer = 0 })
	vim.keymap.set("n", "]]", "<Plug>Markdown_MoveToNextHeader|j", { noremap = true, silent = true, buffer = 0 })
end
if filename:match("hrafnatinna") then
        -- hendir línu neðst í næsta eða fyrra ## heading
	-- stylua: ignore start
        vim.keymap.set( "n", "<a-]>", [[dd:<C-u>call search('##', 's')<CR>:call search('##')<CR>:<C-u>call search('^.\+', 'b')<CR>p''zt]], { noremap = true, silent = true, buffer = 0 })
        vim.keymap.set( "n", "<a-[>", [[dd:<C-u>call search('##', 'bs')<CR>:<C-u>call search('^.\+', 'b')<CR>p'']], { noremap = true, silent = true, buffer = 0 })
        vim.keymap.set( "n", "<leader><a-]>", [[dd:<C-u>call search('##', 's')<CR>:call search('##')<CR>:<C-u>call search('^.\+', 'b')<CR>p]], { noremap = true, silent = true, buffer = 0 })
        vim.keymap.set( "n", "<leader><a-[>", [[dd:<C-u>call search('##', 'bs')<CR>:<C-u>call search('^.\+', 'b')<CR>p]], { noremap = true, silent = true, buffer = 0 })
	-- stylua: ignore ends
end

vim.api.nvim_set_hl(0, "kanTagBoys", {fg="#595f6f", italic=true})
vim.fn.matchadd('kanTagBoys', [[\<\#\{1\}[^[:space:]#]\+\>]])
-- Af einhverjum óskiljanlegum ástæðum virkar tag highlightingið ekki
-- nema ég hafi keyrt SoftPencil
vim.cmd([[SoftPencil]]) -- laggy af yo
-- vim.opt.listchars:remove("eol")
-- vim.opt_local.wrap = true

vim.api.nvim_set_hl(0, "Pomodorro", {fg="#fc5d7c"})
vim.fn.matchadd('Pomodorro', [[🍅]])

vim.cmd([[
call vimtex#options#init()
call vimtex#text_obj#init_buffer()

omap <silent><buffer> id <plug>(vimtex-id)
omap <silent><buffer> ad <plug>(vimtex-ad)
xmap <silent><buffer> id <plug>(vimtex-id)
xmap <silent><buffer> ad <plug>(vimtex-ad)

omap <silent><buffer> i$ <plug>(vimtex-i$)
omap <silent><buffer> a$ <plug>(vimtex-a$)
xmap <silent><buffer> i$ <plug>(vimtex-i$)
xmap <silent><buffer> a$ <plug>(vimtex-a$)

" *<plug>(vimtex-ac)*   Commands
" *<plug>(vimtex-ic)*
" *<plug>(vimtex-ad)*   Delimiters
" *<plug>(vimtex-id)*
" *<plug>(vimtex-ae)*   Environments (except top-level `document`)
" *<plug>(vimtex-ie)*
" *<plug>(vimtex-a$)*   Math environments
" *<plug>(vimtex-i$)*
" *<plug>(vimtex-aP)*   Sections
" *<plug>(vimtex-iP)*
" *<plug>(vimtex-am)*   Items
" *<plug>(vimtex-im)*
 
]])
