M = {}

M.winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {{function() return vim.loop.cwd() end, color = { fg = '#7d7d7d' }}},
        lualine_x = {},
        lualine_y = { { "filename", path = 1 } },
        lualine_z = {},
}

M.emptybar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
}

return M
