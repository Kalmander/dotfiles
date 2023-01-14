local switcher_toggled = true
local lualine = require("lualine")

local switch2eng = function()
        if (vim.opt.iminsert._value == 1) then
                vim.cmd([[call feedkeys("\<C-^>")]])
                lualine.refresh()
        end
end

local switch2ice = function()
        if (vim.opt.iminsert._value == 0) and switcher_toggled then
                vim.cmd([[call feedkeys("\<C-^>")]])
                lualine.refresh()
        end
end

local refresh_layout = function()
        switcher_toggled = not switcher_toggled
        vim.cmd([[call feedkeys("\<C-^>")]])
        lualine.refresh()
end

vim.keymap.set("i", "<c-e>", refresh_layout, {noremap = true, silent=true})

local in_mathzone = function()
	return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local toggle_mathmode_input = function()
	if in_mathzone() then
		switch2eng()
	else
		switch2ice()
	end
end

vim.api.nvim_create_autocmd(
        {"CursorMovedI", "CursorHoldI", "InsertEnter", "TextChangedI"},
        {
                pattern = {"*.tex", "*.sty", "*.md"},
                callback =toggle_mathmode_input
        }
)
