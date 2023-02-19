-- Eftirfarandi gerir lætur vim opna lf í stað netrw á startup
-- er partur af plpugininu en var ekki að virka for som raisin
-- svo ég koppíaði það hingað og þá virkaði allt
local api = vim.api
local fn = vim.fn
local group = api.nvim_create_augroup("ReplaceNetrwWithLf", {clear = true})
api.nvim_create_autocmd(
    "VimEnter",
    {
	pattern = "*",
	group = group,
	once = true,
	callback = function()
	    if fn.exists("#FileExplorer") then
		vim.cmd("silent! autocmd! FileExplorer")
	    end
	end
    }
)
api.nvim_create_autocmd(
    "BufEnter",
    {
	pattern = "*",
	group = group,
	once = true,
	callback = function()
	    local bufnr = api.nvim_get_current_buf()
	    local path = require("plenary.path"):new(fn.expand("%"))
	    if path:is_dir() and fn.argc() ~= 0 then
		vim.cmd(("sil! bwipeout! %s"):format(bufnr))

		vim.defer_fn(
		    function()
			require("lf").start(path:absolute())
		    end,
		    1
		)
	    end
	end
    }
)


return {
	{
		"lmburns/lf.nvim",
		lazy = false,
		config = function()
			-- This feature will not work if the plugin is lazy-loaded
			vim.g.lf_netrw = 1

			require("lf").setup({
				escape_quit = false,
				border = "solid",
				-- highlights = { FloatBorder = { guifg = require("kimbox.palette").colors.magenta } },
				direction = "float",
				-- open_mapping = [[;]],
				-- on_open = function() vim.cmd([[:Lf<cr>]]) end,
				shade_terminals = false,
				winblend = 0,
				width = 1,
				height = 1,
				default_actions = { -- default action keybindings
					["<C-;>"] = "cd",
					["<C-s>"] = "split", --defaultið er c-x
				},
				on_open = function(term)
					vim.api.nvim_buf_set_keymap(
						term.bufnr,
						"t",
						"a",
						"<cmd>close<CR>",
						{ noremap = true, silent = true }
					)
				end,
			})
		end,
		dependencies = { "plenary.nvim", "toggleterm.nvim" },
	},
}
