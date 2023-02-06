local utils = require 'mp.utils'
local msg = require 'mp.msg'
local misc_script = mp.command_native({"expand-path", "~~/scripts/miscellaneous_scripts/miscellaneous.lua"})

--local lib = mp.find_config_file('scripts/lib.disable')
local script_dir =  mp.get_script_directory() 
local lib = utils.join_path(script_dir, "playlist_gallery_view")
if not lib then
    return
end
-- lib can be nil if the folder does not exist or we're in --no-config mode
package.path = package.path .. ';' .. lib .. '/?.lua;' .. misc_script .. ";"
local gallery = require 'gallery'
local ON_WINDOWS = (package.config:sub(1,1) ~= "/")

local thumbnails_dir
if ON_WINDOWS then 
    thumbnails_dir = mp.command_native({"expand-path", "~~exe_dir/thumbnails_gallery/"})
else
    thumbnails_dir = mp.command_native({"expand-path", "/mnt/derichet/mpv_thumbnails_etc/thumbnails_gallery/"})
end
local misc = require 'miscellaneous.lua'


local opts = {
    thumbs_dir = thumbnails_dir, --ON_WINDOWS and "%APPDATA%\\mpv\\gallery-thumbs-dir" or "~/.mpv_thumbs_dir/",
    generate_thumbnails_with_mpv = ON_WINDOWS,

    gallery_position = "{ (ww - gw) / 2, (wh - gh) / 2}",
    gallery_size = "{ 9 * ww / 10, 9 * wh / 10 }",
    min_spacing = "{ 15, 15 }",
    thumbnail_size = "(ww * wh <= 1366 * 768) and {192, 108} or {288, 162}",
    max_thumbnails = 64,

    take_thumbnail_at = "20%",

    load_file_on_toggle_off = false,
    close_on_load_file = true,
    pause_on_start = true,
    resume_on_stop = "only-if-did-pause",
    follow_playlist_position = true,
    remember_time_position = true,

    start_on_mpv_startup = false,
    start_on_file_end = true,

    show_text = true,
    show_title = true,
    strip_directory = true,
    strip_extension = true,
    text_size = 28,

    background_color = "333333",
    background_opacity = "33",
    normal_border_color = "BBBBBB",
    normal_border_size = 1,
    selected_border_color = "DDDDDD",
    selected_border_size = 6,
    playing_border_color = "14a80f",
    playing_border_size = 6,
    flagged_border_color = "5B9769",
    flagged_border_size = 3,
    selected_flagged_border_color = "BAFFCA",
    placeholder_color = "222222",

    command_on_open = "",
    command_on_close = "",

    flagged_file_path = "./mpv_gallery_flagged",

    mouse_support = true,
    UP        = "UP",
    DOWN      = "DOWN",
    LEFT      = "LEFT",
    RIGHT     = "RIGHT",
    PAGE_UP   = "PGUP",
    PAGE_DOWN = "PGDWN",
    FIRST     = "HOME",
    LAST      = "END",
    RANDOM    = "r",
    ACCEPT    = "ENTER",
    CANCEL    = "ESC",
    REMOVE    = "DEL",
    FLAG      = "SPACE",
}
(require 'mp.options').read_options(opts, "gallery")

if ON_WINDOWS then
    opts.thumbs_dir = string.gsub(opts.thumbs_dir, "^%%APPDATA%%", os.getenv("APPDATA") or "%APPDATA%")
else
    opts.thumbs_dir = string.gsub(opts.thumbs_dir, "^~", os.getenv("HOME") or "~")
end
opts.max_thumbnails = math.min(opts.max_thumbnails, 64)

local res = utils.file_info(opts.thumbs_dir)
if not res or not res.is_dir then
    msg.error(string.format("Thumbnail directory \"%s\" does not exist", opts.thumbs_dir))
end

local gallery = gallery_new()

local flags = {}
local resume = {}
local did_pause = false
local hash_cache = {}

gallery.config.accurate = false
gallery.config.generate_thumbnails_with_mpv = opts.generate_thumbnails_with_mpv
gallery.config.always_show_placeholders = false -- true setur bakgrunnslit á thumbnails sem er lame
gallery.config.align_text = true
gallery.config.placeholder_color = opts.placeholder_color
gallery.config.background_color = opts.background_color
gallery.config.background_opacity = opts.background_opacity
gallery.config.max_thumbnails = opts.max_thumbnails
gallery.config.selected_color = opts.selected_border_color
gallery.config.playing_color = opts.playing_border_color

gallery.too_small = function()
    stop()
end
gallery.item_to_overlay_path = function(index, item)
    local filename = item.filename
    local filename_hash = hash_cache[filename]
    if filename_hash == nil then
        filename_hash = string.sub(misc:sha256_normalized(filename), 1, 12)
        hash_cache[filename] = filename_hash
    end
    
    local thumb_filename = string.format("%s_%d_%d", filename_hash, gallery.geometry.thumbnail_size[1], gallery.geometry.thumbnail_size[2])
    return utils.join_path(opts.thumbs_dir, thumb_filename)
end
gallery.item_to_thumbnail_params = function(index, item)
    return item.filename, opts.take_thumbnail_at
end
gallery.item_to_border = function(index, item)
    local flagged = flags[item.filename]
    local selected = index == gallery.selection
    local currently_playing = item['filename'] == mp.get_property('path')
    if not flagged and not selected and not currently_playing then
        return opts.normal_border_size, opts.normal_border_color
    elseif flagged and selected then
        return opts.selected_border_size, opts.selected_flagged_border_color
    elseif flagged then
        return opts.flagged_border_size, opts.flagged_border_color
    elseif selected then
        return opts.selected_border_size, opts.selected_border_color
    elseif currently_playing then 
        return opts.playing_border_size, opts.playing_border_color
    end
end
function wrap(str, limit, indent, indent1)
    indent = indent or ""
    indent1 = indent1 or indent
    limit = limit or 79
    local here = 1-#indent1
    return indent1..str:gsub("(%s+)()(%S+)()",
        function(sp, st, word, fi)
            if fi-here > limit then
            here = st - #indent
            return "\\N"..indent..word
        end
    end)
end
gallery.item_to_text = function(index, item)
    if not opts.show_text then return "", false end--or index ~= gallery.selection then return "", false end
    local f
    if opts.show_title and item.title then
        f = item.title
    else
        f = item.filename
        if opts.strip_directory then
            if ON_WINDOWS then
                f = string.match(f, "([^\\/]+)$") or f
            else
                f = string.match(f, "([^/]+)$") or f
            end
        end
        if opts.strip_extension then
            f = string.match(f, "(.+)%.[^.]+$") or f
        end
    end
    
    if f:len() <= 90 then
        f = wrap(f, 30)
    else
        f = wrap(f, 36) -- Leyfir aðeins lengri línur þegar línufjöldinn er að fara yfir 3 (að hluta til því þá minnka ég letrið hvort eð er)
    end

    return f, true
end

do
    local function increment_func(increment, clamp)
        local new = (gallery.pending.selection or gallery.selection) + increment
        if new <= 0 or new > #gallery.items then
            if not clamp then return end
            new = math.max(1, math.min(new, #gallery.items))
        end
        gallery.pending.selection = new
    end

    local function turn_page(direction)
        local whole_page = gallery.geometry.columns * gallery.geometry.rows
        local relative_location
        if direction == 'next' then 
            relative_location = gallery.view.last - (gallery.pending.selection or gallery.selection)
            increment_func(whole_page + relative_location, true)
            gallery:idle_handler()
            increment_func(-relative_location, true)    
        elseif direction == 'previous' then 
            relative_location = (gallery.pending.selection or gallery.selection) - gallery.view.first
            increment_func(-(whole_page + relative_location), true)
            gallery:idle_handler()
            increment_func(relative_location, true)
        elseif direction == 'next3' then 
            relative_location = gallery.view.last - (gallery.pending.selection or gallery.selection)
            increment_func(whole_page*3 + relative_location, true)
            gallery:idle_handler()
            increment_func(-relative_location, true)    
        elseif direction == 'previous3' then 
            relative_location = (gallery.pending.selection or gallery.selection) - gallery.view.first
            increment_func(-(whole_page*3 + relative_location), true)
            gallery:idle_handler()
            increment_func(relative_location, true)
        end
    end


    local bindings_repeat = {}
        bindings_repeat[opts.UP]        = function() increment_func(- gallery.geometry.columns, false) end
        bindings_repeat[opts.DOWN]      = function() increment_func(  gallery.geometry.columns, false) end
        bindings_repeat[opts.LEFT]      = function() increment_func(- 1, false) end
        bindings_repeat[opts.RIGHT]     = function() increment_func(  1, false) end
        bindings_repeat["UP"]        = function() increment_func(- gallery.geometry.columns, false) end
        bindings_repeat["DOWN"]      = function() increment_func(  gallery.geometry.columns, false) end
        bindings_repeat["LEFT"]      = function() increment_func(- 1, false) end
        bindings_repeat["RIGHT"]     = function() increment_func(  1, false) end
        bindings_repeat[opts.PAGE_UP]   = function() increment_func(- gallery.geometry.columns * gallery.geometry.rows, true) end
        bindings_repeat[opts.PAGE_DOWN] = function() increment_func(  gallery.geometry.columns * gallery.geometry.rows, true) end
        bindings_repeat["CTRL+left"]    = function() turn_page('previous') end
        bindings_repeat["CTRL+right"]   = function() turn_page('next') end
        bindings_repeat["NEXT"]         = function() turn_page('previous3') end
        bindings_repeat["PREV"]         = function() turn_page('next3') end
        bindings_repeat[opts.RANDOM]    = function() gallery.pending.selection = math.random(1, #gallery.items) end
        bindings_repeat[opts.REMOVE]    = function()
            mp.commandv("playlist-remove", gallery.selection - 1)
            gallery.selection = gallery.selection + (gallery.selection == #gallery.items and -1 or 1)
        end

    local bindings = {}
        bindings[opts.FIRST]  = function() gallery.pending.selection = 1 end
        bindings[opts.LAST]   = function() gallery.pending.selection = #gallery.items end
        bindings[opts.ACCEPT] = function()
            load_selection()
            if opts.close_on_load_file then stop() end
        end
        bindings[opts.CANCEL] = function() stop() end
        bindings[opts.FLAG]   = function()
            local name = gallery.items[gallery.selection].filename
            if flags[name] == nil then
                flags[name] = true
            else
                flags[name] = nil
            end
            -- TODO refresh ass
        end
    if opts.mouse_support then
        bindings["MBTN_LEFT"]  = function()
            local index = gallery:index_at(mp.get_mouse_pos())
            if not index then return end
            if index == gallery.selection then
                load_selection()
                if opts.close_on_load_file then stop() end
            else
                gallery.pending.selection = index
            end
        end
        bindings["WHEEL_UP"]   = function() increment_func(- gallery.geometry.columns, false) end
        bindings["WHEEL_DOWN"] = function() increment_func(  gallery.geometry.columns, false) end
    end

     function setup_ui_handlers()
        for key, func in pairs(bindings_repeat) do
            mp.add_forced_key_binding(key, "playlist-view-"..key, func, {repeatable = true})
        end
        for key, func in pairs(bindings) do
            mp.add_forced_key_binding(key, "playlist-view-"..key, func)
        end
    end

    function teardown_ui_handlers()
        for key, _ in pairs(bindings_repeat) do
            mp.remove_key_binding("playlist-view-"..key)
        end
        for key, _ in pairs(bindings) do
            mp.remove_key_binding("playlist-view-"..key)
        end
    end
end

do
    local geometry_functions = loadstring(string.format([[
    return {
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end,
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end,
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end,
    function(ww, wh, gx, gy, gw, gh, sw, sh, tw, th)
        return %s
    end
    }]], opts.gallery_position, opts.gallery_size, opts.min_spacing, opts.thumbnail_size))()

    local names = { "gallery_position", "gallery_size", "min_spacing", "thumbnail_size" }
    local order = {} -- the order in which the 4 properties should be computed, based on inter-dependencies

    -- build the dependency matrix
    local patterns = { "g[xy]", "g[wh]", "s[wh]", "t[wh]" }
    local deps = {}
    for i = 1,4 do
        for j = 1,4 do
            local i_depends_on_j = (string.find(opts[names[i]], patterns[j]) ~= nil)
            if i == j and i_depends_on_j then
                msg.error(names[i] .. " depends on itself")
                return
            end
            deps[i * 4 + j] = i_depends_on_j
        end
    end

    local function has_deps(index)
        for j = 1,4 do
            if deps[index * 4 + j] then
                return true
            end
        end
        return false
    end
    local num_resolved = 0
    local resolved = { false, false, false, false }
    while true do
        local resolved_one = false
        for i = 1, 4 do
            if resolved[i] then
                -- nothing to do
            elseif not has_deps(i) then
                order[#order + 1] = i
                -- since i has no deps, anything that depends on it might as well not
                for j = 1, 4 do
                    deps[j * 4 + i] = false
                end
                resolved[i] = true
                resolved_one = true
                num_resolved = num_resolved + 1
            end
        end
        if num_resolved == 4 then
            break
        elseif not resolved_one then
            local str = ""
            for index, resolved in ipairs(resolved) do
                if not resolved then
                    str = (str == "" and "" or (str .. ", ")) .. names[index]
                end
            end
            msg.error("Circular dependency between " .. str)
            return
        end
    end

    gallery.set_geometry_props = function()
        local g = gallery.geometry
        g.window[1], g.window[2] = mp.get_osd_size()
        for _, index in ipairs(order) do
            g[names[index]] = geometry_functions[index](
                g.window[1], g.window[2],
                g.gallery_position[1], g.gallery_position[2],
                g.gallery_size[1], g.gallery_size[2],
                g.min_spacing[1], g.min_spacing[2],
                g.thumbnail_size[1], g.thumbnail_size[2]
            )
            -- extrawuerst
            if opts.show_text and names[index] == "min_spacing" then
                g.min_spacing[2] = math.max(opts.text_size, g.min_spacing[2])
            elseif names[index] == "thumbnail_size" then
                g.thumbnail_size[1] = math.floor(g.thumbnail_size[1])
                g.thumbnail_size[2] = math.floor(g.thumbnail_size[2])
            end
        end
    end
end

function playlist_changed(key, playlist)
    if not gallery.active then return end
    local did_change = function()
        if #gallery.items ~= #playlist then return true end
        for i = 1, #gallery.items do
            if gallery.items[i].filename ~= playlist[i].filename then return true end
        end
        return false
    end
    if not did_change() then return end
    if #playlist == 0 then
        stop()
        return
    end
    local selection = gallery.items[gallery.selection].filename
    gallery.items = playlist
    gallery.selection = math.max(1, math.min(gallery.selection, #gallery.items))
    for i, f in ipairs(gallery.items) do
        if selection == f.filename then
            gallery.selection = i
            break
        end
    end
    gallery:items_changed()
end

function follow_selection(_, val)
    gallery.pending.selection = val
end

function start()
    if gallery.active then return end
    playlist = mp.get_property_native("playlist")
    if #playlist == 0 then return end
    gallery.items = playlist

    local pos = mp.get_property_number("playlist-pos-1") --langar að nota frekar gallery.selection (til að vista hvar þetta opnbast) en eru einhver vandamál til að laga svo geymdi það
    if not gallery:activate(pos or 1) then return end

    did_pause = false
    if opts.pause_on_start and not mp.get_property_bool("pause", false) then
        mp.set_property_bool("pause", true)
        did_pause = true
    end
    if opts.command_on_open ~= "" then
        mp.command(opts.command_on_open)
    end
    if opts.follow_playlist_position then
        mp.observe_property("playlist-pos-1", "native", follow_selection)
    end

    setup_ui_handlers()
end

function load_selection()
    local sel = mp.get_property_number("playlist-pos-1", -1)
    if sel == gallery.selection then return end
    if opts.remember_time_position then
        if sel then
            local time = mp.get_property_number("time-pos")
            if time ~= nil then
                if time > 1 then
                    resume[gallery.items[sel].filename] = time
                end
            end
        end
        mp.set_property("playlist-pos-1", gallery.selection)
        local time = resume[gallery.items[gallery.selection].filename]
        if not time then return end
        local func
        func = function()
            mp.commandv("osd-msg-bar", "seek", time, "absolute")
            mp.unregister_event(func)
        end
        mp.register_event("file-loaded", func)
    else
        mp.set_property("playlist-pos-1", gallery.selection)
    end
end

function stop()
    if not gallery.active then return end
    if opts.resume_on_stop == "yes" or (opts.resume_on_stop == "only-if-did-pause" and did_pause) then
        mp.set_property_bool("pause", false)
    end
    if opts.command_on_close ~= "" then
        mp.command(opts.command_on_close)
    end
    if opts.follow_playlist_position then
        mp.unobserve_property(follow_selection)
    end
    gallery:deactivate()
    teardown_ui_handlers()
end

function toggle()
    if not gallery.active then
        start()
    else
        if opts.load_file_on_toggle_off then load_selection() end
        stop()
    end
end

mp.register_script_message("thumbnail-generated", function(thumb_path)
    gallery:thumbnail_generated(thumb_path)
end)

mp.register_script_message("metadata-generated", function(thumb_path)
    gallery:metadata_generated(thumb_path)
end)

mp.register_script_message("thumbnails-generator-broadcast", function(generator_name)
     gallery:add_generator(generator_name)
end)

mp.register_script_message("duration-generator-broadcast", function(generator_name)
    gallery:add_dur_generator(generator_name)
end)


function write_flag_file()
    if next(flags) == nil then return end
    local out = io.open(opts.flagged_file_path, "w")
    for f, _ in pairs(flags) do
        out:write(f .. "\n")
    end
    out:close()
end
mp.register_event("shutdown", write_flag_file)

if opts.start_on_file_end then
    mp.observe_property("eof-reached", "bool", function(_, val)
        if val and mp.get_property_number("playlist-count") > 1 and (mp.get_property("keep-open") == 'always') then
            start()
        end
    end)
end

if opts.start_on_mpv_startup then
    local autostart
    autostart = function()
        if mp.get_property_number("playlist-count") == 0 then return end
        if mp.get_property_number("osd-width") <= 0 then return end
        start()
        mp.unobserve_property(autostart)
    end
    mp.observe_property("playlist-count", "number", autostart)
    mp.observe_property("osd-width", "number", autostart)
end

-- workaround for mpv bug #6823
mp.observe_property("playlist", "native", playlist_changed)

mp.add_key_binding(nil, "playlist-view-open", function() start() end)
mp.add_key_binding(nil, "playlist-view-close", stop)
mp.add_key_binding(nil, "playlist-view-toggle", toggle)
mp.add_key_binding(nil, "playlist-view-load-selection", load_selection)
mp.add_key_binding(nil, "playlist-view-write-flag-file", write_flag_file)

