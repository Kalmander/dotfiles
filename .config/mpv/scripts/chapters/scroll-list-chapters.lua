local mp = require 'mp'
local assdraw = require 'mp.assdraw'

--formats strings for ass handling
--this function is taken from https://github.com/mpv-player/mpv/blob/master/player/lua/console.lua#L110
local function ass_escape(str)
    str = str:gsub('\\', '\\\239\187\191')
    str = str:gsub('{', '\\{')
    str = str:gsub('}', '\\}')
    -- Precede newlines with a ZWNBSP to prevent ASS's weird collapsing of
    -- consecutive newlines
    str = str:gsub('\n', '\239\187\191\\N')
    -- Turn leading spaces into hard spaces to prevent ASS from stripping them
    str = str:gsub('\\N ', '\\N\\h')
    str = str:gsub('^ ', '\\h')
    return str
end

local overlay = {
    ass = mp.create_osd_overlay('ass-events'),
    bg_ass = mp.create_osd_overlay('ass-events'),
    hidden = true,
    flag_update = true,

    global_style = [[]],

    header = "header \\N ----------------------------------------------",
    header_style = [[{\bord0\1a33&\q2\fs30\c&5454f7&}]],

    list = {},
    list_style = [[{\q2\fs23\c&Hdddddd&}]],
    wrapper_style = [[{\c&bbbbbb&\fs16}]],

    cursor = [[➤\h]],
    indent = [[\h\h\h\h]],
    cursor_style = [[{\c&129ec9&}]],
    selected_style = [[{\c&129ec9&}]],

    num_entries = 22,
    selected = 1,
    wrap = false,
    empty_text = "no chapters",

    keybinds = {},

    ass_escape = ass_escape,

    --appends the entered text to the overlay
    append = function(this, text)
        if text == nil then return end
        this.ass.data = this.ass.data .. text
    end,

    --appends a newline character to the osd
    newline = function(this)
        this.ass.data = this.ass.data .. '\\N'
    end,

    --re-parses the list into an ass string
    --if the list is closed then it flags an update on the next open
    update = function(this)
        if this.hidden then this.flag_update = true
        else this:update_ass() end
    end,

    --prints the header to the overlay
    format_header = function(this)
        this:append(this.header_style)
        this:append(this.header)
        this:newline()
    end,

    --formats each line of the list and prints it to the overlay
    format_line = function(this, index, item)
        this:append(this.list_style)

        if index == this.selected then this:append(this.cursor_style..this.cursor..this.selected_style)
        else this:append(this.indent) end

        this:append(item.style)
        this:append(item.ass)
        this:newline()
    end,

    --refreshes the ass text using the contents of the list
    update_ass = function(this)
        local a = assdraw.ass_new()
        a:new_event()
        a:append('{\\bord0}')
        a:append('{\\shad0}')
        a:append('{\\1c&' .. '#000000' .. '}')
        a:append('{\\1a&' .. '256' .. '}')
        a:pos(0, 0)
        a:draw_start()
        --local ww, wh = mp.get_osd_size()
        a:round_rect_cw(0, 0, 3840, 2160, 0)
        a:draw_stop()
        this.bg_ass.data = a.text


        this.ass.data = this.global_style
        this.ass.z = 1
        this:format_header()

        if #this.list < 1 then
            this:append(this.list_style)
            this:append(this.empty_text)
            this.ass:update()
            this.bg_ass:update()
            return
        end

        local start = 1
        local finish = start+this.num_entries-1

        --handling cursor positioning
        local mid = math.ceil(this.num_entries/2)+1
        if this.selected+mid > finish then
            local offset = this.selected - finish + mid

            --if we've overshot the end of the list then undo some of the offset
            if finish + offset > #this.list then
                offset = offset - ((finish+offset) - #this.list)
            end

            start = start + offset
            finish = finish + offset
        end

        --making sure that we don't overstep the boundaries
        if start < 1 then start = 1 end
        local overflow = finish < #this.list
        --this is necessary when the number of items in the dir is less than the max
        if not overflow then finish = #this.list end

        --adding a header to show there are items above in the list
        if start > 1 then this:append(this.wrapper_style..(start-1)..' item(s) above\\N\\N') end

        for i=start, finish do
            this:format_line(i, this.list[i])
        end

        if overflow then this:append('\\N'..this.wrapper_style..#this.list-finish..' item(s) remaining') end
        this.ass:update()
        this.bg_ass:update()
    end,

    --moves the selector down the list
    scroll_down = function (this)
        if this.selected < #this.list then
            this.selected = this.selected + 1
            this:update_ass()
        elseif this.wrap then
            this.selected = 1
            this:update_ass()
        end
    end,

    --moves the selector up the list
    scroll_up = function (this)
        if this.selected > 1 then
            this.selected = this.selected - 1
            this:update_ass()
        elseif this.wrap then
            this.selected = #this.list
            this:update_ass()
        end
    end,

    --adds the forced keybinds
    add_keybinds = function(this)
        for _,v in ipairs(this.keybinds) do
            mp.add_forced_key_binding(v[1], 'dynamic/'..this.ass.id..'/'..v[2], v[3], v[4])
        end
    end,

    --removes the forced keybinds
    remove_keybinds = function(this)
        for _,v in ipairs(this.keybinds) do
            mp.remove_key_binding('dynamic/'..this.ass.id..'/'..v[2])
        end
    end,

    --opens the list and sets the hidden flag
    open_list = function(this)
        this.hidden = false
        if not this.flag_update then 
            this.ass:update()
            this.bg_ass:update()
        else 
            this.flag_update = false ; this:update_ass() 
        end
    end,

    --closes the list and sets the hidden flag
    close_list = function(this)
        this.hidden = true
        this.bg_ass:remove()
        this.ass:remove()
    end,

    --modifiable function that opens the list
    open = function(this)
        this:open_list()
        this:add_keybinds()
    end,

    --modifiable function that closes the list
    close = function(this)
        this:remove_keybinds()
        this:close_list()
    end,

    --toggles the list
    toggle = function(this)
        if this.hidden then this:open()
        else this:close() end
    end
}

overlay.keybinds = {
        {'DOWN', 'scroll_down', function() overlay:scroll_down() end, {repeatable = true}},
        {'UP', 'scroll_up', function() overlay:scroll_up() end, {repeatable = true}},
        {'CTRL+RIGHT', 'scroll_down_large', function()
                for i = 1,12 do
                    overlay:scroll_down()
                end
            end, {repeatable = true}},
        {'CTRL+LEFT', 'scroll_up_large', function()
                for i = 1,12 do
                    overlay:scroll_up()
                end
            end, {repeatable = true}},
        {'j', 'scroll_down_vim', function() overlay:scroll_down() end, {repeatable = true}},
        {'k', 'scroll_up_vim', function() overlay:scroll_up() end, {repeatable = true}},
        {'CTRL+d', 'scroll_down_large_vim', function()
                for i = 1,12 do
                    overlay:scroll_down()
                end
            end, {repeatable = true}},
        {'CTRL+u', 'scroll_up_large_vim', function()
                for i = 1,12 do
                    overlay:scroll_up()
                end
            end, {repeatable = true}},
        {'ESC', 'close_browser', function() overlay:close() end, {}}
}

return overlay
