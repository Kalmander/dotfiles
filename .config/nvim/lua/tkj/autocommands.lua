-- Af einhverjum ástæðum resettast formatoptions 
-- (eitthvað C plugin) svo þarf að stilla þau svona 
vim.cmd([[
augroup _general_settings
    autocmd!
    autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200}) 
    autocmd BufWinEnter * :set formatoptions-=cro " Lagar comment haldi áfram í newline
    autocmd BufWinEnter * :set formatoptions+=t "Þarft fyrir tw, mælt með að nota += 
    autocmd BufRead,BufNewFile *.md ListsEnable
augroup end
]])

vim.cmd([[autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown]])


-- Show autodiagnostic popup on cursor hover_range
-- Show inlay_hints more frequently
-- vim.cmd([[
-- set signcolumn=yes
-- autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
-- ]])



-- Eftirfarandi gerir lætur vim opna lf í stað netrw á startup
-- er partur af plpugininu en var ekki að virka for som raisin
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
