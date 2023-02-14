local set_hl = function(...)
	local args = { ... }
	vim.api.nvim_set_hl(0, unpack(args))
end

require("onedark").setup({
	style = "warmer", -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
	term_colors = true, -- Change terminal color as per the selected theme style-vim.cmd([[colorscheme sonokai]])
})

vim.g.sonokai_diagnostic_virtual_text = "colored" -- grey eða  colored
vim.g.sonokai_style = "atlantis"
vim.g.sonokai_enable_italic = 1

-- "dracula/vim" -> dracula
-- "sainnhe/sonokai"
--	`'default'`, `'atlantis'`, `'andromeda'`, `'shusia'`, `'maia'`,`'espresso'`
-- "navarasu/onedark.nvim"
-- "rose-pine/neovim" -> rose-pine
-- "sainnhe/everforest"
-- "shaunsingh/nord.nvim"
-- "sonph/onehalf"  -> onehalfdark
local current_scheme = "sonokai"
vim.cmd.colorscheme(current_scheme)

if current_scheme == "sonokai" then
	set_hl("SpecialKey", { fg = "#b39df3" })
	set_hl("CursorLineNR", { fg = "#b39df3" })
	local conceal_col = "#85d3f2"
	set_hl("Conceal", { fg = conceal_col })
	local math_col = "#fc5d7c"
	local math_col_2 = "#a7df78"
	set_hl("mkdMath", { fg = math_col })
	set_hl("texMathZoneTI", { fg = math_col })
	set_hl("texMathDelimZoneTI", { fg = math_col })
	-- set_hl("texMathDelim", {fg=math_col})
	set_hl("texMathSuperSub", { fg = math_col })
	set_hl("texMathOper", { fg = math_col })
	set_hl("texMathArg", { fg = math_col })
	set_hl("texMathCmd", { fg = math_col_2 })
end

set_hl("IlluminatedWordText", { bold = true })
set_hl("IlluminatedWordRead", { bold = true })
set_hl("IlluminatedWordWrite", { bold = true })


-- vim.api.nvim_set_hl(0, "LeapLabelPrimary", {fg = "red", bold = true, nocombine = true })
-- vim.api.nvim_set_hl(0, "LeapLabelSecondary", {fg = "blue", bold = true, nocombine = true })

-- til að gera cursorinn hvítann í insert mode því ég nota kitty litinn sem
-- líkir eftir bakgrunni og það sést stundum illa í insert mode
set_hl("Cursor2", { fg = "white", bg = "white" })
vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor2/lCursor2,r-cr:hor20,o:hor50"


-----------------------------------------------------------------------------------------
-- Sonokai litirnir:
-- if a:style ==# 'default'
--   let palette = {
--         \ 'black':      ['#181819',   '232'],
--         \ 'bg_dim':     ['#222327',   '232'],
--         \ 'bg0':        ['#2c2e34',   '235'],
--         \ 'bg1':        ['#33353f',   '236'],
--         \ 'bg2':        ['#363944',   '236'],
--         \ 'bg3':        ['#3b3e48',   '237'],
--         \ 'bg4':        ['#414550',   '237'],
--         \ 'bg_red':     ['#ff6077',   '203'],
--         \ 'diff_red':   ['#55393d',   '52'],
--         \ 'bg_green':   ['#a7df78',   '107'],
--         \ 'diff_green': ['#394634',   '22'],
--         \ 'bg_blue':    ['#85d3f2',   '110'],
--         \ 'diff_blue':  ['#354157',   '17'],
--         \ 'diff_yellow':['#4e432f',   '54'],
--         \ 'fg':         ['#e2e2e3',   '250'],
--         \ 'red':        ['#fc5d7c',   '203'],
--         \ 'orange':     ['#f39660',   '215'],
--         \ 'yellow':     ['#e7c664',   '179'],
--         \ 'green':      ['#9ed072',   '107'],
--         \ 'blue':       ['#76cce0',   '110'],
--         \ 'purple':     ['#b39df3',   '176'],
--         \ 'grey':       ['#7f8490',   '246'],
--         \ 'grey_dim':   ['#595f6f',   '240'],
--         \ 'none':       ['NONE',      'NONE']
--         \ }
-- elseif a:style ==# 'shusia'
--   let palette = {
--         \ 'black':      ['#1a181a',   '232'],
--         \ 'bg_dim':     ['#211f21',   '232'],
--         \ 'bg0':        ['#2d2a2e',   '235'],
--         \ 'bg1':        ['#37343a',   '236'],
--         \ 'bg2':        ['#3b383e',   '236'],
--         \ 'bg3':        ['#423f46',   '237'],
--         \ 'bg4':        ['#49464e',   '237'],
--         \ 'bg_red':     ['#ff6188',   '203'],
--         \ 'diff_red':   ['#55393d',   '52'],
--         \ 'bg_green':   ['#a9dc76',   '107'],
--         \ 'diff_green': ['#394634',   '22'],
--         \ 'bg_blue':    ['#78dce8',   '110'],
--         \ 'diff_blue':  ['#354157',   '17'],
--         \ 'diff_yellow':['#4e432f',   '54'],
--         \ 'fg':         ['#e3e1e4',   '250'],
--         \ 'red':        ['#f85e84',   '203'],
--         \ 'orange':     ['#ef9062',   '215'],
--         \ 'yellow':     ['#e5c463',   '179'],
--         \ 'green':      ['#9ecd6f',   '107'],
--         \ 'blue':       ['#7accd7',   '110'],
--         \ 'purple':     ['#ab9df2',   '176'],
--         \ 'grey':       ['#848089',   '246'],
--         \ 'grey_dim':   ['#605d68',   '240'],
--         \ 'none':       ['NONE',      'NONE']
--         \ }
-- elseif a:style ==# 'andromeda'
--   let palette = {
--         \ 'black':      ['#181a1c',   '232'],
--         \ 'bg_dim':     ['#252630',   '232'],
--         \ 'bg0':        ['#2b2d3a',   '235'],
--         \ 'bg1':        ['#333648',   '236'],
--         \ 'bg2':        ['#363a4e',   '236'],
--         \ 'bg3':        ['#393e53',   '237'],
--         \ 'bg4':        ['#3f445b',   '237'],
--         \ 'bg_red':     ['#ff6188',   '203'],
--         \ 'diff_red':   ['#55393d',   '52'],
--         \ 'bg_green':   ['#a9dc76',   '107'],
--         \ 'diff_green': ['#394634',   '22'],
--         \ 'bg_blue':    ['#77d5f0',   '110'],
--         \ 'diff_blue':  ['#354157',   '17'],
--         \ 'diff_yellow':['#4e432f',   '54'],
--         \ 'fg':         ['#e1e3e4',   '250'],
--         \ 'red':        ['#fb617e',   '203'],
--         \ 'orange':     ['#f89860',   '215'],
--         \ 'yellow':     ['#edc763',   '179'],
--         \ 'green':      ['#9ed06c',   '107'],
--         \ 'blue':       ['#6dcae8',   '110'],
--         \ 'purple':     ['#bb97ee',   '176'],
--         \ 'grey':       ['#7e8294',   '246'],
--         \ 'grey_dim':   ['#5a5e7a',   '240'],
--         \ 'none':       ['NONE',      'NONE']
--         \ }
-- elseif a:style ==# 'atlantis'
--   let palette = {
--         \ 'black':      ['#181a1c',   '232'],
--         \ 'bg_dim':     ['#24272e',   '232'],
--         \ 'bg0':        ['#2a2f38',   '235'],
--         \ 'bg1':        ['#333846',   '236'],
--         \ 'bg2':        ['#373c4b',   '236'],
--         \ 'bg3':        ['#3d4455',   '237'],
--         \ 'bg4':        ['#424b5b',   '237'],
--         \ 'bg_red':     ['#ff6d7e',   '203'],
--         \ 'diff_red':   ['#55393d',   '52'],
--         \ 'bg_green':   ['#a5e179',   '107'],
--         \ 'diff_green': ['#394634',   '22'],
--         \ 'bg_blue':    ['#7ad5f1',   '110'],
--         \ 'diff_blue':  ['#354157',   '17'],
--         \ 'diff_yellow':['#4e432f',   '54'],
--         \ 'fg':         ['#e1e3e4',   '250'],
--         \ 'red':        ['#ff6578',   '203'],
--         \ 'orange':     ['#f69c5e',   '215'],
--         \ 'yellow':     ['#eacb64',   '179'],
--         \ 'green':      ['#9dd274',   '107'],
--         \ 'blue':       ['#72cce8',   '110'],
--         \ 'purple':     ['#ba9cf3',   '176'],
--         \ 'grey':       ['#828a9a',   '246'],
--         \ 'grey_dim':   ['#5a6477',   '240'],
--         \ 'none':       ['NONE',      'NONE']
--         \ }
-- elseif a:style ==# 'maia'
--   let palette = {
--         \ 'black':      ['#1c1e1f',   '232'],
--         \ 'bg_dim':     ['#21282c',   '232'],
--         \ 'bg0':        ['#273136',   '235'],
--         \ 'bg1':        ['#313b42',   '236'],
--         \ 'bg2':        ['#353f46',   '236'],
--         \ 'bg3':        ['#3a444b',   '237'],
--         \ 'bg4':        ['#414b53',   '237'],
--         \ 'bg_red':     ['#ff6d7e',   '203'],
--         \ 'diff_red':   ['#55393d',   '52'],
--         \ 'bg_green':   ['#a2e57b',   '107'],
--         \ 'diff_green': ['#394634',   '22'],
--         \ 'bg_blue':    ['#7cd5f1',   '110'],
--         \ 'diff_blue':  ['#354157',   '17'],
--         \ 'diff_yellow':['#4e432f',   '54'],
--         \ 'fg':         ['#e1e2e3',   '250'],
--         \ 'red':        ['#f76c7c',   '203'],
--         \ 'orange':     ['#f3a96a',   '215'],
--         \ 'yellow':     ['#e3d367',   '179'],
--         \ 'green':      ['#9cd57b',   '107'],
--         \ 'blue':       ['#78cee9',   '110'],
--         \ 'purple':     ['#baa0f8',   '176'],
--         \ 'grey':       ['#82878b',   '246'],
--         \ 'grey_dim':   ['#55626d',   '240'],
--         \ 'none':       ['NONE',      'NONE']
--         \ }
-- elseif a:style ==# 'espresso'
--   let palette = {
--         \ 'black':      ['#1f1e1c',   '232'],
--         \ 'bg_dim':     ['#242120',   '232'],
--         \ 'bg0':        ['#312c2b',   '235'],
--         \ 'bg1':        ['#393230',   '236'],
--         \ 'bg2':        ['#413937',   '236'],
--         \ 'bg3':        ['#49403c',   '237'],
--         \ 'bg4':        ['#4e433f',   '237'],
--         \ 'bg_red':     ['#fd6883',   '203'],
--         \ 'diff_red':   ['#55393d',   '52'],
--         \ 'bg_green':   ['#adda78',   '107'],
--         \ 'diff_green': ['#394634',   '22'],
--         \ 'bg_blue':    ['#85dad2',   '110'],
--         \ 'diff_blue':  ['#354157',   '17'],
--         \ 'diff_yellow':['#4e432f',   '54'],
--         \ 'fg':         ['#e4e3e1',   '250'],
--         \ 'red':        ['#f86882',   '203'],
--         \ 'orange':     ['#f08d71',   '215'],
--         \ 'yellow':     ['#f0c66f',   '179'],
--         \ 'green':      ['#a6cd77',   '107'],
--         \ 'blue':       ['#81d0c9',   '110'],
--         \ 'purple':     ['#9fa0e1',   '176'],
--         \ 'grey':       ['#90817b',   '246'],
--         \ 'grey_dim':   ['#6a5e59',   '240'],
--         \ 'none':       ['NONE',      'NONE']
--         \ }
-- endif