return {

	"michaeljsmith/vim-indent-object",
	"lukas-reineke/indent-blankline.nvim",
	"jbyuki/nabla.nvim",
	"ThePrimeagen/harpoon",
	"andymass/vim-matchup",
	"tommcdo/vim-exchange",
	"ThePrimeagen/vim-be-good",
	"mbbill/undotree",
	"itchyny/calendar.vim",
	"kana/vim-textobj-user",
	"MunifTanjim/nui.nvim",
	"rhysd/clever-f.vim",

	{ "nguyenvukhang/nvim-toggler", config = true },
	{ "ziontee113/color-picker.nvim", config = true },
	{ "windwp/nvim-autopairs", config = true },
	{ "numToStr/Comment.nvim", config = true },
	{ "kylechui/nvim-surround", config = true },

	{
		"RRethy/vim-illuminate",
		config = function()
			require("illuminate").configure({
				filetypes_denylist = {
					"dirvish",
					"fugitive",
					"markdown",
					"text",
					"help",
				},
			})
		end,
	},

	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			-- var augljóslega þegar með termguicolors stillt í options en
			-- þetta plugin þarf að hafa það laodað áður en pluginið er loadað
			-- svo best að setja það hér
			vim.opt.termguicolors = true
			require("colorizer").setup()
		end,
	},

	{
		"ggandor/leap.nvim",
		config = function()
			require("leap").add_default_mappings()
			require("leap").opts.equivalence_classes = {
				" \t\r\n",
				"áa",
				"ée",
				"íi",
				"óo",
				"úu",
				"ýy",
				"dð",
			}
		end,
	},

	{
		"akinsho/toggleterm.nvim",
		lazy = false,
		config = function()
			require("toggleterm").setup({
				-- size = 20,
				open_mapping = [[<c-\>]],
				hide_numbers = true,
				shade_filetypes = {},
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				persist_size = true,
				direction = "float",
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "single",
					winblend = 0,
					highlights = {
						border = "Normal",
						background = "Normal",
					},
					width = 104,
					height = 23,
				},
			})
		end,
	},

	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		config = function()
			-- vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
			-- vim.o.foldcolumn = '1' -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

			-- Option 2: nvim lsp as LSP client
			-- Tell the server the capability of foldingRange,
			-- Neovim hasn't added foldingRange to default capabilities, users must add it manually
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
			local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
			for _, ls in ipairs(language_servers) do
				require("lspconfig")[ls].setup({
					capabilities = capabilities,
					-- you can add other fields for setting up lsp server in this table
				})
			end
			require("ufo").setup()
		end,
	},
}
