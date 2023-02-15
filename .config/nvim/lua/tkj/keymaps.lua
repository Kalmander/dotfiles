local utils = require("tkj.keymap_utils")
local map = utils.set_keymap
local multimap = utils.set_keymaps_multi
local noremap_silent = { noremap = true, silent = true }

local tele = require("telescope.builtin")
local dropdown = require("telescope.themes").get_dropdown
local ivy = require("telescope.themes").get_ivy
local M = {}

vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "



---- Keymap Definitions ------------------------------------------------------
M.normal_mode_keymaps = {
	["<leader>ge"] = [[<cmd>silent Explore<cr>]],
	["<leader>mm"] = function() utils.set_zen_mode('off') end,
	["<leader>mq"] = function() utils.set_zen_mode('normal') end,
	["<leader>mw"] = function() utils.set_zen_mode('super') end,
	["<leader>me"] = function() utils.set_zen_mode('centered') end,
	["<leader>mr"] = function() utils.set_zen_mode('super_centered') end,
	["<A-j>"] = ":m .+1<CR>==",
	["<A-k>"] = ":m .-2<CR>==",
	["<leader>cp"] = "<cmd>PickColor<cr>",
	["<leader>ci"] = "<cmd>ConvertHEXandRGB<cr>",
	["<leader>cl"] = utils.toggle_conceallevel,
	["<leader>cc"] = utils.toggle_concealcursor,
	["<leader>r"] = utils.reload_lua,
	["<leader>tt"] = utils.toggle_diagnostics,
        -- ["<A-/>"] = "<cmd>nohlsearch<CR><cmd>echo<CR>", -- óþarfi, <C-l> gerir þetta og meira native
        ["<A-1>"] = function() require("harpoon.ui").nav_file(1) end,
        ["<A-2>"] = function() require("harpoon.ui").nav_file(2) end,
        ["<A-3>"] = function() require("harpoon.ui").nav_file(3) end,
        ["<A-4>"] = function() require("harpoon.ui").nav_file(4) end,
        ["<A-w>"] = require("harpoon.mark").add_file,
        ["<A-q>"] = require("harpoon.ui").toggle_quick_menu,
        ["<C-BS>"] = "<C-6>",
        ["<C-W>N"] = "<cmd>vnew<CR>",
        ["<leader>go"] = [[<cmd>silent !vimiv -s statusbar.show false -f <cfile><CR>]],
        ["<leader>lw"] = [[<cmd>%s/\s\+$//e<cr>]],
        -- ["<leader>lw"] = [[<cmd>%s#\($\n\s*\)\+\%$##<cr><cmd>%s/\s\+$//e<cr><cmd>noh<cr>]], -- líka aftast en hendir í villu ef ekekrt
	["<leader>ss"] = "<cmd>call SynStack()<CR>",
	["<leader>st"] = utils.get_ts_hl_group,
	["<leader>h"] = utils.hide_cursor,
	["<leader>["] = [[<cmd>set cmdheight+=1<cr>]],
	["<leader>]"] = [[<cmd>set cmdheight-=1<cr>]],
	["<leader>c"] = utils.open_calendar,
	-- ["<leader>l"] = ':ls<cr>:b<space>' -- þetta er cool af en virkar ekki með noice atm, ætti að reynað laga
	[";"] = '<cmd>Lf<cr>',
	-- ["<C-;>"] = '<cmd>Neotree toggle left<cr>',
	-- ["<A-;>"] = '<cmd>Neotree toggle float reveal_force_cwd<cr>',
}

-- vim.cmd([[
--     nnoremap / :Neotree toggle current reveal_force_cwd<cr>
--     nnoremap | :Neotree reveal<cr>
--     nnoremap gd :Neotree float reveal_file=<cfile> reveal_force_cwd<cr>
--     nnoremap <leader>b :Neotree toggle show buffers right<cr>
--     nnoremap <leader>s :Neotree float git_status<cr>
-- ]])

M.visualselect_keymaps = {
-- 	[">"] = ">gv",
-- 	["<"] = "<gv",
--	["p"] = '"_dP',
}
-- yanky keymaps
vim.keymap.set({ 'n', 'x' }, 'y',	  '<Plug>(YankyYank)')
vim.keymap.set({ 'n', 'x' }, 'p',	  '<Plug>(YankyPutAfter)')
vim.keymap.set({ 'n', 'x' }, 'P',         '<Plug>(YankyPutBefore)')
vim.keymap.set({ 'n', 'x' }, 'gp',        '<Plug>(YankyGPutAfter)')
vim.keymap.set({ 'n', 'x' }, 'gP',        '<Plug>(YankyGPutBefore)')
vim.keymap.set({ 'n' },      '<c-n>',     '<Plug>(YankyCycleForward)')
vim.keymap.set({ 'n' },      '<c-p>',     '<Plug>(YankyCycleBackward)')
-- unimpaired yankings
vim.keymap.set("n", "]p", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[p", "<Plug>(YankyPutIndentBeforeLinewise)")
vim.keymap.set("n", "]P", "<Plug>(YankyPutIndentAfterLinewise)")
vim.keymap.set("n", "[P", "<Plug>(YankyPutIndentBeforeLinewise)")
vim.keymap.set("n", ">p", "<Plug>(YankyPutIndentAfterShiftRight)")
vim.keymap.set("n", "<p", "<Plug>(YankyPutIndentAfterShiftLeft)")
vim.keymap.set("n", ">P", "<Plug>(YankyPutIndentBeforeShiftRight)")
vim.keymap.set("n", "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)")
vim.keymap.set("n", "=p", "<Plug>(YankyPutAfterFilter)")
vim.keymap.set("n", "=P", "<Plug>(YankyPutBeforeFilter)")

M.visual_mode_keymaps = {
	["<A-j>"] = ":m '>+1<CR>gv-gv",
	["<A-k>"] = ":m '<-2<CR>gv-gv",
}

M.terminal_mode_keymaps = {
        -- ["<esc><esc>"] = [[<C-\><C-n>]],
}

M.telescope_keymaps = {
	["<leader>F"] = tele.resume,
	["<leader>fk"] = tele.keymaps,
	["<leader>fp"] = require("telescope").extensions.projects.projects,
	["<leader>fr"] = require("telescope.builtin").registers,
	["<leader>fh"] = function() tele.help_tags(dropdown()) end,
	["<leader>fg"] = function() tele.live_grep(ivy()) end,
	["<leader>fm"] = function() tele.marks(dropdown()) end,
	["<leader>ft"] = function() tele.builtin(dropdown()) end,
	["<leader>fb"] = function()
		tele.buffers(dropdown({ previewer = false }))
	end,
	["<leader>ff"] = function()
		tele.find_files(dropdown({ previewer = false }))
	end,
	["<leader>fe"] = function()
		tele.current_buffer_fuzzy_find(
			ivy({ sorting_strategy = "ascending", layout_config = { prompt_position = "top" } })
		)
	end,
	["<leader>fn"] = function()
		tele.find_files(dropdown({ previewer = false, cwd = "~/.config/nvim/" }))
	end,
	["<leader>fs"] = function()
		tele.live_grep(dropdown({ previewer = false, cwd = "~/.config/nvim/lua/tkj/math-snippets/" }))
	end,
	["<leader>fl"] = function()
		tele.find_files(dropdown({ previewer = false, cwd = "~/.local/share/nvim/site/pack/packer/" }))
	end,
}

M.lsp_keymaps = {
	["gD"] = "<cmd>lua vim.lsp.buf.declaration()<CR>",
	["gd"] = "<cmd>lua vim.lsp.buf.definition()<CR>",
	["K"] = "<cmd>lua vim.lsp.buf.hover()<CR>",
	["gI"] = "<cmd>lua vim.lsp.buf.implementation()<CR>",
	["gr"] = "<cmd>lua vim.lsp.buf.references()<CR>",
	["gl"] = "<cmd>lua vim.diagnostic.open_float()<CR>",
	["<leader>lf"] = "<cmd>lua vim.lsp.buf.format{ async = true }<cr>",
	["<leader>li"] = "<cmd>LspInfo<cr>",
	["<leader>lI"] = "<cmd>LspInstallInfo<cr>",
	["<leader>la"] = "<cmd>lua vim.lsp.buf.code_action()<cr>",
	["<leader>lj"] = "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>",
	["<leader>lk"] = "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>",
	["<leader>lr"] = "<cmd>lua vim.lsp.buf.rename()<cr>",
	["<leader>ls"] = "<cmd>lua vim.lsp.buf.signature_help()<CR>",
	["<leader>lq"] = "<cmd>lua vim.diagnostic.setloclist()<CR>",
}

M.text_objects = {
        -- ["il"] = ":<C-u>norm! _vg_<cr>",
        -- ["al"] = ":<C-u>norm! 0v$<cr>",
}

M.gitsigns_keymaps = {
	-- eru í gitsigns.lua
		-- map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
		-- map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
		-- map("n", "<leader>hS", gs.stage_buffer)
		-- map("n", "<leader>hu", gs.undo_stage_hunk)
		-- map("n", "<leader>hR", gs.reset_buffer)
		-- map("n", "<leader>hp", gs.preview_hunk)
		-- map("n", "<leader>hb", function()
		-- 	gs.blame_line({ full = true })
		-- end)
		-- map("n", "<leader>tb", gs.toggle_current_line_blame)
		-- map("n", "<leader>hd", gs.diffthis)
		-- map("n", "<leader>hD", function()
		-- 	gs.diffthis("~")
		-- end)
		-- map("n", "<leader>td", gs.toggle_deleted)
		-- -- Text object
		-- map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
}

M.set_lsp_keymaps = function(self, bufnr)
	for lhs, rhs in pairs(self.lsp_keymaps) do
		vim.keymap.set("n", lhs, rhs, { noremap = true, silent = true, buffer = bufnr })
	end
end

multimap("n", M.normal_mode_keymaps, noremap_silent)
multimap("v", M.visualselect_keymaps, noremap_silent)
multimap("x", M.visual_mode_keymaps, noremap_silent)
multimap("n", M.telescope_keymaps, {})
multimap("t", M.terminal_mode_keymaps, noremap_silent)
multimap({"o", "x"}, M.text_objects, noremap_silent)

---- Misc Keymaps ------------------------------------------------------------
map({ "n", "v" }, "<leader>i", require("nvim-toggler").toggle)
-- vim.keymap.set("n", "gf", ":echo GAAA<cr>", {noremap = false, buffer = 0})
-- vim.keymap.set("n", "gf", utils.obsidian_link, {noremap = false, expr = true, buffer = 0})

return M
