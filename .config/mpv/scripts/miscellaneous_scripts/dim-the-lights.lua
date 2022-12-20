local assdraw = require 'mp.assdraw'


local function make_background()
    --local g = gallery.geometry
    local a = assdraw.ass_new()
    a:new_event()
    a:append('{\\bord0}')
    a:append('{\\shad0}')
    a:append('{\\1c&' .. '#000000' .. '}')
    a:append('{\\1a&' .. '256' .. '}')
    a:pos(0, 0)
    a:draw_start()
    local ww, wh = mp.get_osd_size()
    a:round_rect_cw(0, 0, ww, wh, 0)
    a:draw_stop()
    return a.text
end

local function draw_bg()
    local ww, wh = mp.get_osd_size()
    ass = make_background()
    mp.set_osd_ass(ww, wh, ass)
end

local function clear_bg()
    local ww, wh = mp.get_osd_size()
    mp.set_osd_ass(ww, wh, "")
end

local dimmer = {
    toggled = false,
    toggle = function(self)
        if not self.toggled then 
    
            self.toggled = true
            draw_bg()
    
        else
    
            self.toggled = false
            clear_bg()
        end
    end,--
    
    
    toggleOn = function(self)
        self.toggled = true
        draw_bg()
    end,
    
    
    toggleOff = function(self)
        self.toggled = false
        clear_bg()
    end
}
return dimmer 
