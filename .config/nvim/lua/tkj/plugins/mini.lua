return {
	{
		'echasnovski/mini.indentscope',
		config = function()
			require("mini.indentscope").setup({
				draw = {
					animation = require("mini.indentscope").
					gen_animation.quadratic({
						easing = 'in',
						duration = 10,
						unit = 'step',
					})
				},
				-- symbol = '╎',
				symbol = '⎜',
			})
		end
	},

	{
		'echasnovski/mini.jump',
		config = function()
			require("mini.jump").setup({
				mappings = {
					repeat_jump = '',
				}
			})
                        vim.api.nvim_set_hl(0, "MiniJump", { bold = true, italic = true })
		end
	},
}
