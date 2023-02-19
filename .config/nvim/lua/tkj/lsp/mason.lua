local servers = {
	"lua_ls",
	"cssls",
	"html",
	"tsserver",
	"pyright",
	"bashls",
	"jsonls",
	"yamlls",
	"texlab",
	"r_language_server",
	-- "rust_analyzer", -- rust pluginið sér um þetta
	-- "codelldb",
}


require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = servers,
	automatic_installation = true,
})
local lspconfig = require("lspconfig")

local opts = {}
for _, server in pairs(servers) do
	opts = {
		on_attach = require("tkj.lsp.handlers").on_attach,
		capabilities = require("tkj.lsp.handlers").capabilities,
	}


	local require_ok, conf_opts = pcall(require, "tkj.lsp.settings." .. server)
	if require_ok then
		opts = vim.tbl_deep_extend("force", conf_opts, opts)
	end

	lspconfig[server].setup(opts)
end
