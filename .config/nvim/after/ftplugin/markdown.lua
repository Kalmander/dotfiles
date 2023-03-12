vim.opt_local.keymap = "ice"
vim.opt_local.wrap = true


vim.keymap.set("n", "<leader>gp", "mygg/mynd:<CR><cmd>noh<cr>2w<cmd>silent !vimiv -s statusbar.show false -f <cfile><CR>`y<cmd>echo <CR>", { silent = true, buffer = 0 })
vim.keymap.set("n", "[[", "<Plug>Markdown_MoveToPreviousHeader|jzt", { noremap = true, silent = true, buffer = 0 })
vim.keymap.set("n", "]]", "<Plug>Markdown_MoveToNextHeader|jzt", { noremap = true, silent = true, buffer = 0 })

local filename = vim.api.nvim_buf_get_name(0)
if filename:match("hrafnatinna") then
        vim.keymap.set( "n", "<a-]>", [[dd:<C-u>call search('##', 's')<CR>:call search('##')<CR>:<C-u>call search('^.\+', 'b')<CR>p''zt]], { noremap = true, silent = true, buffer = 0 })
        vim.keymap.set( "n", "<a-[>", [[dd:<C-u>call search('##', 'bs')<CR>:<C-u>call search('^.\+', 'b')<CR>p'']], { noremap = true, silent = true, buffer = 0 })
end
vim.api.nvim_set_hl(0, "kanTagBoys", {fg="#595f6f", italic=true})
vim.fn.matchadd('kanTagBoys', [[\#\{1\}[^[:space:]#]\+]])
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
]])
