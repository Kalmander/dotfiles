local lualine = require("tkj.lualine_settings")
M = {}

M.set_keymap = function(mode, lhs, rhs, options)
	if options == nil then
		options = { noremap = true, silent = true }
	elseif type(options) == "table" then
		if options["noremap"] == nil then
			options["noremap"] = true
		end
		if options["silent"] == nil then
			options["silent"] = true
		end
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

M.set_keymaps_multi = function(mode, map_table, options)
	for lhs, rhs in pairs(map_table) do
		vim.keymap.set(mode, lhs, rhs, options)
	end
end

local zen_toggled = false
M.toggle_zen = function()
	if zen_toggled then
		zen_toggled = false
		require('lualine').setup({ winbar = lualine.winbar })
		require("true-zen.minimalist").off()
                vim.opt.cmdheight = 1
	else
		zen_toggled = true
		require('lualine').setup({ winbar = lualine.emptybar })
		require("true-zen.minimalist").on()
                vim.opt.cmdheight = 0
	end
end

M.reload_lua = function()
	for name, _ in pairs(package.loaded) do
		if name:match("^tkj") then
			package.loaded[name] = nil
		end
	end
	dofile(vim.env.MYVIMRC)
end

-- Stolið af reddit en virkar ekki alveg 
-- Getur slökkt á diagnostics, getur bara ekki kveikt á því aftur
local diagnostics_toggled = true
M.toggle_diagnostics = function()
	if diagnostics_toggled then
		diagnostics_toggled = false
                vim.diagnostic.disable()
	else
		diagnostics_toggled = true
                vim.diagnostic.enable()
	end
end

return M
