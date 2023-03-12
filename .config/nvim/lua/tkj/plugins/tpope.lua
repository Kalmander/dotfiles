return {
	"tpope/vim-repeat",
	"tpope/vim-unimpaired",
	"tpope/vim-fugitive",
	"tpope/vim-sleuth",
	{
		"tpope/vim-rsi",
		init = function()
			-- tpope bætir við alt- (meta) mappings 
			-- úr readline en eǵ vil frekar native vim
			-- alt hegðunina, td út af alt-p fyrir paste
			-- í insert mode
			vim.g.rsi_no_meta = 1
		end,
	},
}
