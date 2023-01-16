require("nvim-surround").setup()
require("Comment").setup()
require("leap").add_default_mappings()
require("nvim-autopairs").setup()
require("color-picker")

require("nvim-toggler").setup({
	inverses = {
		["vim"] = "emacs",
	},
	remove_default_keybinds = true, -- removes the default <leader>i keymap
})

require("project_nvim").setup({
	-- your configuration comes here
	-- or leave it empty to use the default settings
	-- All the patterns used to detect root dir, when **"pattern"** is in
	-- detection_methods
	patterns = { ">Latex", ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" }, -- refer to the configuration section below
})

require("trouble").setup({
	-- your configuration comes here
	-- or leave it empty to use the default settings
	-- refer to the configuration section below
})

local rt = require("rust-tools")
rt.setup({
	server = {
		on_attach = function(_, bufnr)
			require("tkj.keymaps"):set_lsp_keymaps(bufnr)
		end,
	},
})

require("fidget").setup({})

require("obsidian").setup({
	dir = "~/Desktop/hrafnatinna/",
	completion = {
		nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
	},
	disable_frontmatter = true,
})

-- -- Vimwiki
-- vim.cmd([[
-- " let g:vimwiki_list = [{'path': '~/vimwiki/',
-- "                       \ 'syntax': 'markdown', 'ext': '.md'}]
-- let g:vimwiki_global_ext = 0
-- let wiki_1 = {}
-- let wiki_1.path = '~/vimwiki/'
-- let wiki_1.syntax = 'markdown'
-- let wiki_1.ext = '.md'
--
-- let g:vimwiki_list = [wiki_1]
-- let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
-- ]])
