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
		on_attach = function(client, bufnr)
			require("tkj.keymaps"):set_lsp_keymaps(bufnr)
			local status_ok, illuminate = pcall(require, "illuminate")
			if not status_ok then
				return
			end
			illuminate.on_attach(client)
		end,
	},
})

require("indent_blankline").setup({
	-- for example, context is off by default, use this to turn it on
	-- show_current_context = true,
	show_current_context_start = true,
	show_end_of_line = true,
})

require("fidget").setup({})
