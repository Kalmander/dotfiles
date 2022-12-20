local utils = require 'mp.utils'
local misc_scripts_dir = mp.command_native({"expand-path", "~~/scripts/miscellaneous_scripts"})
package.path = misc_scripts_dir .. "/?.lua;" .. package.path
local misc = require 'miscellaneous'
local options = require 'mp.options'
special_options = {
    ds9=false,
    tng_long=false,
    tng_short=false,
    short_skips=false,
    print_local_notification=false
}
options.read_options(special_options, 'misc')


-----------------------------------------------------------------------------
---- Subscripts -------------------------------------------------------------
-----------------------------------------------------------------------------
autocrop        = utils.join_path(misc_scripts_dir, "autocrop.lua")
clock           = utils.join_path(misc_scripts_dir, "clock.lua")
ruler           = utils.join_path(misc_scripts_dir, "ruler.lua")
after_playback  = utils.join_path(misc_scripts_dir, "after-playback.lua")
refresh_rate    = utils.join_path(misc_scripts_dir, "refresh-rate.lua")
search_page     = utils.join_path(misc_scripts_dir, "search-page.lua")
download_video  = utils.join_path(misc_scripts_dir, "download-video.lua")
youtube_quality = utils.join_path(misc_scripts_dir, "youtube-quality.lua")

dofile(autocrop)
dofile(clock)
dofile(ruler)
dofile(after_playback)
dofile(refresh_rate)
dofile(search_page)
dofile(download_video)
dofile(youtube_quality)


-----------------------------------------------------------------------------
---- Önnur föll -------------------------------------------------------------
-----------------------------------------------------------------------------
local dimmer = require 'dim-the-lights'
local function toggle_dimmer()
    dimmer:toggle()
end

-- Hætti með þetta því það var stupid en vildi ekki eyða kóðanum því 
-- svalar hugmyndir í honum
--local function apply_special_options()
--    options.read_options(special_options, 'miscellaneous_scripts')
--    if special_options.ds9 then 
--        mp.remove_key_binding("long-seek-back")
--        mp.remove_key_binding("long-seek-forw")
--        mp.add_forced_key_binding('CTRL+left',  "long-seek-back", function() mp.command('no-osd seek -110') end)
--        mp.add_forced_key_binding('CTRL+right', "long-seek-forw", function() mp.command('no-osd seek +110') end)
--    elseif special_options.tng_short then 
--        mp.remove_key_binding("long-seek-back")
--        mp.remove_key_binding("long-seek-forw")
--        mp.add_forced_key_binding('CTRL+left',  "long-seek-back", function() mp.command('no-osd seek -97 exact') end)
--        mp.add_forced_key_binding('CTRL+right', "long-seek-forw", function() mp.command('no-osd seek +97 exact') end)
--    elseif special_options.tng_long then 
--        mp.remove_key_binding("long-seek-back")
--        mp.remove_key_binding("long-seek-forw")
--        mp.add_forced_key_binding('CTRL+left',  "long-seek-back", function() mp.command('no-osd seek -105 exact') end)
--        mp.add_forced_key_binding('CTRL+right', "long-seek-forw", function() mp.command('no-osd seek +105 exact') end)
--    end
--end
 
local function remove_unwanted_playlist_items(_, playlist)
    unwanted_inds = {}
    unwanted_exts = {srt=1, sub=1, idx=1, db=1, ini=1, txt=1, lnk=1} --Hef gildin sem keys til að finna þau hraðar
    for ind, item in pairs(playlist) do 
        split_name = misc.splitstring(item['filename'], '.')
        ext = split_name[#split_name]
        if unwanted_exts[ext] ~= nil then -- þýðir: if ext in unwanted exts
            table.insert(unwanted_inds, ind-1)
        end
    end

    for i = #unwanted_inds, 1, -1 do
        ind = unwanted_inds[i]
        mp.command('playlist-remove ' .. ind)
    end
end

local function print_estimated_filesize()
    -- Hugsað fyrir streams þar sem ég veit ekki stærðina
    print('\n')
    print('________________________')
    print('Estimation of file size:')

    video_bitrate = mp.get_property_number('video-bitrate')
    if (video_bitrate == nil) then 
        print('Video bitrate was nil, try again')
        return
    end
    print('video bitrate [bits/sec]: ' .. string.format("%.2f", video_bitrate))

    audio_bitrate = mp.get_property_number('audio-bitrate')
    if (audio_bitrate == nil) then 
        print('Audio bitrate was nil, try again')
        return
    end
    print('audio bitrate [bits/sec]: ' .. string.format("%.2f", audio_bitrate))

    sub_bitrate = mp.get_property_number('sub-bitrate')
    if (sub_bitrate == nil) then 
        print('Sub bitrate was nil, ignoring it')
    else 
        print('sub-bitrate [bits/sec]: ' .. string.format("%.2f", sub_bitrate))
    end

    duration = mp.get_property_number('duration')
    if (duration == nil) then 
        print('Duration was nil, try again')
        return
    end
    print('duration [secs]: ' .. string.format("%.2f", duration))

    bitrate = video_bitrate + audio_bitrate
    if (sub_bitrate ~= nil) then 
        bitrate = bitrate + sub_bitrate
    end

    size = bitrate*duration/8000000
    mp.osd_message('Estimated video size [in MB]: ' .. string.format("%.2f", size), 4)
    print('Estimated video size [in MB]: ' .. string.format("%.2f", size))
    print('\n')
end


-----------------------------------------------------------------------------
---- Key bindings etc. ------------------------------------------------------
-----------------------------------------------------------------------------
mp.add_key_binding(nil, 'toggle-dimmer', toggle_dimmer)
mp.add_key_binding(nil, 'print-estimated-filesize', print_estimated_filesize)
mp.add_key_binding(nil, 'open-in-explorer', function()
    -- Það var smá maus að fá þetta til að virka rétt fyrir öll skjöl, 
    -- þurfti að vera nákvæmlega svona, þeas
    -- þurfti að nota command_native og hafa kommuna í /select
    -- og EKKI hafa aukagæsalappir utan um path
    path = mp.get_property('path')
    path = path:gsub('/', '\\') -- þetta þarf í windows, sem er ástæðan að input.conf aðferðin virkar ekki
    command = {
        'explorer', 
        '/select,', 
        path
    }
    command_native_output = mp.command_native({
        name = "subprocess",
        args = command
    })
end)
--mp.observe_property('options/script-opts', 'string', apply_special_options)
mp.observe_property('playlist', 'native', remove_unwanted_playlist_items)

if special_options.short_skips == true then 
    mp.add_forced_key_binding('left',  "short-seek-back", function() mp.command('no-osd seek -0.05 exact') end)
    mp.add_forced_key_binding('right', "short-seek-forw", function() mp.command('no-osd seek +0.05 exact') end)
end

if special_options.print_local_notification == true then 
    mp.osd_message('Reopened video locally')
    print('Reopened video locally')
end
