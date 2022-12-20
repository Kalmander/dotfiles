local msg = require 'mp.msg'
local assdraw = require 'mp.assdraw'
local options = require 'mp.options'
local misc = require "miscellaneous"
local stale = true
local clock_opts = {
    enabled = false,
    position = "top-right",
    size = 18,
    font_color = '9e9e9e', 
    include_secs = false
    --text = "${filename} [${playlist-pos-1}/${playlist-count}]",
}
local clock_ass = mp.create_osd_overlay('ass-events')
options.read_options(clock_opts, 'clock')


local function get_time_message()
    local font_size = clock_opts.size
    local small_font_size
    local TIME_FORMAT

    if clock_opts.include_secs then 
        TIME_FORMAT = '%H:%M:%S'
        small_font_size = math.floor(font_size*0.73)
    else
        TIME_FORMAT = '%H:%M'
        small_font_size = math.floor(font_size*0.48)
    end
    local remaining = mp.get_property_number('time-remaining')
    local now = os.time()
    local time_message
    
    
    local clock_ft = "{\\fs" .. font_size .. "}" -- clock font tag
    local text_ft = "{\\fs" .. small_font_size .. "}"
    
    -- ath hard space er \\h
    time_message = clock_ft .. os.date(TIME_FORMAT, math.floor(now)) .. text_ft .."\\NCurrent time\\N\\N\\N"
    if remaining ~= nil then 
        time_at_eof = os.date(TIME_FORMAT, math.floor(now + remaining))
        if clock_opts.include_secs then -- Ef sek þá námunda að 10 sek til að forðast flökt
            time_at_eof = time_at_eof:sub(1, -2) .. '0' 
        end
        time_message = time_message .. clock_ft .. time_at_eof .. text_ft .. "\\NTime at EoF"
    end

    return time_message
end


function clock_refresh()
    if not stale then return end
    stale = false
    local time_message = get_time_message()
    local expanded = mp.command_native({ "expand-text", time_message})
    if not expanded then
        msg.error("Error expanding status-line")
        misc.draw_ass("")
        clock_ass:remove()
        return
    end
    msg.verbose("Status-line changed to: " .. expanded)
    local w,h = mp.get_osd_size()
    local an, x, y
    local margin = 10
    if clock_opts.position == "top-left" then
        x = margin
        y = margin
        an = 7
    elseif clock_opts.position == "top-right" then
        x = w-margin
        y = margin
        an = 9
    elseif clock_opts.position == "bottom-right" then
        x = w-margin
        y = h-margin
        an = 3
    elseif clock_opts.position == "bottom-left" then
        x = margin
        y = h-margin
        an = 1
    else
        msg.error("Invalid position: " .. clock_opts.position)
        return
    end
    local a = assdraw:ass_new()

    a:new_event()
    a:an(an)
    -- lenti i miklu veseni með pos því vantaði eftirfarandi:
    --clock_ass.res_x = screenW
    --clock_ass.res_y = screenH

    --a:pos(x,y)
    
    a:append("{\\1c&H" .. clock_opts.font_color .. "}{\\bord1.0}")
    a:append(expanded)
    clock_ass.data = a.text
    clock_ass:update()
    --misc.draw_ass(a.text)
end

function mark_stale()
    stale = true
end

local active = false

function clock_enable()
    if active then return end
    active = true
    local start = 0
    --while true do
    --    local time_message = get_time_message()
    --    local s, e, cap = string.find(time_message, "%${[?!]?([%l%d-/]*)", start)
    --    if not s then break end
    --    msg.verbose("Observing property " .. cap)
    --    mp.observe_property(cap, nil, mark_stale)
    --    start = e
    --end
    --mp.observe_property("osd-width", nil, mark_stale)
    --mp.observe_property("osd-height", nil, mark_stale)
    mp.register_idle(clock_refresh)
    mp.add_periodic_timer(0.1, mark_stale)
    mark_stale()
end


function clock_disable()
    if not active then return end
    active = false
    mp.unobserve_property(mark_stale)
    mp.unregister_idle(clock_refresh)
    --misc.draw_ass("")
    clock_ass:remove()
end

function clock_toggle()
    if active and not clock_opts.include_secs then
        clock_opts.include_secs = true
        clock_enable()
    elseif active and clock_opts.include_secs then
        clock_disable()
    else
        clock_opts.include_secs = false
        clock_enable()
    end
end

if clock_opts.enabled then
    clock_enable()
end


mp.add_key_binding(nil, "enable-clock", clock_enable)
mp.add_key_binding(nil, "disable-clock", clock_disable)
mp.add_key_binding(nil, "toggle-clock", clock_toggle)
