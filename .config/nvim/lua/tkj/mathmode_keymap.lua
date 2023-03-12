local switch2eng = function()
	if vim.opt.keymap:get() == "ice" then
                vim.cmd("setlocal keymap=")
	end
end

local switch2ice = function()
	if vim.opt.keymap:get() == "" then
                vim.cmd("setlocal keymap=ice")
	end
end

local toggle_mathmode_input = function()
	if vim.fn["vimtex#syntax#in_mathzone"]() == 1 then
		switch2eng()
	else
		switch2ice()
	end
end

vim.api.nvim_create_autocmd({ "CursorMovedI", "CursorHoldI", "InsertEnter", "TextChangedI" }, {
	pattern = { "*.tex", "*.md" },
	callback = toggle_mathmode_input,
})
