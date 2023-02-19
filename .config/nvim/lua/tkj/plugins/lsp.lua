return {
	"neovim/nvim-lspconfig", -- enable LSP
	"williamboman/mason.nvim", -- simple to use language server installer
	"williamboman/mason-lspconfig.nvim", -- bridge the gap between mason and lspconfig
	--  bara prufa
	"jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
	"j-hui/fidget.nvim",
	{
		"simrat39/rust-tools.nvim",
		config = function()
			require("rust-tools").setup({
				server = {
					on_attach = function(_, bufnr)
						require("tkj.keymaps"):set_lsp_keymaps(bufnr)
					end,
				},
			})
		end,
	},
}
