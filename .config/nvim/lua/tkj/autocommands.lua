-- Af einhverjum ástæðum resettast formatoptions 
-- (eitthvað C plugin) svo þarf að stilla þau svona 
vim.cmd([[
augroup _general_settings
    autocmd!
    autocmd TextYankPost * silent!lua require('vim.highlight').on_yank({higroup = 'Visual', timeout = 200}) 
    autocmd BufWinEnter * :set formatoptions-=cro " Lagar comment haldi áfram í newline
    autocmd BufWinEnter * :set formatoptions+=t "Þarft fyrir tw, mælt með að nota += 
    autocmd BufRead,BufNewFile *.md ListsEnable
    autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown
augroup end
]])
