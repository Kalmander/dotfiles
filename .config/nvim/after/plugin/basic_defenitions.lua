require("nvim-surround").setup({ move_cursor = false })
require("Comment").setup()
require("nvim-autopairs").setup()
require("color-picker")
-- require("auto-hlsearch").setup()
require("tkj.textobjs").setup({ useDefaultKeymaps = true })
-- require("fidget").setup({})


require("leap").add_default_mappings()
require("leap").opts.equivalence_classes = {
	' \t\r\n',
	'áa',
	'ée',
	'íi',
	'óo',
	'úu',
	'ýy',
}

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

require("illuminate").configure({
	filetypes_denylist = {
		"dirvish",
		"fugitive",
		"markdown",
		"text",
		"help",
	},
})
