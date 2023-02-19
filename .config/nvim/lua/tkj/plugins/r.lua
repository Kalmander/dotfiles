return {
	{
		"jamespeapen/Nvim-R",
		init = function()
			vim.g.rout_follow_colorscheme = 1
			vim.g.Rout_more_colors = 1
			vim.g.R_assign = 0
			vim.g.R_nvim_wd = 1
			vim.g.R_csv_app = 'terminal:vd'
		end,
	},
	"jalvesaq/cmp-nvim-r",
}
