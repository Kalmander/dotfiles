vim.opt_local.keymap = "icelandic"
require("tkj.keymap_utils").toggle_zen("on")
vim.keymap.set({"x", "o"}, "iq", ":<c-u>normal! g_vF]2l<cr>", {silent=true})
vim.keymap.set("n", "<leader>gp", "mygg/mynd:<CR><cmd>noh<cr>2w<cmd>silent !vimiv -s statusbar.show false -f <cfile><CR>`y<cmd>echo <CR>", { silent = true, buffer = 0 })

local filename = vim.api.nvim_buf_get_name(0)
if filename:match("kanban") then
	vim.keymap.set("n", "o", "o<esc>i- [ ] ", { noremap = true, silent = true, buffer = 0 })
end
if filename:match("hrafnatinna") then
        -- hendir línu neðst í næsta eða fyrra ## heading
	-- stylua: ignore start
        vim.keymap.set( "n", "<a-]>", [[dd:<C-u>call search('##', 's')<CR>:call search('##')<CR>:<C-u>call search('^.\+', 'b')<CR>p'']], { noremap = true, silent = true, buffer = 0 })
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
