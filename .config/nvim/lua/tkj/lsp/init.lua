local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require("tkj.lsp.mason")
require("tkj.lsp.handlers").setup()
require("tkj.lsp.null-ls")
