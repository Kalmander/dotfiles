local options = {
	clipboard      = "unnamedplus",
	number         = true,
	relativenumber = true,
	termguicolors  = true,
	wrap           = false,
	linebreak      = true, -- companion to wrap, don't split words
	expandtab      = true,
	undofile       = true,
	virtualedit    = "none",
	scrolloff      = 6,
	sidescrolloff  = 1,
	conceallevel   = 2,
        concealcursor  = 'n',
	ignorecase     = true,
	smartcase      = true,
	smartindent    = true,
	timeoutlen     = 400, -- time to wait for a mapped sequence to complete
	updatetime     = 300, -- faster completion (4000ms default)
	hlsearch       = true, -- highlight all matches on previous search pattern
	cursorline     = true,
	laststatus     = 3, -- default er 2
        splitright     = true,
	swapfile       = true,
	directory      = vim.fn.expand("~/.backups/swp//"),
	signcolumn     = "yes", -- always show the sign column, otherwise it would shift the text each time
	showmode       = false,
}
for k, v in pairs(options) do
	vim.opt[k] = v
end

vim.cmd([[
augroup _general_settings
    autocmd!
    autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200}) 
    " autocmd BufWinEnter * :set formatoptions-=cro " Lagar comment haldi áfram í newline
    " autocmd BufWinEnter * :set formatoptions+=t "Þarft fyrir tw, mælt með að nota += 
    " autocmd BufRead,BufNewFile *.md ListsEnable
    autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown
augroup end
]])
