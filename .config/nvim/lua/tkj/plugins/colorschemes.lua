local current = 'sonokai'
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
	        vim.g.sonokai_style = "atlantis"
	        --	`'default'`, `'atlantis'`, `'andromeda'`, `'shusia'`, `'maia'`,`'espresso'`
	        vim.g.sonokai_enable_italic = 1

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
	            style = "deep",
	            --> 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'

	            -- toggle_style_key = "<leader>ts",
	        })

	        vim.cmd.colorscheme("onedark")
        end,
    },

    {
        "rose-pine/neovim",
        as = "rose-pine",
        lazy = false_if_current("rose-pine", current),
        priority = high_priority_if_current("rose-pine", current),
        config = function()
	        if current ~= "rose-pine" then
		        return
	        end

	        require("rose-pine").setup({
	            dark_variant = "moon",
	        })
	        vim.cmd.colorscheme("rose-pine")
        end,
    },

    {
        "sainnhe/everforest",
        lazy = false_if_current("everforest", current),
        priority = high_priority_if_current("everforest", current),
        config = function()
	        if current ~= "everforest" then
		        return
	        end

	        vim.g.everforest_background = "hard"
	        --> 'hard', 'medium'(default), 'soft'
	        vim.g.everforest_better_performance = 1

	        vim.cmd.colorscheme("everforest")
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

	        vim.cmd.colorscheme("kanagawa")
        end,
    },

    {
        "catppuccin/nvim",
        lazy = false_if_current("catppuccin", current),
        priority = high_priority_if_current("catppuccin", current),
        config = function()
	        if current ~= "catppuccin" then
		        return
	        end

	        --> catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
	        vim.cmd.colorscheme("catppuccin")
        end,
    },
}
