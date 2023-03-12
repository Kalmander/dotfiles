local normal_mode_keymaps = {
	["<A-j>"] = ":m .+1<CR>==",
	["<A-k>"] = ":m .-2<CR>==",
	-- ["<leader>cl"] = utils.toggle_conceallevel,
	-- ["<leader>cc"] = utils.toggle_concealcursor,
}

for lhs, rhs in pairs(normal_mode_keymaps) do
	vim.keymap.set("n", lhs, rhs)
end

local m = vim.keymap.set
m("n", "<A-j>", ":m .+1<CR>==", { desc = "Move current line down" })
m("n", "<A-k>", ":m .-2<CR>==", { desc = "Move current line up" })
m("n", "<leader>go", "<cmd>silent !vimiv -s statusbar.show false -f <cfile><CR>", { desc = "Open vimiv" })
m("n", "<leader>lw", [[<cmd>%s/\s\+$//e<cr>]], { desc = "Delete trailing whitespace" })
m("n", "<leader>bc", "yypV:'<,'>!bc -l<cr>", { desc = "Call bc on current line and print" })
m("n", "<leader>lm", "<cmd>TSJToggle<cr>")
m("n", "<leader>ca", "<cmd>Calendar -position=here<cr>", { desc = "Open calendar" })
m("n", "<leader>cl", function()
	if vim.opt.conceallevel:get() == 0 then
		vim.opt.conceallevel = 2
	else
		vim.opt.conceallevel = 0
	end
end, { desc = "Toggle conceal level" })
m("n", "<leader>cc", function()
	if vim.opt.concealcursor:get() == "" then
		vim.opt.concealcursor = "n"
	else
		vim.opt.concealcursor = ""
	end
end, { desc = "Toggle conceal on cursorline" })
-- Trikk frá TJ til að deala við jk í wrapped línum
m('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
m('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })


m("v", "<leader>bc", "yPgv:'<,'>!bc -l<cr>", { desc = "Call bc on current visualselection" })


m("x", "<A-j>", ":m '>+1<CR>gv-gv", { desc = "Move visual selection down"})
m("x", "<A-k>", ":m '<-2<CR>gv-gv", { desc = "Move visual selection up"})


vim.cmd([[
command! -nargs=? Filter let @a='' | execute 'g/<args>/y A' | new | setlocal bt=nofile | put! a
]])
