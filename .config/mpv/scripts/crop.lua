local misc_script = mp.command_native({"expand-path", "~~/scripts/miscellaneous_scripts/miscellaneous.lua"})
package.path = misc_script .. ";" .. package.path
local misc = require 'miscellaneous'

local spawn_mode_active = false
local pipename_base = [[\\.\pipe\mpv_crop_socket]]
local pipe_count = 0
local spawned_pipes = {}
local spawned_tracking_active = false
---- Window spawning -----------------------------------------
function make_new_pipe()
    pipe_count = pipe_count + 1
    local vid_identifier = string.sub(misc:sha256_normalized(mp.get_property('filename/no-ext')), 1, 12)
    spawned_pipes[pipe_count] = pipename_base .. '_' .. vid_identifier .. '_' .. pipe_count
    mp.command('script-message add-named-pipe ' .. spawned_pipes[pipe_count]:gsub("\\", "\\\\"))
end

function bool_to_word(input_bool)
    if input_bool == true then 
        return 'yes'
    elseif input_bool == false then 
        return 'no'
    else
        return nil 
    end
end

function send_to_pipe(mpv_command)
    for pipe_nr, pipename in pairs(spawned_pipes) do 
        local cmd_command = "echo " .. mpv_command .. " > " .. pipename
        os.execute(cmd_command)
    end
end

function sync_spawned_windows()
    mp.command('script-binding sync-all-pipes-to-delta')
end


function pause_spawned_windows(prop_name, pause_state)
    send_to_pipe('set pause ' .. bool_to_word(pause_state))
end

function activate_spawned_window_tracking()
    mp.observe_property("pause", "bool", pause_spawned_windows)
    mp.register_event('seek', sync_spawned_windows)
end

function spawn_window(vf_table)
    make_new_pipe()
    if not spawned_tracking_active then activate_spawned_window_tracking(); spawned_tracking_active=true end

    pars = vf_table[1]['params']


    wanted_scripts = mp.command_native({"expand-path", "~~/scripts/crop_window_sync.js"})
    wanted_scripts = wanted_scripts .. ';' .. mp.command_native({"expand-path", "~~/scripts/console.lua"})
    wanted_scripts = wanted_scripts .. ';' .. mp.command_native({"expand-path", "~~/scripts/zones.lua"})
    wanted_scripts = wanted_scripts .. ';' .. mp.command_native({"expand-path", "~~/scripts/crop.lua"})
    wanted_scripts = wanted_scripts .. ';' .. mp.command_native({"expand-path", "~~/scripts/miscellaneous_scripts/main.lua"})
    
    filePath = mp.get_property('path')
    args = {}
    i = 1
    args[i] = 'mpv' ; i = i + 1
    args[i] = string.format('--vf=crop:x=%d:y=%d:w=%d:h=%d', pars['x'], pars['y'], pars['w'], pars['h']) ; i = i + 1
    args[i] = '--input-ipc-server=' .. spawned_pipes[pipe_count] ; i = i + 1
    args[i] = '--hwdec=no' ; i = i + 1
    args[i] = '--load-scripts=no' ; i = i + 1
    args[i] = '--scripts=' .. wanted_scripts ; i = i + 1    
    args[i] = '--script-opts=misc-short_skips=yes,osc-visibility=never' ; i = i + 1
    args[i] = '--aid=no' ; i = i + 1
    args[i] = filePath

    res = mp.command_native({
        name = "subprocess",
        args = args,
        detach = true -- þetta var að valda miklum villum, skiliggi neitt DJÓK virðist fokkast upp ef bæði detach og async, en ég fjarlægði async virkar best svona
    })

    mp.add_timeout(1, sync_spawned_windows)
end

function critter_time()
        if not mp.get_property("video-out-params", nil) then return end
        local hwdec = mp.get_property("hwdec-current")
        if hwdec and hwdec ~= "no" and not string.find(hwdec, "-copy$") then
            mp.set_property("hwdec", "no")
            --mp.osd_message("Cannot crop with hardware decoding active (ctrl+h cycles hwdec modes)") -- Ég bætti þessu við TKJ
            --msg.error("Cannot crop with hardware decoding active (see manual)")
            print('Turned of hwdec (to enable cropping)')
            --return
        end
    
        matt_params = {
                y=111, 
                x=26,
                h=406,
                w=560
        }

        matt_vf_table = {}
        matt_vf_table[1] = {params=matt_params}
        spawn_window(matt_vf_table)


        upper_params = {
                y=110, 
                x=629,
                h=415,
                w=1264
        }

        upper_vf_table = {}
        upper_vf_table[1] = {params=upper_params}
        spawn_window(upper_vf_table)



        local vf_table = mp.get_property_native("vf")
        vf_table[#vf_table + 1] = {
            name="crop",
            params= {
                x = '630',
                y = '558',
                w = '1259',
                h = '411'
            }
        }
        mp.set_property_native("vf", vf_table)
    

end



---- Window spawning ends -----------------------------------
---- Crop script proper -------------------------------------


local opts = {
    draw_shade = true,
    shade_opacity = "77",
    draw_crosshair = true,
    draw_text = true,
    mouse_support=true,
    coarse_movement=30,
    left_coarse="LEFT",
    right_coarse="RIGHT",
    up_coarse="UP",
    down_coarse="DOWN",
    fine_movement=1,
    left_fine="ALT+LEFT",
    right_fine="ALT+RIGHT",
    up_fine="ALT+UP",
    down_fine="ALT+DOWN",
    accept="ENTER,MOUSE_BTN0",
    cancel="ESC",
}
(require 'mp.options').read_options(opts, 'crop')

function split(input)
    local ret = {}
    for str in string.gmatch(input, "([^,]+)") do
        ret[#ret + 1] = str
    end
    return ret
end
opts.accept = split(opts.accept)
opts.cancel = split(opts.cancel)

local assdraw = require 'mp.assdraw'
local msg = require 'mp.msg'
local needs_drawing = false
local dimensions_changed = false
local crop_first_corner = nil -- in video space
local crop_cursor = {
    x = -1,
    y = -1
}
local aspect_lock_state = 0  -- 0 is none, 1 is 16:9, 2 is square


function update_aspect_lock_state()
    aspect_lock_state = (aspect_lock_state + 1) % 3
end

function get_video_dimensions()
    if not dimensions_changed then return _video_dimensions end
    -- this function is very much ripped from video/out/aspect.c in mpv's source
    local video_params = mp.get_property_native("video-out-params")
    if not video_params then return nil end
    dimensions_changed = false
    local keep_aspect = mp.get_property_bool("keepaspect")
    local w = video_params["w"]
    local h = video_params["h"]
    local dw = video_params["dw"]
    local dh = video_params["dh"]
    if mp.get_property_number("video-rotate") % 180 == 90 then
        w, h = h,w
        dw, dh = dh, dw
    end
    _video_dimensions = {
        top_left = {},
        bottom_right = {},
        ratios = {},
    }
    if keep_aspect then
        local unscaled = mp.get_property_native("video-unscaled")
        local panscan = mp.get_property_number("panscan")
        local window_w, window_h = mp.get_osd_size()

        local fwidth = window_w
        local fheight = math.floor(window_w / dw * dh)
        if fheight > window_h or fheight < h then
            local tmpw = math.floor(window_h / dh * dw)
            if tmpw <= window_w then
                fheight = window_h
                fwidth = tmpw
            end
        end
        local vo_panscan_area = window_h - fheight
        local f_w = fwidth / fheight
        local f_h = 1
        if vo_panscan_area == 0 then
            vo_panscan_area = window_h - fwidth
            f_w = 1
            f_h = fheight / fwidth
        end
        if unscaled or unscaled == "downscale-big" then
            vo_panscan_area = 0
            if unscaled or (dw <= window_w and dh <= window_h) then
                fwidth = dw
                fheight = dh
            end
        end

        local scaled_width = fwidth + math.floor(vo_panscan_area * panscan * f_w)
        local scaled_height = fheight + math.floor(vo_panscan_area * panscan * f_h)

        local split_scaling = function (dst_size, scaled_src_size, zoom, align, pan)
            scaled_src_size = math.floor(scaled_src_size * 2 ^ zoom)
            align = (align + 1) / 2
            local dst_start = math.floor((dst_size - scaled_src_size) * align + pan * scaled_src_size)
            if dst_start < 0 then
                --account for C int cast truncating as opposed to flooring
                dst_start = dst_start + 1
            end
            local dst_end = dst_start + scaled_src_size;
            if dst_start >= dst_end then
                dst_start = 0
                dst_end = 1
            end
            return dst_start, dst_end
        end
        local zoom = mp.get_property_number("video-zoom")

        local align_x = mp.get_property_number("video-align-x")
        local pan_x = mp.get_property_number("video-pan-x")
        _video_dimensions.top_left.x, _video_dimensions.bottom_right.x = split_scaling(window_w, scaled_width, zoom, align_x, pan_x)

        local align_y = mp.get_property_number("video-align-y")
        local pan_y = mp.get_property_number("video-pan-y")
        _video_dimensions.top_left.y, _video_dimensions.bottom_right.y = split_scaling(window_h,  scaled_height, zoom, align_y, pan_y)
    else
        _video_dimensions.top_left.x = 0
        _video_dimensions.bottom_right.x = window_w
        _video_dimensions.top_left.y = 0
        _video_dimensions.bottom_right.y = window_h
    end
    _video_dimensions.ratios.w = w / (_video_dimensions.bottom_right.x - _video_dimensions.top_left.x)
    _video_dimensions.ratios.h = h / (_video_dimensions.bottom_right.y - _video_dimensions.top_left.y)
    return _video_dimensions
end

function sort_corners(c1, c2)
    local r1, r2 = {}, {}
    if c1.x < c2.x then r1.x, r2.x = c1.x, c2.x else r1.x, r2.x = c2.x, c1.x end
    if c1.y < c2.y then r1.y, r2.y = c1.y, c2.y else r1.y, r2.y = c2.y, c1.y end
    if aspect_lock_state == 1 then --tkjtkj
        r1.y = r2.y - (r2.x - r1.x)*0.5625
    --elseif aspect_lock_state == 2 then
    --    r1.y = r2.y - (r2.x - r1.x)*0.75 þetta er 4:3
    elseif aspect_lock_state == 2 then
        r1.y = r2.y - (r2.x - r1.x)*1.0
    end
    return r1, r2
end

function clamp(low, value, high)
    if value <= low then
        return low
    elseif value >= high then
        return high
    else
        return value
    end
end

function clamp_point(top_left, point, bottom_right)
    return {
        x = clamp(top_left.x, point.x, bottom_right.x),
        y = clamp(top_left.y, point.y, bottom_right.y)
    }
end

function screen_to_video(point, video_dim)
    return {
        x = math.floor(video_dim.ratios.w * (point.x - video_dim.top_left.x) + 0.5),
        y = math.floor(video_dim.ratios.h * (point.y - video_dim.top_left.y) + 0.5)
    }
end

function video_to_screen(point, video_dim)
    return {
        x = math.floor(point.x / video_dim.ratios.w + video_dim.top_left.x + 0.5),
        y = math.floor(point.y / video_dim.ratios.h + video_dim.top_left.y + 0.5)
    }
end

function draw_shade(ass, unshaded, video)
    ass:new_event()
    ass:pos(0, 0)
    ass:append("{\\bord0}")
    ass:append("{\\shad0}")
    ass:append("{\\c&H000000&}")
    ass:append("{\\1a&H" .. opts.shade_opacity .. "}")
    ass:append("{\\2a&HFF}")
    ass:append("{\\3a&HFF}")
    ass:append("{\\4a&HFF}")
    local c1, c2 = unshaded.top_left, unshaded.bottom_right
    local v = video
    --          c1.x   c2.x
    --     +-----+------------+
    --     |     |     ur     |
    -- c1.y| ul  +-------+----+
    --     |     |       |    |
    -- c2.y+-----+-------+ lr |
    --     |     ll      |    |
    --     +-------------+----+
    ass:draw_start()
    ass:rect_cw(v.top_left.x, v.top_left.y, c1.x, c2.y) -- ul
    ass:rect_cw(c1.x, v.top_left.y, v.bottom_right.x, c1.y) -- ur
    ass:rect_cw(v.top_left.x, c2.y, c2.x, v.bottom_right.y) -- ll
    ass:rect_cw(c2.x, c1.y, v.bottom_right.x, v.bottom_right.y) -- lr
    ass:draw_stop()
    -- also possible to draw a rect over the whole video
    -- and \iclip it in the middle, but seemingy slower
end

function draw_crosshair(ass, center, window_size)
    ass:new_event()
    ass:append("{\\bord0}")
    ass:append("{\\shad0}")
    ass:append("{\\c&HBBBBBB&}")
    ass:append("{\\1a&H00&}")
    ass:append("{\\2a&HFF&}")
    ass:append("{\\3a&HFF&}")
    ass:append("{\\4a&HFF&}")
    ass:pos(0, 0)
    ass:draw_start()
    ass:rect_cw(center.x - 0.5, 0, center.x + 0.5, window_size.h)
    ass:rect_cw(0, center.y - 0.5, window_size.w, center.y + 0.5)
    ass:draw_stop()
end

function draw_position_text(ass, text, position, window_size, offset)
    ass:new_event()
    local align = 1
    local ofx = 1
    local ofy = -1
    if position.x > window_size.w / 2 then
        align = align + 2
        ofx = -1
    end
    if position.y < window_size.h / 2 then
        align = align + 6
        ofy = 1
    end
    ass:append("{\\an"..align.."}")
    ass:append("{\\fs26}")
    ass:append("{\\bord1.5}")
    ass:pos(ofx*offset + position.x, ofy*offset + position.y)
    ass:append(text)
end

function draw_crop_zone()
    if needs_drawing then
        local video_dim = get_video_dimensions()
        if not video_dim then
            cancel_crop()
            return
        end

        local window_size = {}
        window_size.w, window_size.h = mp.get_osd_size()
        crop_cursor = clamp_point(video_dim.top_left, crop_cursor, video_dim.bottom_right)
        local ass = assdraw.ass_new()

        if opts.draw_shade and crop_first_corner then
            local first_corner = video_to_screen(crop_first_corner, video_dim)
            local unshaded = {}
            unshaded.top_left, unshaded.bottom_right = sort_corners(first_corner, crop_cursor)
            -- don't draw shade over non-visible video parts
            local window = {
                top_left = { x = 0, y = 0 },
                bottom_right = { x = window_size.w, y = window_size.h },
            }
            local video_visible = {
                top_left = clamp_point(window.top_left, video_dim.top_left, window.bottom_right),
                bottom_right = clamp_point(window.top_left, video_dim.bottom_right, window.bottom_right),
            }
            draw_shade(ass, unshaded, video_visible)
        end

        if opts.draw_crosshair then
            draw_crosshair(ass, crop_cursor, window_size)
        end

        if opts.draw_text then
            cursor_video = screen_to_video(crop_cursor, video_dim)
            local text = string.format("%d, %d", cursor_video.x, cursor_video.y)
            if crop_first_corner then
                text = string.format("%s (%dx%d)", text,
                    math.abs(cursor_video.x - crop_first_corner.x),
                    math.abs(cursor_video.y - crop_first_corner.y)
                )
            end
            draw_position_text(ass, text, crop_cursor, window_size, 6)
        end

        mp.set_osd_ass(window_size.w, window_size.h, ass.text)
        needs_drawing = false
    end
end

function crop_video(x, y, w, h)
    local vf_table = mp.get_property_native("vf")
    vf_table[#vf_table + 1] = {
        name="crop",
        params= {
            x = tostring(x),
            y = tostring(y),
            w = tostring(w),
            h = tostring(h)
        }
    }
    if spawn_mode_active then 
        spawn_window(vf_table)
    else
        mp.set_property_native("vf", vf_table)
    end
end

function update_crop_zone_state()
    local dim = get_video_dimensions()
    if not dim then
        cancel_crop()
        return
    end
    crop_cursor = clamp_point(dim.top_left, crop_cursor, dim.bottom_right)
    corner_video = screen_to_video(crop_cursor, dim)
    if crop_first_corner == nil then
        crop_first_corner = corner_video
        needs_drawing = true
    else
        local c1, c2 = sort_corners(crop_first_corner, corner_video)
        crop_video(c1.x, c1.y, c2.x - c1.x, c2.y - c1.y)
        cancel_crop()
        aspect_lock_state = 0 --resetta þetta í false, er ekki alveg viss en held þetta sé þægilegra
    end
end

function reset_crop()
    dimensions_changed = true
    needs_drawing = true
end

local bindings = {}
local bindings_repeat = {}

function cancel_crop()
    needs_drawing = false
    crop_first_corner = nil
    for key, _ in pairs(bindings) do
        mp.remove_key_binding("crop-"..key)
    end
    for key, _ in pairs(bindings_repeat) do
        mp.remove_key_binding("crop-"..key)
    end
    mp.unobserve_property(reset_crop)
    mp.unregister_idle(draw_crop_zone)
    mp.set_osd_ass(1280, 720, '')
end

-- bindings
if opts.mouse_support then
    bindings["MOUSE_MOVE"] = function() crop_cursor.x, crop_cursor.y = mp.get_mouse_pos(); needs_drawing = true end
end
for _, key in ipairs(opts.accept) do
    bindings[key] = update_crop_zone_state
end
for _, key in ipairs(opts.cancel) do
    bindings[key] = cancel_crop
end
function movement_func(move_x, move_y)
    return function()
        crop_cursor.x = crop_cursor.x + move_x
        crop_cursor.y = crop_cursor.y + move_y
        needs_drawing = true
    end
end
bindings_repeat[opts.left_coarse]  = movement_func(-opts.coarse_movement, 0)
bindings_repeat[opts.right_coarse] = movement_func(opts.coarse_movement, 0)
bindings_repeat[opts.up_coarse]    = movement_func(0, -opts.coarse_movement)
bindings_repeat[opts.down_coarse]  = movement_func(0, opts.coarse_movement)
bindings_repeat[opts.left_fine]    = movement_func(-opts.fine_movement, 0)
bindings_repeat[opts.right_fine]   = movement_func(opts.fine_movement, 0)
bindings_repeat[opts.up_fine]      = movement_func(0, -opts.fine_movement)
bindings_repeat[opts.down_fine]    = movement_func(0, opts.fine_movement)
bindings_repeat['a']    = update_aspect_lock_state

local properties = {
    "keepaspect",
    "video-out-params",
    "video-unscaled",
    "panscan",
    "video-zoom",
    "video-align-x",
    "video-pan-x",
    "video-align-y",
    "video-pan-y",
    "osd-width",
    "osd-height",
}

function start_crop()
    if not mp.get_property("video-out-params", nil) then return end
    local hwdec = mp.get_property("hwdec-current")
    if hwdec and hwdec ~= "no" and not string.find(hwdec, "-copy$") then
        mp.set_property("hwdec", "no")
        --mp.osd_message("Cannot crop with hardware decoding active (ctrl+h cycles hwdec modes)") -- Ég bætti þessu við TKJ
        --msg.error("Cannot crop with hardware decoding active (see manual)")
        print('Turned of hwdec (to enable cropping)')
        --return
    end

    crop_cursor.x, crop_cursor.y = mp.get_mouse_pos()
    needs_drawing = true
    dimensions_changed = true
    for key, func in pairs(bindings) do
        mp.add_forced_key_binding(key, "crop-"..key, func)
    end
    for key, func in pairs(bindings_repeat) do
        mp.add_forced_key_binding(key, "crop-"..key, func, { repeatable = true })
    end
    mp.register_idle(draw_crop_zone)
    for _, p in ipairs(properties) do
        mp.observe_property(p, "native", reset_crop)
    end
end

function toggle_crop()
    local vf_table = mp.get_property_native("vf")
    if #vf_table > 0 then
        for i = #vf_table, 1, -1 do
            if vf_table[i].name == "crop" then
                for j = i, #vf_table-1 do
                    vf_table[j] = vf_table[j+1]
                end
                vf_table[#vf_table] = nil
                mp.set_property_native("vf", vf_table)
                return
            end
        end
    end
    start_crop()
end

function toggle_spawn_mode()
    local crop_mode_msg = ''
    if spawn_mode_active then 
        spawn_mode_active = false
        crop_mode_msg = 'Crop mode: Normal'
    else
        spawn_mode_active = true 
        crop_mode_msg = 'Crop mode: Window Spawning'
    end
    mp.osd_message(crop_mode_msg)
    print(crop_mode_msg)
end

mp.add_key_binding(nil, "start-crop", start_crop)
mp.add_key_binding(nil, "toggle-crop", toggle_crop)
mp.add_key_binding(nil, "toggle-spawn-mode", toggle_spawn_mode)
mp.add_key_binding(nil, 'critter-time', critter_time)
