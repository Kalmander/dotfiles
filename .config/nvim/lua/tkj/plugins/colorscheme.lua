local current = "sonokai"
local set_hl = vim.api.nvim_set_hl
local function false_if_current(colorscheme, curr)
	if colorscheme == curr then
		return false
	else
		return true
	end
end
local function high_priority_if_current(colorscheme, curr)
	if colorscheme == curr then
		return 1000
	else
		return 50 -- default priorityið
	end
end

-- til að gera cursorinn hvítann í insert mode því ég nota kitty litinn sem
-- líkir eftir bakgrunni og það sést stundum illa í insert mode
--set_hl(0, "Cursor2", { fg = "white", bg = "white" })
--vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor2/lCursor2,r-cr:hor20,o:hor50"

return {

	{
		"sainnhe/sonokai",
		lazy = false_if_current("sonokai", current),
		priority = high_priority_if_current("sonokai", current),
		config = function()
			if current ~= "sonokai" then
				return
			end

			vim.g.sonokai_better_performance = 1
			vim.g.sonokai_diagnostic_virtual_text = "colored" -- grey eða  colored
			vim.g.sonokai_style = "default"
			--	`'default'`, `'atlantis'`, `'andromeda'`, `'shusia'`, `'maia'`,`'espresso'`
			vim.g.sonokai_enable_italic = 1
			vim.g.sonokai_transparent_background = 1

			vim.cmd.colorscheme("sonokai")

			set_hl(0, "SpecialKey", { fg = "#b39df3" })
			set_hl(0, "CursorLineNR", { fg = "#b39df3" })
			local conceal_col = "#85d3f2"
			set_hl(0, "Conceal", { fg = conceal_col })
			local math_col = "#fc5d7c"
			local math_col_2 = "#a7df78"
			set_hl(0, "mkdMath", { fg = math_col })
			set_hl(0, "texMathZoneTI", { fg = math_col })
			set_hl(0, "texMathDelimZoneTI", { fg = math_col })
			-- set_hl(0, "texMathDelim", {fg=math_col})
			set_hl(0, "texMathSuperSub", { fg = math_col })
			set_hl(0, "texMathOper", { fg = math_col })
			set_hl(0, "texMathArg", { fg = math_col })
			set_hl(0, "texMathCmd", { fg = math_col_2 })

			set_hl(0, "Search", { fg = "#16181d", bg = "#eed581" })
			set_hl(0, "IncSearch", { fg = "#16181d", bg = "#bbe89b" })
		end,
	},

        {
                "navarasu/onedark.nvim",
                lazy = false_if_current("onedark", current),
                priority = high_priority_if_current("onedark", current),
                config = function()
                        if current ~= "onedark" then
                                return
                        end

                        -- Þarft ekki setupið nema þú viljir breyta settings
                        require("onedark").setup({
                                --> 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
                                style = "deep",
                                transparent = true,

                                -- toggle_style_key = "<leader>ts",
                        })

                        vim.cmd.colorscheme("onedark")
                end,
        },

        {
                "folke/tokyonight.nvim",
                lazy = false_if_current("tokyonight", current),
                priority = high_priority_if_current("tokyonight", current),
                config = function()
                        if current ~= "tokyonight" then
                                return
                        end
                        require("tokyonight").setup({
                                style = "storm",
                                --> storm, moon, night, day
                        })

                        vim.cmd.colorscheme("tokyonight")
                end,
        },

	{
		"shaunsingh/nord.nvim",
		lazy = false_if_current("nord", current),
		priority = high_priority_if_current("nord", current),
		config = function()
			if current ~= "nord" then
				return
			end

			vim.cmd.colorscheme("nord")
		end,
	},

	{
		"rebelot/kanagawa.nvim",
		lazy = false_if_current("kanagawa", current),
		priority = high_priority_if_current("kanagawa", current),
		config = function()
			if current ~= "kanagawa" then
				return
			end

			require("kanagawa").setup({
				transparent = true
			})

			vim.cmd.colorscheme("kanagawa")
		end,
	},
}
