local utils = require 'mp.utils'
local assdraw = require 'mp.assdraw'

misc_script = mp.command_native({'expand-path', '~~/scripts/miscellaneous_scripts/miscellaneous.lua'})
package.path = misc_script .. ";" .. package.path
local misc = require 'miscellaneous'

local metadataLog = mp.command_native({'expand-path', '~~/mpvMetadata.log'})
local duration_overlays = mp.command_native({'expand-path', '/mnt/derichet/mpv_thumbnails_etc/overlays/durations/raw/'})
local date_overlays = mp.command_native({'expand-path', '/mnt/derichet/mpv_thumbnails_etc/overlays/dates/raw/'})

local gallery_mt = {}
gallery_mt.__index = gallery_mt



function gallery_new()
    local gallery = setmetatable({
        active = false,
        items = {},
        geometry = {
            window = { 0, 0 },
            gallery_position = { 0, 0 },
            gallery_size = { 0, 0 },
            min_spacing = { 0, 0 },
            thumbnail_size = { 0, 0 },
            rows = 0,
            columns = 0,
            effective_spacing = { 0, 0 },
        },
        view = { -- 1-based indices into the "playlist" array
            first = 0, -- must be equal to N*columns
            last = 0, -- must be > first and <= first + rows*columns
        },
        overlays = {
            active = {}, -- array of <=64 strings indicating the file associated to the current overlay (false if nothing)
            missing = {}, -- associative array of thumbnail path to view index it should be shown at
            metadata_active = {}, -- nota hér 1-30 eins og fyrir venjulegu indexana en alltaf þegar þú kallar 
            metadata_missing = {} -- á overlay-add þá bæta við 30
        },
        selection = 0,
        pending = {
            selection = nil,
            geometry_changed = false,
        },
        config = {
            background = true,
            background_color = '333333',
            background_opacity = '33',
            background_roundness = 5,
            scrollbar = true,
            scrollbar_left_side = false,
            scrollbar_min_size = 10,
            max_thumbnails = 64,
            show_placeholders = true,
            always_show_placeholders = false,
            placeholder_color = '222222',
            text_size = 28,
            align_text = true,
            accurate = false,
            generate_thumbnails_with_mpv = false,
            selected_color = "00C3FF",
            playing_color = "14a80f",
        },
        ass = {
            background = "",
            selection = "",
            scrollbar = "",
            placeholders = "",
        },
        generators = {}, -- list of generator scripts
        metadata_generators = {}, -- list of duration generators

        too_small = function() return end,
        item_to_overlay_path = function(index, item) return "" end,
        item_to_thumbnail_params = function(index, item) return "", 0 end,
        item_to_text = function(index, item) return "", true end,
        item_to_border = function(index, item) return 0, "" end,
        set_geometry_props = function(ww, wh) return end,

        idle,
        window_changed,
        metadata = misc:read_metadata_log(metadataLog),
        location_info = mp.create_osd_overlay('ass-events')
    }, gallery_mt)
    for i = 1, gallery.config.max_thumbnails do
        gallery.overlays.active[i] = false
        gallery.overlays.metadata_active[i] = false
    end
    return gallery
end

function gallery_mt.show_overlay(gallery, index_1, thumb_path)
    local g = gallery.geometry
    gallery.overlays.active[index_1] = thumb_path
    local index_0 = index_1 - 1
    local x, y = gallery:view_index_position(index_0)


    mp.command_native({
        name='overlay-add',
        id=index_0,
        x=math.floor(x + 0.5),
        y=math.floor(y + 0.5),
        file=thumb_path,
        offset=0,
        fmt="bgra",
        w=g.thumbnail_size[1],
        h=g.thumbnail_size[2],
        stride=4*g.thumbnail_size[1]
    })
    mp.osd_message(" ", 0.01) -- Ég bætti þessu ekki við, er væntanlega einhver ástæða að þetta þarf...
end

function gallery_mt.show_metadata(gallery, index_1, thumb_path)
    local g = gallery.geometry
    gallery.overlays.metadata_active[index_1] = thumb_path
    local index_0 = index_1 - 1
    local x, y = gallery:view_index_position(index_0)
    local metadata_w = 90
    local metadata_h = 28
    local pad_w = 0
    local pad_h = 0

    dir, _ = utils.split_path(thumb_path)
    t = utils.readdir(dir)
    for _, file in pairs(t) do 
        file = utils.join_path(dir, file)
        local extracted_time = gallery.metadata[thumb_path]['duration']
        local extracted_date = gallery.metadata[thumb_path]['date']
        if tonumber(extracted_time) > 43200 then 
            extracted_time = tostring(math.floor(tonumber(extracted_time)/600+0.5)*600) -- námunda að næstu 10 min
        elseif tonumber(extracted_time) > 18000 then
            extracted_time = tostring(math.floor(tonumber(extracted_time)/60+0.5)*60) -- námunda að næstu min
        end

        if extracted_time ~= nil then 
            extracted_time = tonumber(extracted_time)
            mp.command_native({
                name='overlay-add',
                id=20+index_0,
                x=math.floor(x + g.thumbnail_size[1] - metadata_w - pad_w),
                y=math.floor(y + g.thumbnail_size[2] - metadata_h - pad_h),
                file=duration_overlays .. misc.timestamp_path(extracted_time),
                offset=0,
                fmt="bgra",
                w=metadata_w,
                h=metadata_h,
                stride=4*metadata_w
            })

            if type(tonumber(extracted_date)) == 'number' then -- líklega hægt að gera þetta betur
                date_path = extracted_date:sub(3, 4) .. '-' .. extracted_date:sub(5, 6) .. '-' .. extracted_date:sub(7, 8)
                mp.command_native({
                    name='overlay-add',
                    id=40+index_0,
                    x=math.floor(x - pad_w),
                    y=math.floor(y + g.thumbnail_size[2] - metadata_h - pad_h),
                    file=date_overlays .. date_path,
                    offset=0,
                    fmt="bgra",
                    w=metadata_w,
                    h=metadata_h,
                    stride=4*metadata_w
                })
            end
            break
        end
    end
    mp.osd_message(" ", 0.01) -- Ég bætti þessu ekki við, er væntanlega einhver ástæða að þetta þarf...
end

function gallery_mt.remove_overlays(gallery)
    for view_index, _ in pairs(gallery.overlays.active) do
        mp.command("overlay-remove " .. view_index - 1)
        gallery.overlays.active[view_index] = false
    end

    for view_index, _ in pairs(gallery.overlays.metadata_active) do
        mp.command("overlay-remove " .. 20 + view_index - 1)
        mp.command("overlay-remove " .. 40 + view_index - 1)
        gallery.overlays.metadata_active[view_index] = false
    end
    gallery.overlays.missing = {}
    gallery.overlays.metadata_missing = {}
end

local function file_exists(path)
    local info = utils.file_info(path)
    return info ~= nil and info.is_file
end

function gallery_mt.refresh_overlays(gallery, force)
    local todo = {}
    local dur_todo = {}
    local o = gallery.overlays
    local g = gallery.geometry
    o.missing = {}
    
    for view_index = g.rows * g.columns, 1, -1 do
        local index = gallery.view.first + view_index - 1
        local active = o.active[view_index]
        local metadata_active = o.metadata_active[view_index]
        
        if index <= #gallery.items then
            local thumb_path = gallery.item_to_overlay_path(index, gallery.items[index])
            
            ---- FYRST THUMBNAILS -------------------------------------------------------------
            if not force and active == thumb_path then
                -- nothing to do
            elseif file_exists(thumb_path) then
                -- TKJ BÆTA VIÐ EINHVERJU HÉR UM AÐ TJÉKKA Á
                -- HVORT DURATION SÉ TIL OG BÚA TIL EF
                gallery:show_overlay(view_index, thumb_path)
            else
                -- need to generate that thumbnail
                o.active[view_index] = false
                mp.command("overlay-remove " .. view_index - 1)
                o.missing[thumb_path] = view_index
                todo[#todo + 1] = { index = index, output = thumb_path }
            end


            ---- SVO DURATIONS -----------------------------------------------------------------
            if not force and metadata_active == thumb_path then
                -- nothing to do
            elseif gallery.metadata[thumb_path] ~= nil then
                gallery:show_metadata(view_index, thumb_path)
            else
                -- need to generate that duration
                o.metadata_active[view_index] = false
                mp.command("overlay-remove " .. 20 + view_index - 1) 
                mp.command("overlay-remove " .. 40 + view_index - 1) 
                o.metadata_missing[thumb_path] = view_index
                dur_todo[#dur_todo + 1] = { index = index, output = thumb_path }
            end

        else
            -- might happen if we're close to the end of gallery.items
            if active ~= false then
                o.active[view_index] = false
                o.metadata_active[view_index] = false
                mp.command("overlay-remove " .. view_index - 1)
                mp.command("overlay-remove " .. 20 + view_index - 1) 
                mp.command("overlay-remove " .. 40 + view_index - 1) 
            end
        end

    end

    if #gallery.generators >= 1 then
        -- reverse iterate so that the first thumbnail is at the top of the stack
        for i = #todo, 1, -1 do
            local generator = gallery.generators[i % #gallery.generators + 1]
            local t = todo[i]
            local input_path, time = gallery.item_to_thumbnail_params(t.index, gallery.items[t.index])
            mp.commandv("script-message-to", generator, "push-thumbnail-front",
                mp.get_script_name(),
                input_path,
                tostring(g.thumbnail_size[1]),
                tostring(g.thumbnail_size[2]),
                time,
                t.output,
                gallery.config.accurate and "true" or "false",
                gallery.config.generate_thumbnails_with_mpv and "true" or "false"
            )
        end
    end

    if #gallery.metadata_generators >= 1 then
        -- reverse iterate so that the first thumbnail is at the top of the stack
        for i = #dur_todo, 1, -1 do
            local generator = gallery.metadata_generators[i % #gallery.metadata_generators + 1]
            local t = dur_todo[i]
            local input_path, time = gallery.item_to_thumbnail_params(t.index, gallery.items[t.index])
            mp.commandv("script-message-to", generator, "push-metadata-front",
                mp.get_script_name(),
                input_path,
                t.output
            )
        end
    end
end

function gallery_mt.index_at(gallery, mx, my)
    local g = gallery.geometry
    if mx < g.gallery_position[1] or my < g.gallery_position[2] then return nil end
    mx = mx - g.gallery_position[1]
    my = my - g.gallery_position[2]
    if mx > g.gallery_size[1] or my > g.gallery_size[2] then return nil end
    mx = mx - g.effective_spacing[1]
    my = my - g.effective_spacing[2]
    local on_column = (mx % (g.thumbnail_size[1] + g.effective_spacing[1])) < g.thumbnail_size[1]
    local on_row = (my % (g.thumbnail_size[2] + g.effective_spacing[2])) < g.thumbnail_size[2]
    if on_column and on_row then
        local column = math.floor(mx / (g.thumbnail_size[1] + g.effective_spacing[1]))
        local row = math.floor(my / (g.thumbnail_size[2] + g.effective_spacing[2]))
        local index = gallery.view.first + row * g.columns + column
        if index <= gallery.view.last then
            return index
        end
    end
    return nil
end

function gallery_mt.compute_geometry(gallery)
    local g = gallery.geometry
    g.rows = math.floor((g.gallery_size[2] - g.min_spacing[2]) / (g.thumbnail_size[2] + g.min_spacing[2]))
    g.columns = math.floor((g.gallery_size[1] - g.min_spacing[1]) / (g.thumbnail_size[1] + g.min_spacing[1]))
    if (g.rows * g.columns > gallery.config.max_thumbnails) then
        local r = math.sqrt(g.rows * g.columns / gallery.config.max_thumbnails)
        g.rows = math.floor(g.rows / r)
        g.columns = math.floor(g.columns / r)
    end
    g.effective_spacing[1] = (g.gallery_size[1] - g.columns * g.thumbnail_size[1]) / (g.columns + 1)
    g.effective_spacing[2] = (g.gallery_size[2] - g.rows * g.thumbnail_size[2]) / (g.rows + 1)
    return true
end

-- makes sure that view.first and view.last are valid with regards to the playlist
-- and that selection is within the view
-- to be called after the playlist, view or selection was modified somehow
function gallery_mt.ensure_view_valid(gallery)
    local v = gallery.view
    local g = gallery.geometry
    local selection_row = math.floor((gallery.selection - 1) / g.columns)
    local max_thumbs = g.rows * g.columns
    local changed = false

    if v.last >= #gallery.items then
        v.last = #gallery.items
        last_row = math.floor((v.last - 1) / g.columns)
        first_row = math.max(0, last_row - g.rows + 1)
        v.first = 1 + first_row * g.columns
        changed = true
    elseif v.first == 0 or v.last == 0 or v.last - v.first + 1 ~= max_thumbs then
        -- special case: the number of possible thumbnails was changed
        -- just recreate the view such that the selection is in the middle row
        local max_row = (#gallery.items - 1) / g.columns + 1
        local row_first = selection_row - math.floor((g.rows - 1) / 2)
        local row_last = selection_row + math.floor((g.rows - 1) / 2) + g.rows % 2
        if row_first < 0 then
            row_first = 0
        elseif row_last > max_row then
            row_first = max_row - g.rows + 1
        end
        v.first = 1 + row_first * g.columns
        v.last = math.min(#gallery.items, v.first - 1 + max_thumbs)
        return true
    end

    if gallery.selection < v.first then
        -- the selection is now on the first line
        v.first = selection_row * g.columns + 1
        v.last = math.min(#gallery.items, v.first + max_thumbs - 1)
        changed = true
    elseif gallery.selection > v.last then
        -- the selection is now on the last line
        v.last = (selection_row + 1) * g.columns
        v.first = math.max(1, v.last - max_thumbs + 1)
        v.last = math.min(#gallery.items, v.last)
        changed = true
    end
    return changed
end

-- ass related stuff
function gallery_mt.refresh_background(gallery)
    local g = gallery.geometry
    local a = assdraw.ass_new()
    a:new_event()
    a:append('{\\bord0}')
    a:append('{\\shad0}')
    a:append('{\\1c&' .. gallery.config.background_color .. '}')
    a:append('{\\1a&' .. gallery.config.background_opacity .. '}')
    a:pos(0, 0)
    a:draw_start()
    a:round_rect_cw(g.gallery_position[1], g.gallery_position[2], g.gallery_position[1] + g.gallery_size[1], g.gallery_position[2] + g.gallery_size[2], gallery.config.background_roundness)
    a:draw_stop()
    gallery.ass.background = a.text
end

function gallery_mt.refresh_placeholders(gallery)
    if not gallery.config.show_placeholders then return end
    local g = gallery.geometry
    local a = assdraw.ass_new()
    a:new_event()
    a:append('{\\bord0}')
    a:append('{\\shad0}')
    a:append('{\\1c&' .. gallery.config.placeholder_color .. '}')
    a:pos(0, 0)
    a:draw_start()
    for i = 0, gallery.view.last - gallery.view.first do
        if gallery.config.always_show_placeholders or not gallery.overlays.active[i + 1] then
            local x, y = gallery:view_index_position(i)
            a:rect_cw(x, y, x + g.thumbnail_size[1], y + g.thumbnail_size[2])
        end
    end
    a:draw_stop()
    gallery.ass.placeholders = a.text
end

function gallery_mt.refresh_scrollbar(gallery)
    if not gallery.config.scrollbar then return end
    gallery.ass.scrollbar = ""
    local g = gallery.geometry
    local before = (gallery.view.first - 1) / #gallery.items
    local after = (#gallery.items - gallery.view.last) / #gallery.items
    -- don't show the scrollbar if everything is visible
    if before + after == 0 then return end
    local p = gallery.config.scrollbar_min_size / 100
    if before + after > 1 - p then
        if before == 0 then
            after = (1 - p)
        elseif after == 0 then
            before = (1 - p)
        else
            before, after =
                before / after * (1 - p) / (1 + before / after),
                after / before * (1 - p) / (1 + after / before)
        end
    end
    local dist_from_edge = g.gallery_size[2] * 0.015
    local y1 = g.gallery_position[2] + dist_from_edge + before * (g.gallery_size[2] - 2 * dist_from_edge)
    local y2 = g.gallery_position[2] + g.gallery_size[2] - (dist_from_edge + after * (g.gallery_size[2] - 2 * dist_from_edge))
    local x1, x2
    if gallery.config.scrollbar_left_side then
        x1 = g.gallery_position[1] + g.effective_spacing[1] / 2 - 2
    else
        x1 = g.gallery_position[1] + g.gallery_size[1] - g.effective_spacing[1] / 2 - 2
    end
    x2 = x1 + 4
    local scrollbar = assdraw.ass_new()

    scrollbar:new_event()
    scrollbar:append('{\\bord0}')
    scrollbar:append('{\\shad0}')
    scrollbar:append('{\\1c&AAAAAA&}')
    scrollbar:pos(0, 0)
    scrollbar:draw_start()
    scrollbar:rect_cw(x1, y1, x2, y2)
    scrollbar:draw_stop()


    gallery.ass.scrollbar = scrollbar.text
end

function gallery_mt.refresh_selection(gallery)
    local selection_ass = assdraw.ass_new()
    local v = gallery.view
    local g = gallery.geometry
    local draw_frame = function(index, size, color)
        local x, y = gallery:view_index_position(index - v.first)
        selection_ass:new_event()
        selection_ass:append('{\\bord' .. size ..'}')
        selection_ass:append('{\\3c&'.. color ..'&}')
        selection_ass:append('{\\1a&FF&}')
        selection_ass:pos(0, 0)
        selection_ass:draw_start()
        selection_ass:rect_cw(x, y, x + g.thumbnail_size[1], y + g.thumbnail_size[2])
        selection_ass:draw_stop()
    end
    for i = v.first, v.last do
        local size, color = gallery.item_to_border(i, gallery.items[i])
        if size > 0 then
            draw_frame(i, size, color)
        end
    end

    for index = v.first, v.last do
        local text  = gallery.item_to_text(index, gallery.items[index])
        if text ~= "" then
            selection_ass:new_event()
            local an = 5
            local x, y = gallery:view_index_position(index - v.first)
            x = x + g.thumbnail_size[1] / 2
            y = y + g.thumbnail_size[2] + gallery.config.text_size * 0.75

            if gallery.config.align_text then
                local col = (index - v.first) % g.columns
                --if g.columns > 1 then
                --    if col == 0 then
                --        x = x - g.thumbnail_size[1] / 2
                --        an = 4
                --    elseif col == g.columns - 1 then
                --        x = x + g.thumbnail_size[1] / 2
                --        an = 6
                --    end
                --end
            end
            selection_ass:an(an)
            
            currently_playing = gallery.items[index]['filename'] == mp.get_property('path')
            -- TKJ eftirfarandi if/else stillir staðsetningu og stærð texta,
            -- fyrst fyrir valið item og svo öll hin
            -- ég hef customizað þetta eftir línufjölda
            _, linecount = string.gsub(text, "\\N", "")
            linecount = linecount + 1 

            -- Default stillingar (óbreytt fyrir 1-línu óvalin items)
            text_size = gallery.config.text_size + 5
            textX = x
            textY = y + 4
            lineweight = 4 -- Hve mikið færum við textann á selected niður

            -- Ef lítil thumbnails (út af lítilli gluggastærð) þá minnkum við fontið og bilið
            if gallery.geometry.thumbnail_size[1] < 500 then 
                text_size = text_size - 16
                textY = textY - 14
                lineweight = 2
            end

            -- Breytingar fyrir valið item
            if index == gallery.selection then  -- selected item
                text_size = text_size + 6
                textY = textY + lineweight*linecount
                selection_ass:append("{\\c&" .. gallery.config.selected_color .."}") -- breytir litnum
            elseif currently_playing then 
                selection_ass:append("{\\c&" .. gallery.config.playing_color .. "}") -- breytir litnum
            end

            -- Breytingar fyrir items með fleiri línum
            if linecount == 2 then
                textY = textY + 14
            elseif linecount == 3 then
                if gallery.geometry.thumbnail_size[1] < 500 then 
                    textY = textY + 24
                else
                    textY = textY + 32
                end
            elseif linecount > 3 then
                text_size = text_size - 8
                if gallery.geometry.thumbnail_size[1] < 500 then 
                    textY = textY + 30
                else
                    textY = textY + 36
                end
            end

            selection_ass:append(string.format("{\\fs%d}", text_size))
            selection_ass:pos(textX, textY)

            selection_ass:append("{\\bord0}")
            selection_ass:append(text)
        end
    end


    local display_w, display_h, display_aspect = mp.get_osd_size()

    selection_ass:new_event()
    --selection_ass:an(1)
    selection_ass:pos(20,display_h-50)
    
    local loc_font_size
    if mp.get_property('fullscreen') == 'yes' then 
        loc_font_size = 34
    else
        loc_font_size = 24
    end
    selection_ass:append("{\\1a&H55&}")
    selection_ass:append("{\\bord0}")
    selection_ass:append(string.format("{\\fs%d}", loc_font_size))
    selection_ass:append('Showing videos ' .. gallery.view.first .. ' to ' .. gallery.view.last .. ' out of ' .. #gallery.items .. ' ')
    selection_ass:append('  |   Playlist entry ' .. gallery.selection .. ' is selected')




    gallery.ass.selection = selection_ass.text
end


function gallery_mt.ass_show(gallery, selection, scrollbar, placeholders, background)
    if selection then gallery:refresh_selection() end
    if scrollbar then gallery:refresh_scrollbar() end
    if placeholders then gallery:refresh_placeholders() end
    if background then gallery:refresh_background() end
    local merge = function(a, b)
        return b ~= "" and (a .. "\n" .. b) or a
    end
    mp.set_osd_ass(gallery.geometry.window[1], gallery.geometry.window[2],
        merge(
            gallery.ass.background,
            merge(
                gallery.ass.placeholders,
                merge(
                    gallery.ass.selection,
                    gallery.ass.scrollbar
                )
            )
        )
    )
end

function gallery_mt.ass_hide()
    mp.set_osd_ass(1280, 720, "")
end

function gallery_mt.idle_handler(gallery)
    if gallery.pending.selection then
        gallery.selection = gallery.pending.selection
        gallery.pending.selection = nil
        if gallery:ensure_view_valid() then
            gallery:refresh_overlays(false)
            gallery:ass_show(true, true, true, false)
        else
            gallery:ass_show(true, false, false, false)
        end
    end
    if gallery.pending.geometry_changed then
        gallery.pending.geometry_changed = false
        local ww, wh = mp.get_osd_size()
        if ww ~= gallery.geometry.window[1] or wh ~= gallery.geometry.window[2] then
            gallery.set_geometry_props(ww, wh)
            if not gallery:enough_space() then
                gallery.too_small()
                return
            end
            local old_total = gallery.geometry.rows * gallery.geometry.columns
            gallery:compute_geometry()
            local new_total = gallery.geometry.rows * gallery.geometry.columns
            for view_index = new_total + 1, old_total do
                mp.command("overlay-remove " .. view_index - 1)
                mp.command("overlay-remove " .. 20 + view_index - 1) -- timestamp
                mp.command("overlay-remove " .. 40 + view_index - 1) -- timestamp
                gallery.overlays.active[view_index] = false
            end
            gallery:ensure_view_valid()
            gallery:refresh_overlays(true)
            gallery:ass_show(true, true, true, true)
        end
    end
end

function gallery_mt.items_changed(gallery)
    gallery:ensure_view_valid()
    gallery:refresh_overlays(false)
    gallery:ass_show(true, true, true, false)
end

function gallery_mt.thumbnail_generated(gallery, thumb_path)
    if not gallery.active then return end
    local view_index = gallery.overlays.missing[thumb_path]
    if view_index == nil then return end
    gallery:show_overlay(view_index, thumb_path)
    if not gallery.config.always_show_placeholders then
        gallery:ass_show(false, false, true, false)
    end
    gallery.overlays.missing[thumb_path] = nil
end

function gallery_mt.metadata_generated(gallery, generator_output)
    if (generator_output == nil) then return end
    local parsed_record = misc.parse_metadata_log_line(generator_output)
    if (parsed_record['duration'] == nil) or (parsed_record['thumb_path'] == nil) then return end
    gallery.metadata[parsed_record['thumb_path']] = {
        duration=parsed_record['duration'],
        date=parsed_record['date']
    }
    if not gallery.active then return end
    local view_index = gallery.overlays.metadata_missing[parsed_record['thumb_path']]
    if view_index == nil then return end
    gallery:show_metadata(view_index, parsed_record['thumb_path'])
    gallery.overlays.metadata_missing[parsed_record['thumb_path']] = nil
end

function gallery_mt.add_generator(gallery, generator_name)
    for _, g in ipairs(gallery.generators) do
        if generator_name == g then return end
    end
    gallery.generators[#gallery.generators + 1] = generator_name
end

function gallery_mt.add_dur_generator(gallery, generator_name)
    for _, g in ipairs(gallery.metadata_generators) do
        if generator_name == g then return end
    end
    gallery.metadata_generators[#gallery.metadata_generators + 1] = generator_name
end

function gallery_mt.view_index_position(gallery, index_0)
    local g = gallery.geometry
    return math.floor(g.gallery_position[1] + g.effective_spacing[1] + (g.effective_spacing[1] + g.thumbnail_size[1]) * (index_0 % g.columns)),
        math.floor(g.gallery_position[2] + g.effective_spacing[2] + (g.effective_spacing[2] + g.thumbnail_size[2]) * math.floor(index_0 / g.columns))
end

function gallery_mt.enough_space(gallery)
    if gallery.geometry.gallery_size[1] < gallery.geometry.thumbnail_size[1] + 2 * gallery.geometry.min_spacing[1] then return false end
    if gallery.geometry.gallery_size[2] < gallery.geometry.thumbnail_size[2] + 2 * gallery.geometry.min_spacing[2] then return false end
    return true
end

function gallery_mt.activate(gallery, selection)
    if gallery.active then return false end
    if #gallery.items == 0 then return false end
    local ww, wh = mp.get_osd_size()
    gallery.set_geometry_props(ww, wh)
    if not gallery:enough_space() then return false end
    gallery:compute_geometry()
    gallery.selection = selection
    gallery:ensure_view_valid()
    gallery:refresh_overlays(false)
    gallery:ass_show(true, true, true, true)
    gallery.idle = function() gallery:idle_handler() end
    mp.register_idle(gallery.idle)
    gallery.window_changed = function() gallery.pending.geometry_changed = true end
    for _, prop in ipairs({ "osd-width", "osd-height" }) do
        mp.observe_property(prop, "native", gallery.window_changed)
    end
    gallery.active = true
    return true
end

function gallery_mt.deactivate(gallery)
    if not gallery.active then return end
    gallery:remove_overlays()
    gallery:ass_hide()
    mp.unregister_idle(gallery.idle)
    mp.unobserve_property(gallery.window_changed)
    gallery.active = false
end

return {gallery_new = gallery_new}

