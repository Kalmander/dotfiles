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
	-- textwidth = 80,
	conceallevel = 2,
        concealcursor = 'n',
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
	cursorline = true,
	laststatus = 3, -- default er 2
        splitright = true,

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

-- TKJ Þetta er frá rustmanninum:
-- Fixed column for diagnostics to appear
-- Show autodiagnostic popup on cursor hover_range
-- Goto previous / next diagnostic warning / error
-- Show inlay_hints more frequently
-- vim.cmd([[
-- set signcolumn=yes
-- autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
-- ]])


vim.cmd([[
let g:wiki_root = '~/hrafnatinna'
let g:wiki_filetypes = ['md']
let g:wiki_link_extension = '.md'
" autocmd BufRead,BufNewFile *.Rmd set filetype=wiki
" autocmd BufRead,BufNewFile *.md set filetype=wiki
]])
--
-- Vimwiki
-- vim.cmd([[
-- " let g:vimwiki_list = [{'path': '~/vimwiki/',
-- "                       \ 'syntax': 'markdown', 'ext': '.md'}]
-- let wiki_1 = {}
-- let wiki_1.path = '~/riker/'
-- let wiki_1.syntax = 'markdown'
-- let wiki_1.ext = '.md'
--
-- let wiki_2 = {}
-- let wiki_2.path = '~/hrafnatinna/'
-- let wiki_2.syntax = 'markdown'
-- let wiki_2.ext = '.md'
--
-- let g:vimwiki_global_ext = 0
-- let g:vimwiki_list = [wiki_1, wiki_2]
-- let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
-- ]])
--
-- vim.cmd([[
-- autocmd VimEnter * let g:vimwiki_syntaxlocal_vars['markdown']['Link1'] = g:vimwiki_syntaxlocal_vars['default']['Link1']
-- " Þetta gerir latex syntax en fokkar upp hlekkja syntaxinum
-- " augroup Mkd
-- " au BufRead,BufWinEnter,BufNewFile *.{md,mdx,mdown,mkd,mkdn,markdown,mdwn} setlocal syntax=markdown
-- " au BufRead,BufWinEnter,BufNewFile *.{md,mdx,mdown,mkd,mkdn,markdown,mdwn}.{des3,des,bf,bfa,aes,idea,cast,rc2,rc4,rc5,desx} setlocal syntax=markdown
-- " augroup END
-- ]])
--
