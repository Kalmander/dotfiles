local options = {
	clipboard = "unnamedplus",
	number = true,
	relativenumber = true,
	termguicolors = true,
	wrap = false,
	linebreak = true, -- companion to wrap, don't split words
	breakindent = true,
	expandtab = true,
	undofile = true,
	virtualedit = "none",
	scrolloff = 6,
	sidescrolloff = 1,
	conceallevel = 2,
	concealcursor = "n",
	ignorecase = true,
	smartcase = true,
	smartindent = true,
	timeoutlen = 400, -- time to wait for a mapped sequence to complete
	updatetime = 250, -- faster completion (4000ms default)
	hlsearch = true, -- highlight all matches on previous search pattern
	cursorline = true,
	laststatus = 3, -- default er 2
	splitright = true,
	swapfile = true,
	directory = vim.fn.expand("~/.backups/swp//"),
	signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
	showmode = false,
	completeopt = "menuone,noselect",
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

local settings_group = vim.api.nvim_create_augroup("GeneralSettings", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	desc = "Consider calcurse notes markdown",
	pattern = { "/tmp/calcurse*", vim.fn.expand("~") .. ".calcurse/notes/*" },
	group = settings_group,
	callback = function()
		vim.opt_local.filetype = "markdown"
	end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlights yanked area",
	pattern = "*",
	group = settings_group,
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 250 })
	end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
	desc = "Prevents automatically commenting newline after commented line",
	pattern = "*",
	group = settings_group,
	callback = function()
		vim.opt.formatoptions:remove({ 'c', 'r', 'o' })
	end,
})
