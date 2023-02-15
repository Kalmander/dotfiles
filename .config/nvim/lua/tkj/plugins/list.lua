return {

	"michaeljsmith/vim-indent-object",
	"kylechui/nvim-surround",
	"numToStr/Comment.nvim",
	"ggandor/leap.nvim",
	"windwp/nvim-autopairs",
	"ziontee113/color-picker.nvim",
	"lukas-reineke/indent-blankline.nvim",
	"brenoprata10/nvim-highlight-colors",
	"jbyuki/nabla.nvim",
	"ThePrimeagen/harpoon",
	"lewis6991/gitsigns.nvim",
	"junegunn/gv.vim",
	"andymass/vim-matchup",
	"gbprod/yanky.nvim",
	"tommcdo/vim-exchange",
	"nguyenvukhang/nvim-toggler",
	"ThePrimeagen/vim-be-good",
	"mbbill/undotree",
	"itchyny/calendar.vim",
	"asiryk/auto-hlsearch.nvim",
	"kana/vim-textobj-user",
	"MunifTanjim/nui.nvim",
	"rhysd/clever-f.vim",

	{ "nvim-lualine/lualine.nvim", dependencies = { "kyazdani42/nvim-web-devicons", opt = true } },
	{ "akinsho/toggleterm.nvim", lazy = false },
	{ "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" },

	{
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup({
				manual_mode = false, -- þarft þá að nota :ProjectRoot
				detection_methods = { "pattern" }, -- be default er lsp primary og pattern 2nd
				silent_chdir = false, -- true by default
				scope_chdir = "tab", -- global by default
				patterns = { ".git", "Makefile", ">.config", ">share" },
			})
		end,
	},

	{
		"lmburns/lf.nvim",
		lazy = false,
		config = function()
			-- This feature will not work if the plugin is lazy-loaded
			vim.g.lf_netrw = 1

			require("lf").setup({
				escape_quit = false,
				border = "solid",
				-- highlights = { FloatBorder = { guifg = require("kimbox.palette").colors.magenta } },
				direction = "float",
				-- open_mapping = [[;]],
				-- on_open = function() vim.cmd([[:Lf<cr>]]) end,
				shade_terminals = false,
				winblend = 0,
				width = 1,
				height = 1,
				default_actions = { -- default action keybindings
					[";"] = "cd",
					["<C-s>"] = "split", --defaultið er c-x
				},
				on_open = function(term)
					vim.api.nvim_buf_set_keymap(
						term.bufnr,
						"t",
						"a",
						"<cmd>close<CR>",
						{ noremap = true, silent = true }
					)
				end,
			})
		end,
		dependencies = { "plenary.nvim", "toggleterm.nvim" },
	},
}
