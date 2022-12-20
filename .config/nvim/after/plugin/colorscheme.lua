require('onedark').setup  {
	-- Main options --
	style = 'warmer', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
	-- transparent = true,  -- Show/hide background
	term_colors = true, -- Change terminal color as per the selected theme style-vim.cmd([[colorscheme sonokai]])

	lualine = {
		-- transparent = true, -- lualine center bar transparency
	},
}
-- vim.g.sonokai_transparent_background = 2
vim.g.sonokai_diagnostic_virtual_text = 'colored' -- grey eða  colored

vim.cmd.colorscheme('sonokai')
-- vim.api.nvim_set_hl(0, "NormalFloat", {bg="none"})
-- vim.api.nvim_set_hl(0, "FloatBorder", {bg="none"})
-- vim.api.nvim_set_hl(0, "Pmenu", {bg="none"})
