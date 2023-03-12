return {
	{
		'neovim/nvim-lspconfig',
		dependencies = {
			'williamboman/mason.nvim',
			'williamboman/mason-lspconfig.nvim',

			{ 'j-hui/fidget.nvim', config = true },

			'folke/neodev.nvim',
			"jose-elias-alvarez/null-ls.nvim",
		},
	},
}
