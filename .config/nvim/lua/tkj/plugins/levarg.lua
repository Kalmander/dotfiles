return {
	"lervag/vimtex",
	{
		"lervag/wiki.vim",
		init = function()
			vim.g.wiki_root = '~/'
			vim.g.wiki_filetypes = {'md'}
			vim.g.wiki_link_extension = '.md'
		end
	},
	-- "lervag/wiki-ft.vim",
	"lervag/lists.vim",
}
