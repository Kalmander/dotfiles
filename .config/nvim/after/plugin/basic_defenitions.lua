require("nvim-surround").setup({ move_cursor = false })
require("Comment").setup()
require("leap").add_default_mappings()
require("nvim-autopairs").setup()
require("color-picker")
require("auto-hlsearch").setup()
require("tkj.textobjs").setup({ useDefaultKeymaps = true })

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

require("noice").setup({
	cmdline = {
		view = "cmdline",
	},
	lsp = {
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
	},
	-- you can enable a preset for easier configuration
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		command_palette = true, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = false, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false, -- add a border to hover docs and signature help
	},
	views = {
		split = { size = "auto" },
		cmdline_popup = {
			border = {
				style = "none",
				padding = { 1, 1 },
			},
			filter_options = {},
			win_options = {
				winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
			},
		},
	},
	routes = {
		{
			filter = {
				event = "msg_show",
				kind = "search_count",
			},
			opts = { skip = true },
		},
	},
})
