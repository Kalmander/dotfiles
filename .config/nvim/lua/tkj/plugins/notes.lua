return {
	"godlygeek/tabular",
	{
		"preservim/vim-markdown",
		init = function()
			-- gerði þetta því var að lenda í bugs vegna 
			-- víxlverkunnar þessa plugins við ufo
			vim.g.vim_markdown_folding_disabled = 1
		end,
	},
	"preservim/vim-pencil",
	"dhruvasagar/vim-table-mode",
}
