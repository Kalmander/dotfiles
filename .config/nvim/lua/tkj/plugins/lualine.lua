local function searchcount_if_hi(str)
        if vim.v.hlsearch == 1 then
                return str
        else
                return ""
        end
end

local function keymap()
        -- if vim.fn.mode() ~= 'i' then return '' end
        if vim.opt.iminsert:get() > 0 and vim.b.keymap_name then
                return "⌨ " .. vim.b.keymap_name
        end
        return ""
end

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "kyazdani42/nvim-web-devicons", opt = true },
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "auto",
					-- component_separators = { left = "", right = "" },
					-- section_separators = { left = "", right = "" },
                                        -- section_separators = { left = '', right = '' },
                                        -- component_separators = { left = '', right = '' },
					component_separators = { " ", " " },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {
						statusline = { "toggleterm" },
						winbar = { "toggleterm" },
					},
					ignore_focus = {},
					always_divide_middle = true,
					globalstatus = true,
					refresh = {
						statusline = 1000,
						tabline = 1000,
						winbar = 1000,
					},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{ keymap },
						-- { "searchcount", searchcount_if_hi },
						function()
							return "%="
						end,
						{
							"filename",
							path = 1,
							newfile_status = true,
							shorting_target=1000,
							symbols = {
							  modified = "落",
							  readonly = "",
							  unnamed = "[No Name]",
							  newfile = "[New]",
							},
						}
					},
				        lualine_x = { "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},
}
