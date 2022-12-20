local options = {
	clipboard = "unnamedplus",
	number = true,
	relativenumber = true,
	termguicolors = true,
	wrap = false,
	linebreak = true, -- companion to wrap, don't split words
	cmdheight = 1,
	-- showtabline  = 2,
	undofile = true,
	virtualedit = "none",
	scrolloff = 6,
	sidescrolloff = 1,
	textwidth = 80,
	conceallevel = 1,
	-- fileencoding = "utf-8",
	ignorecase = true,
	smartcase = true,
	smartindent = true,
	timeoutlen = 300, -- time to wait for a mapped sequence to complete (in milliseconds)
	updatetime = 300, -- faster completion (4000ms default)
	expandtab = true, -- convert tabs to spaces
	signcolumn = "yes", -- shows sign column, otherwise shifts the text each time
	-- foldmethod = "indent",
	foldlevel = 10,
	hlsearch = true, -- highlight all matches on previous search pattern
	cursorline = false,
	laststatus = 3, -- default er 2

	completeopt = { "menuone", "noselect" }, -- mostly just for cmp
	pumheight = 10, -- pop up menu height

	swapfile = true,
	backup = true,
	backupdir = vim.fn.expand("~/backups/backup//"),
	directory = vim.fn.expand("~/backups/swp//"),

	-- Í boði rustmannsins:
	foldmethod = "expr",
	foldexpr = "nvim_treesitter#foldexpr()",

	list = true,
}
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

local neovide_settings = {
	guifont = { "FiraCode Nerd Font", ":h18" },
	neovide_scale_factor = 1.5,
	neovide_transparency = 0.85,
	neovide_fullscreen = true,
	neovide_cursor_vfx_mode = "wireframe",
}

for k, v in pairs(options) do
	vim.opt[k] = v
end

if vim.g.neovide then
	for k, v in pairs(neovide_settings) do
		vim.g[k] = v
	end
end

-- TKJ Þetta er frá rustmanninum:
-- Fixed column for diagnostics to appear
-- Show autodiagnostic popup on cursor hover_range
-- Goto previous / next diagnostic warning / error
-- Show inlay_hints more frequently
-- vim.cmd([[
-- set signcolumn=yes
-- autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
-- ]])
