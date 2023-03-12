return {
	"ThePrimeagen/vim-be-good",
	"itchyny/calendar.vim",
	"mbbill/undotree",

	{ "nguyenvukhang/nvim-toggler", config = true },
	{ "windwp/nvim-autopairs", config = true },
	{ "numToStr/Comment.nvim", config = true },
	{ "kylechui/nvim-surround", config = true },
	{ "lewis6991/gitsigns.nvim", config = true },

	{
		"ziontee113/color-picker.nvim",
		config = function()
			require("color-picker").setup()
			vim.keymap.set("n", "<leader>cp", "<cmd>PickColor<cr>")
			vim.keymap.set("n", "<leader>ci", "<cmd>ConvertHEXandRGB<cr>")
		end,
	},

	{
		"jamespeapen/Nvim-R",
		init = function()
			vim.g.rout_follow_colorscheme = 1
			vim.g.Rout_more_colors = 1
			vim.g.R_assign = 0
			vim.g.R_nvim_wd = 1
			vim.g.R_csv_app = "terminal:vd"
		end,
	},

	{
		"ThePrimeagen/harpoon",
		config = function()
			vim.keymap.set("n", "<A-1>", function()
				require("harpoon.ui").nav_file(1)
			end)
			vim.keymap.set("n", "<A-2>", function()
				require("harpoon.ui").nav_file(2)
			end)
			vim.keymap.set("n", "<A-3>", function()
				require("harpoon.ui").nav_file(3)
			end)
			vim.keymap.set("n", "<A-4>", function()
				require("harpoon.ui").nav_file(4)
			end)
			vim.keymap.set("n", "<A-w>", require("harpoon.mark").add_file)
			vim.keymap.set("n", "<A-q>", require("harpoon.ui").toggle_quick_menu)
		end,
	},

	{
		"chrisgrieser/nvim-various-textobjs",
		opts = {
			useDefaultKeymaps = true,
		},
	},

	{
		"gbprod/substitute.nvim",
		config = function()
			require("substitute").setup()
			vim.keymap.set("n", "cx", "<cmd>lua require('substitute.exchange').operator()<cr>", { noremap = true })
			vim.keymap.set("n", "cxx", "<cmd>lua require('substitute.exchange').line()<cr>", { noremap = true })
			vim.keymap.set("x", "X", "<cmd>lua require('substitute.exchange').visual()<cr>", { noremap = true })
			vim.keymap.set("n", "cxc", "<cmd>lua require('substitute.exchange').cancel()<cr>", { noremap = true })
		end,
	},

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
			vim.api.nvim_set_hl(0, "IlluminatedWordText", { bold = true })
			vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bold = true })
			vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bold = true })
		end,
	},

	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			vim.opt.termguicolors = true
			require("colorizer").setup({
				names = {false} -- "Name" codes like Blue
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
			-- local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- capabilities.textDocument.foldingRange = {
			-- 	dynamicRegistration = false,
			-- 	lineFoldingOnly = true,
			-- }
			-- local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
			-- for _, ls in ipairs(language_servers) do
			-- 	require("lspconfig")[ls].setup({
			-- 		capabilities = capabilities,
			-- 		-- you can add other fields for setting up lsp server in this table
			-- 	})
			-- end
			-- require("ufo").setup()
			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
			})
			-- Að ofan notar lsp annars vegar og svo treesitter hins
			-- vegar til að reikna folds, var að lenda í einhverjum
			-- bugs með markdown folding svo ég slökkti á ufo
			-- sem provider en vildi enn halda plugininu því
			-- það lítur svo miklu betur út
			-- require('ufo').setup({
			--     provider_selector = function(bufnr, filetype, buftype)
			-- 	return ''
			--     end
			-- })
		end,
	},

	{
		"akinsho/toggleterm.nvim",
		lazy = false,
		config = function()
			require("toggleterm").setup({
				size = 20,
				open_mapping = [[<c-\>]],
				hide_numbers = true,
				shade_filetypes = {},
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				persist_size = true,
				-- direction = "horizontal",
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
					width = 240,
					height = 34,
				},
			})
		end,
	},

	{
		"Julian/lean.nvim",
		opts = {
			abbreviations = { builtin = true },
			lsp = {
				on_attach = function(_, bufnr)
					require("tkj.keymaps"):set_lsp_keymaps(bufnr)
				end,
			},
			mappings = true,
		},
	},

	--	{
	--		"ggandor/leap.nvim",
	--		config = function()
	--			require("leap").add_default_mappings()
	--			require("leap").opts.equivalence_classes = {
	--				" \t\r\n",
	--				"áa",
	--				"ée",
	--				"íi",
	--				"óo",
	--				"úu",
	--				"ýy",
	--				"dð",
	--			}
	--		end,
	--	},
}
