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

-- Yankstack
vim.cmd([[
let g:yankstack_map_keys = 0 "defaultin nota meta
nmap <a-p> <Plug>yankstack_substitute_older_paste
nmap <a-P> <Plug>yankstack_substitute_newer_paste
]])
