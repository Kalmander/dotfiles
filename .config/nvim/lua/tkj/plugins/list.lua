return {

	-- Vim motions/operators etc
	{ "michaeljsmith/vim-indent-object" },
	{ "kylechui/nvim-surround" },
	{ "numToStr/Comment.nvim" },
	{ "ggandor/leap.nvim" },

	-- Completions
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/nvim-cmp",
	"L3MON4D3/LuaSnip",
	"saadparwaiz1/cmp_luasnip",
	"rafamadriz/friendly-snippets",
	"windwp/nvim-autopairs",
	"hrsh7th/cmp-nvim-lsp-signature-help",

	-- LSP
	"neovim/nvim-lspconfig", -- enable LSP
	"williamboman/mason.nvim", -- simple to use language server installer
	"williamboman/mason-lspconfig.nvim",
	"jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
	{ "folke/trouble.nvim", dependencies = "kyazdani42/nvim-web-devicons" },
	"RRethy/vim-illuminate",
	"simrat39/rust-tools.nvim",
	"j-hui/fidget.nvim",

	-- GUI
	{ "goolord/alpha-nvim" },
	{ "Pocco81/true-zen.nvim" },
	{ "nvim-lualine/lualine.nvim", dependencies = { "kyazdani42/nvim-web-devicons", opt = true } },
	{ "nvim-telescope/telescope.nvim" },
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{ "ziontee113/color-picker.nvim" },
	"lukas-reineke/indent-blankline.nvim",
	{ "akinsho/toggleterm.nvim", lazy=false },
	"brenoprata10/nvim-highlight-colors",
	{ "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" },
	"jbyuki/nabla.nvim",

	-- Technical stuff
	-- { "wbthomason/packer.nvim" },
	{ "lewis6991/impatient.nvim" }, -- Bætir startup hraða (supposably,
	{ "nvim-lua/plenary.nvim" },
	-- { "p00f/nvim-ts-rainbow" },
	-- { "ahmedkhalf/project.nvim" },
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
	},
	"nvim-treesitter/nvim-treesitter-textobjects",
	"ThePrimeagen/harpoon",
	"lewis6991/gitsigns.nvim",
	"junegunn/gv.vim",
	-- "tpope/vim-vinegar",
	"andymass/vim-matchup",
	"gbprod/yanky.nvim",

	-- Obsidian og markdown
	-- "epwalsh/obsidian.nvim",
	"godlygeek/tabular",
	"preservim/vim-markdown",
	"preservim/vim-pencil",
	"tommcdo/vim-exchange",
	"dhruvasagar/vim-table-mode",

	-- Misc
	{ "lervag/vimtex" },
	"nguyenvukhang/nvim-toggler",
	"ThePrimeagen/vim-be-good",
	"mbbill/undotree",
	"itchyny/calendar.vim",
	-- "vimwiki/vimwiki",
	"lervag/wiki.vim",
	"lervag/wiki-ft.vim",
	"lervag/lists.vim",
	"kana/vim-textobj-user",
	"asiryk/auto-hlsearch.nvim",
	-- "preservim/vim-textobj-sentence",
	-- "edluffy/hologram.nvim", -- highly experimental, til að byrta myndir
	-- "jakewvincent/mkdnflow.nvim",
	-- "vim-pandoc/vim-pandoc-syntax",
	"folke/twilight.nvim",
	"folke/noice.nvim",
	"MunifTanjim/nui.nvim",
	-- "rcarriga/nvim-notify",
	-- "kevinhwang91/nvim-ufo",
	-- "stevearc/oil.nvim", -- filesystem dótið
	-- "ggandor/flit.nvim",
	"folke/zen-mode.nvim",
	"rhysd/clever-f.vim",
	"tpope/vim-rsi",
	{
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
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

			})
		end,
		dependencies = { "plenary.nvim", "toggleterm.nvim" },
	},
}

---- Shortlist ----------------------------------
-- use({ "mrjones2014/legendary.nvim" }) -- Lítur mjög vel út en virðist vera

-- Ah ok, I will give this a try
-- EDIT: now it works. Thanks. I should read the Readme more carefully.
-- structure looks (roughly) like this now
-- init.lua:
-- require "user.lazy"
-- lua/user/lazy.lua:
-- require("lazy").setup("plugins")
-- lua/plugins/init.lua:
-- return { <plugin_author>/>plugin_name.nvim> }
-- This works and reloads everything.
-- Maybe I will break up the plugins/init.lua further.
