return {
	"folke/twilight.nvim",
	{ "folke/which-key.nvim", config = true },
	{ "folke/trouble.nvim", config = true, dependencies = "kyazdani42/nvim-web-devicons" },
	{
		"folke/zen-mode.nvim",
		config = function()
			require("zen-mode").setup({
				window = {
					backdrop = 1,
				},
				plugins = {
					-- disable some global vim options (vim.o...)
					-- comment the lines to not apply the options
					options = {
						enabled = true,
						ruler = false, -- disables the ruler text in the cmd line area
						showcmd = false, -- disables the command in the last line of the screen
					},
					twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
				},
			})
		end,
	},
	{
		"folke/noice.nvim",
		config = function()
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
				messages = { enabled = false },
				views = {
					-- split = {
					-- 	size = "auto",
					-- 	enter = true,
					-- },
					-- cmdline_popup = {
					-- 	border = {
					-- 		style = "none",
					-- 		padding = { 1, 1 },
					-- 	},
					-- 	filter_options = {},
					-- 	win_options = {
					-- 		winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
					-- 	},
					-- },
					-- mini = {
					-- 	timeout = 3000 -- default: 2000
					-- }
				},
				-- messages = { enable = false },
				routes = {
					-- {
					-- 	filter = {
					-- 		event = "msg_show",
					-- 		kind = "search_count",
					-- 	},
					-- 	opts = { skip = true },
					-- },
					-- {
					-- 	view = "split",
					-- 	filter = { event = "msg_show", find = "git" },
					-- },
				},
			})
		end,
	},
}
