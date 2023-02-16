return {
	"folke/noice.nvim",
	"folke/twilight.nvim",
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
	{ "folke/trouble.nvim", dependencies = "kyazdani42/nvim-web-devicons" },
}
