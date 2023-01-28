return require("packer").startup(function(use)
	-- Colorschemes
	use({ "dracula/vim", as = "dracula" })
	use({ "sainnhe/sonokai" })
	use({ "navarasu/onedark.nvim" })
	use({ "rose-pine/neovim", as = "rose-pine" })
	use({ "sainnhe/everforest" })
	use({ "shaunsingh/nord.nvim" })
	use({ "sonph/onehalf" })

	-- Vim motions/operators etc
	use({ "michaeljsmith/vim-indent-object" })
	use({ "kylechui/nvim-surround" })
	use({ "numToStr/Comment.nvim" })
	use({ "ggandor/leap.nvim" })

	-- Completions
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	use("L3MON4D3/LuaSnip")
	use("saadparwaiz1/cmp_luasnip")
	use("rafamadriz/friendly-snippets")
	use("windwp/nvim-autopairs")
	use("hrsh7th/cmp-nvim-lsp-signature-help")

	-- LSP
	use("neovim/nvim-lspconfig") -- enable LSP
	use("williamboman/mason.nvim") -- simple to use language server installer
	use("williamboman/mason-lspconfig.nvim")
	use("jose-elias-alvarez/null-ls.nvim") -- for formatters and linters
	use({ "folke/trouble.nvim", requires = "kyazdani42/nvim-web-devicons" })
	use("RRethy/vim-illuminate")
	use("simrat39/rust-tools.nvim")
	use("j-hui/fidget.nvim")

	-- GUI
	use({ "goolord/alpha-nvim" })
	use({ "Pocco81/true-zen.nvim" })
	use({ "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons", opt = true } })
	use({ "nvim-telescope/telescope.nvim" })
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use({ "ziontee113/color-picker.nvim" })
	use("lukas-reineke/indent-blankline.nvim")
	use({ "akinsho/toggleterm.nvim", tag = "*" })

	-- Technical stuff
	use({ "wbthomason/packer.nvim" })
	use({ "lewis6991/impatient.nvim" }) -- Bætir startup hraða (supposably)
	use({ "tpope/vim-repeat" })
	use({ "nvim-lua/plenary.nvim" })
	-- use({ "p00f/nvim-ts-rainbow" })
	use({ "ahmedkhalf/project.nvim" })
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
			ts_update()
		end,
	})
	use("nvim-treesitter/nvim-treesitter-textobjects")
        use("ThePrimeagen/harpoon")
        use("tpope/vim-unimpaired")
        use("tpope/vim-fugitive")
        use("tpope/vim-sleuth")
	use("tpope/vim-vinegar")
	use("andymass/vim-matchup")

	-- Obsidian og markdown
	-- use("epwalsh/obsidian.nvim")
        use("godlygeek/tabular")
        use("preservim/vim-markdown")
        use("preservim/vim-pencil")
        use("tommcdo/vim-exchange")
	use("dhruvasagar/vim-table-mode")

	-- Misc
	use({ "lervag/vimtex" })
	use("nguyenvukhang/nvim-toggler")
	use("ThePrimeagen/vim-be-good")
	use("mbbill/undotree")
        use("itchyny/calendar.vim")
        -- use("vimwiki/vimwiki")
        use("lervag/wiki.vim")
        use("lervag/wiki-ft.vim")
        use("lervag/lists.vim")
        use("kana/vim-textobj-user")
        use("asiryk/auto-hlsearch.nvim")
        -- use("preservim/vim-textobj-sentence")
        -- use("edluffy/hologram.nvim") -- highly experimental, til að byrta myndir
        -- use("jakewvincent/mkdnflow.nvim")
        -- use("vim-pandoc/vim-pandoc-syntax")
	use("folke/twilight.nvim")
	use("folke/noice.nvim")
	use("MunifTanjim/nui.nvim")
	-- use("rcarriga/nvim-notify")
	-- use("kevinhwang91/nvim-ufo")
	-- use("stevearc/oil.nvim") -- filesystem dótið
end)

---- Shortlist ----------------------------------
-- use({ "mrjones2014/legendary.nvim" }) -- Lítur mjög vel út en virðist vera
-- maus að stilla almennilega
        -- use("terryma/vim-expand-region")
