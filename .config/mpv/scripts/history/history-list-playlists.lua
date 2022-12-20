local lists_dir =  mp.command_native({"expand-path", "~~/scripts/misc_lists/?.lua"})
local misc_dir = mp.command_native({"expand-path", "~~/scripts/miscellaneous_scripts/?.lua"})
package.path = lists_dir .. ";" .. misc_dir .. ";" .. package.path 
local list_maker = require "scroll-list"
local ph_list = list_maker()
local utils = require("mp.utils")
local ph_history_path = mp.command_native({"expand-path", "~~/mpvPlaylistHistory.log"})
local only_this_file = false
local misc = require "miscellaneous"
local skipping_already_done = false

local function skip_after_timeout_if_possible(timeout)
    mp.add_timeout(timeout, function() 
            if (mp.get_property_number('time-pos') == nil) then return end
            if skipping_already_done then return end
            mp.commandv('seek', this.timestamp, 'absolute', 'exact') 
            skipping_already_done = true
    end)
end

local function ph_open_file_timestamped()
    this = ph_list.list[ph_list.selected]
    if this then
        mp.command_native({
            name='loadfile', 
            url=this.filePath, 
            options='playlist-start=' .. tostring(this.pos)
        })
        -- Þó það virkar að keyra td "mpv FILEPATH.m3u --playlist-start=4,start=400" þá virðist þetta
        -- ekki virka með loadfile því miður (sér í lagi start), þetta workaround virðist virka:
        if this.timestamp > 10 then -- óþarfi ef videoið var varla byrjað síðast
            skip_after_timeout_if_possible(0.1)
            skip_after_timeout_if_possible(1.0)
            skip_after_timeout_if_possible(2.0)
            skip_after_timeout_if_possible(3.0)
            skip_after_timeout_if_possible(3.5)
            skip_after_timeout_if_possible(4.0)
            skip_after_timeout_if_possible(4.5)
            skip_after_timeout_if_possible(5.0)
            skip_after_timeout_if_possible(5.5)
            skip_after_timeout_if_possible(6.0)
            skip_after_timeout_if_possible(6.5)
            skip_after_timeout_if_possible(7.0)
            skip_after_timeout_if_possible(7.5)
            skip_after_timeout_if_possible(8.0)
            skip_after_timeout_if_possible(8.5)
            skip_after_timeout_if_possible(9.0)
            skip_after_timeout_if_possible(9.5)
            mp.add_timeout(12, function() skipping_already_done = false end) -- resetta skipping already done
        end
        ph_list:close()
    end
end

ph_list.keybinds = {
    {'DOWN', 'scroll_down', function() ph_list:scroll_down() end, {repeatable = true}},
    {'UP', 'scroll_up', function() ph_list:scroll_up() end, {repeatable = true}},
    {'ENTER', 'ph_open_file_timestamped', ph_open_file_timestamped, {} },
    {'ESC', 'close_browser', function() ph_list:close() end, {}}
}

local function ph_read_logfile()
    only_this_file = false
    local copyLogAdd = io.open(ph_history_path, 'r+')
    local history = {}
    local item, b1_ind, b2_ind, l1_ind, l2_ind
    local index = 1, maxind 
    local consecutive_entries = 0
    for line in copyLogAdd:lines() do
        item = {} 
        b1_ind = line:find("%[")
        b2_ind = line:find("%]")
        l1_ind = line:find("|")
        l2_ind = line:find("|", l1_ind+1)

        item.date = string.sub(line, b1_ind+1, b2_ind-1)
        item.filePath = line:match('%] (.*) |pos=')
        item.pos = tonumber(line:match('|pos=(.*) |time='))
        item.timestamp = tonumber(line:match('|time=(.*) |title='))
        time_in_clockform = os.date('!%H:%M:%S', item.timestamp)
        --time_in_clockform = time_in_clockform:gsub("00:","", 2) -- trims leading 0s hours and mins
        --time_in_clockform = time_in_clockform:gsub("00:","", 1) -- trims leading 0s just hours
        date = string.sub(item.date, 11, 15) .. ' ' .. string.sub(item.date, 1, 9)
        _, playlist_name = utils.split_path(item.filePath)
        playlist_name = playlist_name:match("(.+)%..+") --fjarlægir ext
        if playlist_name == nil then -- þá er þetta folder
            folder_split = misc.splitstring(item.filePath, '/')
            parent_folder = folder_split[#folder_split]
            gparent_folder = folder_split[#folder_split-1]
            if (gparent_folder ~= nil) and (parent_folder:lower():match('season') ~= nil) then
                playlist_name = gparent_folder .. '/' .. parent_folder
            else
                playlist_name = parent_folder
            end
        end
        vid_title = line:match('|title=(.*)')
        if vid_title == nil then vid_title = ' ' end


        item.playlist_name = playlist_name
        if index == 1 then 
        elseif playlist_name == history[index-1].playlist_name then 
            consecutive_entries = consecutive_entries + 1
        else
            consecutive_entries = 0
        end
        local mention_hidden = ''
        local hidden_indicator = ''
        if consecutive_entries > 0 then 
            mention_hidden = '{\\b1}(' .. consecutive_entries .. ' hidden){\\b0} '
            hidden_indicator = '➢ '
        end

        item.ass = '[' .. date .. ', t=' .. time_in_clockform:sub(1,-1) .. '] ' .. hidden_indicator .. playlist_name .. '{\\fs14} ' .. mention_hidden .. '   #'.. string.format('%d', item.pos + 1) .. ': ' .. vid_title
        --item.style = [[{\c&H33ff66&}]]


        --filePath = string.match(line, "%][^|]*|")
        --filePath = string.sub(filePath, 3, -3)
               if consecutive_entries > 0 then 
            history[index - 1] = item
        else
            history[index] = item
            maxind = index 
            index = index + 1
        end
    end
    copyLogAdd.close()
    return history, maxind
end 

local function ph_make_list()
    ph_list.header = "Playlist History \\N ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
    local historytable, history_length
    historytable, history_length = ph_read_logfile()

    ph_list.list = {}
    local item
    for k, v in pairs(historytable) do 
        --item = {}
        --item.ass = v
        ph_list.list[history_length + 1 - k] = v
    end
    ph_list:update()
end

local function ph_toggle_history()
    ph_make_list()
    ph_list:toggle()
end

mp.add_key_binding(nil, "toggle-playlist-history", ph_toggle_history)
