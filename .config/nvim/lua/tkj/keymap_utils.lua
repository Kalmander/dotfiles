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
M.toggle_zen = function(force)
	if zen_toggled and force ~= 'on' then
		zen_toggled = false
		require("true-zen.minimalist").off()
                require("lualine").hide({unhide=true})
                -- vim.opt.cmdheight = 1
        elseif force ~= 'off' then
		zen_toggled = true
                require("lualine").hide()
		require("true-zen.minimalist").on()
                vim.opt.number = true
                vim.opt.relativenumber = true
                -- vim.opt.cmdheight = 0
	end
end

M.toggle_zen_ataraxis = function()
	if zen_toggled then
		zen_toggled = false
		require("true-zen.ataraxis").off()
                require("lualine").hide({unhide=true})
                -- vim.opt.cmdheight = 1
	else
		zen_toggled = true
                require("lualine").hide()
		require("true-zen.ataraxis").on()
                -- vim.opt.cmdheight = 0
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

-- M.obsidian_link = function()
--         if require('obsidian').util.cursor_on_markdown_link() then
--                 return "<cmd>ObsidianFollowLink<CR>"
--         else
--                 return "<CR>"
--         end
-- end

M.toggle_conceallevel = function()
        if vim.opt.conceallevel:get() == 0 then
		vim.opt.conceallevel = 2
	else
		vim.opt.conceallevel = 0
	end
end

M.toggle_concealcursor = function()
        if vim.opt.concealcursor:get() == '' then
		vim.opt.concealcursor = 'n'
	else
		vim.opt.concealcursor = ''
	end
end

M.get_ts_hl_group = function()
	-- Gæinn sem prentast lengst til hægri er ráðandi svo vilt
	-- breyta honum til að breyta litnum
	-- Gætir þurft að bæta @ framan við nafnið í nvim_hl allinu td
	-- vim.api.nvim_set_hl(0, "@variable",              { <colors-here> })
	-- veit ekki hvenær þetta er the shit vs hvenær gamla SynStack dótið er málið
	local result = vim.treesitter.get_captures_at_cursor(0)
        print(vim.inspect(result))
end

local cursor_hidden = false
M.hide_cursor = function()
	-- Ætti að bæta þetta með því að stela frá
	-- auto hl search plugininu góða
	if cursor_hidden then
		-- vim.api.nvim_set_hl(0, "Cursor", {blend=0})
		vim.cmd([[hi Cursor blend=0]])
		cursor_hidden = false
	else
		-- vim.api.nvim_set_hl(0, "Cursor", {blend=100})
		vim.cmd([[hi Cursor blend=100]])
		cursor_hidden = true
	end
end

M.open_calendar = function()
	vim.cmd([[:Calendar -position=here]])
	require("true-zen.minimalist").on()
	require("lualine").hide()
end

return M
