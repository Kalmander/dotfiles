-- Litir teknir úr sonokai atlantis
local colors = {
	black       = '#181a1c',
	bg_dim      = '#24272e',
	bg0         = '#2a2f38',
	bg1         = '#333846',
	bg2         = '#373c4b',
	bg3         = '#3d4455',
	bg4         = '#424b5b',
	bg_red      = '#ff6d7e',
	diff_red    = '#55393d',
	bg_green    = '#a5e179',
	diff_green  = '#394634',
	bg_blue     = '#7ad5f1',
	diff_blue   = '#354157',
	diff_yellow = '#4e432f',
	fg          = '#e1e3e4',
	red         = '#ff6578',
	orange      = '#f69c5e',
	yellow      = '#eacb64',
	green       = '#9dd274',
	blue        = '#72cce8',
	purple      = '#ba9cf3',
	grey        = '#828a9a',
	grey_dim    = '#5a6477',
}

-- calendar.vim
vim.g.calendar_cache_directory = '~/hrafnatinna/dagatal/calendar.vim'
vim.g.calendar_frame = 'space'
vim.g.calendar_date_full_month_name = 1
vim.g.calendar_date_endian = 'big'
vim.g.calendar_date_separator = " "
vim.g.calendar_event_start_time_minwidth = 1
vim.g.calendar_first_day = 'monday'
vim.g.calendar_views = { 'year', 'month', 'week', 'day_3', 'day', 'agenda', 'clock' }
-- ATHUGA: Til að breyta aðal foreground og background litunum
--		(hefur m.a. áhrif á textalit events) þá þarftu að 
--		fara í cache folderið í calendar.vim/local/calendarList
--		skjalið og breyta því þar (er stillt per local calendar)
local hl = {
	Calendar202bSelect	 = { fg = colors.orange,				  }, -- virðist vera event

	CalendarSelect           = { fg = colors.orange, bg = colors.bg0                  },
	CalendarDayTitle         = { fg = colors.fg,     bg = colors.bg1,     bold = true },
        CalendarNormalSpace      = { fg = colors.fg,     bg = colors.bg1                  },

        CalendarToday            = { fg = colors.bg4, bg = colors.yellow, bold = true },
        CalendarTodaySaturday    = { fg = colors.bg4, bg = colors.yellow, bold = true },
	CalendarTodaySunday      = { fg = colors.bg4, bg = colors.yellow, bold = true },

        CalendarSaturday         = { fg = colors.fg, bg = colors.bg0,             },
        CalendarSaturdayTitle    = { fg = colors.fg, bg = colors.grey_dim, bold = true },

        CalendarSunday           = { fg = colors.fg, bg = colors.bg0,                 },
        CalendarSundayTitle      = { fg = colors.fg, bg = colors.grey_dim, bold = true },

        CalendarComment          = { fg = colors.fg, bg = colors.bg_blue, italic = true },
        CalendarCommentSelect    = { fg = colors.fg, bg = colors.bg_blue, italic = true },

        -- CalendarOtherMonth       = { fg = colors.fg, bg = colors.bg_blue, bold = true },
        -- CalendarOtherMonthSelect = { fg = colors.fg, bg = colors.bg_blue, bold = true },
}
for k, v in pairs(hl) do vim.api.nvim_set_hl(0, k, v) end

vim.cmd([===[
augroup calendar-mappings
	autocmd!

	autocmd FileType calendar nmap <buffer> H <Plug>(calendar_view_left)
	autocmd FileType calendar nmap <buffer> L <Plug>(calendar_view_right)
	autocmd FileType calendar nmap <buffer> { <Plug>(calendar_view_left)
	autocmd FileType calendar nmap <buffer> } <Plug>(calendar_view_right)
	autocmd FileType calendar nmap <buffer> q <Plug>(calendar_escape)
	autocmd FileType calendar nmap <buffer> m <Plug>(calendar_down_large)
	autocmd FileType calendar nmap <buffer> M <Plug>(calendar_up_large)
	autocmd FileType calendar nmap <buffer> T <Plug>(calendar_left)
	autocmd FileType calendar nmap <buffer> t <Plug>(calendar_right)
	autocmd FileType calendar nmap <buffer> W <Plug>(calendar_up)
	autocmd FileType calendar nmap <buffer> w <Plug>(calendar_down)
	autocmd FileType calendar nmap <buffer> e <Plug>(calendar_event)
	
augroup END
]===])
