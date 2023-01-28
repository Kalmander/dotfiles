local options = {
	clipboard       = "unnamedplus",
	number          = true,
	relativenumber  = true,
	termguicolors   = true,
	wrap            = false,
	linebreak       = true, -- companion to wrap, don't split words
	cmdheight       = 1,
	-- showtabline  = 2,
	undofile        = true,
	virtualedit     = "none",
	scrolloff       = 6,
	sidescrolloff   = 1,
	-- textwidth    = 80,
	conceallevel    = 2,
        concealcursor   = 'n',
	-- fileencoding = "utf-8",
	ignorecase      = true,
	smartcase       = true,
	smartindent     = true,
	timeoutlen      = 400, -- time to wait for a mapped sequence to complete (in milliseconds)
	updatetime      = 300, -- faster completion (4000ms default)
	-- foldmethod   = "indent",
	foldlevel       = 10,
	hlsearch        = true, -- highlight all matches on previous search pattern
	cursorline      = true,
	laststatus      = 3, -- default er 2
        splitright      = true,
	completeopt     = { "menuone", "noselect" }, -- mostly just for cmp
	pumheight       = 10, -- pop up menu height
	swapfile        = true,
	backup          = true,
	backupdir       = vim.fn.expand("~/backups/backup//"),
	directory       = vim.fn.expand("~/backups/swp//"),
	foldmethod      = "expr",
	foldexpr        = "nvim_treesitter#foldexpr()",
	list            = true,
}
-- vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")
vim.g.vim_markdown_math = 1
vim.g['pencil#conceallevel'] = options.conceallevel
vim.g['pencil#concealcursor'] = options.concealcursor
vim.g['pencil#cursorwrap'] = 0 -- sleppir því að fokka í defaultinu
vim.g['netrw_liststyle'] = 3

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


vim.cmd([[
let g:wiki_root = '~/'
let g:wiki_filetypes = ['md']
let g:wiki_link_extension = '.md'
]])

-- vim.cmd([[
-- augroup init_wiki
--   autocmd!
--   autocmd BufRead,BufNewFile *.md call PossiblyEnableWiki()
--   " This may be slightly better than the above, not sure:
--   " autocmd FileType markdown call PossiblyEnableWiki()
-- augroup END
--
-- function! PossiblyEnableWiki()
--   let l:wikis = ["~/hrafnatinna/", "~/riker/"]
--   if index(l:wikis, wiki#get_root()) >= 0
--     WikiEnable
--   endif
-- endfunction
-- ]])
