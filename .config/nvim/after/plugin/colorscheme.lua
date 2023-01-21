require('onedark').setup  {
	-- Main options --
	style = 'warmer', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
	-- transparent = true,  -- Show/hide background
	term_colors = true, -- Change terminal color as per the selected theme style-vim.cmd([[colorscheme sonokai]])

	lualine = {
		-- transparent = true, -- lualine center bar transparency
	},
}
vim.g.sonokai_diagnostic_virtual_text = 'colored' -- grey eða  colored


	-- "dracula/vim" -> dracule
	-- "sainnhe/sonokai"
	-- "navarasu/onedark.nvim"
	-- "rose-pine/neovim" -> rose-pine
	-- "sainnhe/everforest"
	-- "shaunsingh/nord.nvim"
        -- "sonph/onehalf"  -> onehalfdark
-- vim.cmd.colorscheme('sonokai')
vim.cmd.colorscheme('onedark')
-- vim.cmd('hi CursorLine gui=bold')
vim.cmd('hi IlluminatedWordText gui=bold')
vim.cmd('hi IlluminatedWordRead gui=bold')
vim.cmd('hi IlluminatedWordWrite gui=bold')

-- vim.cmd('hi clear Conceal') -- til að latex conceal verði ekki grátt á gráum bakgrunn
-- vim.cmd([[hi Conceal guifg=#6bc3cc]]) -- Gerir conceal mjög líkt highlightinu á textanum í tex

vim.cmd([[hi clear Conceal]])
vim.cmd([[hi Conceal guifg=#acd8dc]])


-- til að gera cursorinn hvítann í insert mode 
-- því ég nota kitty litinn sem líkir eftir bakgrunni
-- og það sést stundum illa í insert mode
vim.cmd([[hi Cursor2 guifg=white guibg=white]])
vim.cmd([[set guicursor=n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor2/lCursor2,r-cr:hor20,o:hor50]])




-- vim.api.nvim_set_hl(0, "NormalFloat", {bg="none"})
-- vim.api.nvim_set_hl(0, "FloatBorder", {bg="none"})
-- vim.api.nvim_set_hl(0, "Pmenu", {bg="none"})

-- Kann ekki að gera í lua syntax...
-- vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", {guibg='#2c2e34', gui='nocombine'})
-- vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", {guibg='#2a2c32', gui='nocombine'})
-- vim.api.nvim_set_hl(0, "IndentBlanklineContextChar", {guibg='#797986', gui='nocombine'})
-- vim.cmd([[highlight IndentBlanklineIndent1 guibg=#2c2e34 gui=nocombine]])
-- vim.cmd([[highlight IndentBlanklineIndent2 guibg=#2a2c32 gui=nocombine]])
-- vim.cmd[[highlight IndentBlanklineContextChar guifg=#797986 gui=nocombine]]
-- require("indent_blankline").setup({
	-- show_current_context = true,
-- })
-- 	-- char_highlight_list = {
-- 	-- 	"IndentBlanklineIndent1",
-- 	-- 	"IndentBlanklineIndent2",
-- 	-- },
-- 	-- space_char_highlight_list = {
-- 	-- 	"IndentBlanklineIndent1",
-- 	-- 	"IndentBlanklineIndent2",
-- 	-- },
-- 	-- for example, context is off by default, use this to turn it on
-- 	-- show_current_context_start = true,
-- 	-- show_current_context = true,
