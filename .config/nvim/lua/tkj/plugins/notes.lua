return {
	{
		"preservim/vim-markdown",
		init = function()
			vim.g.vim_markdown_folding_disabled = 1 -- fyrir ufo
			vim.g.vim_markdown_math = 1
		end,
	},
	"godlygeek/tabular",
	"dhruvasagar/vim-table-mode",
}
