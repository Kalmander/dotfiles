local script_dir =  mp.command_native( {"expand-path", "~~/scripts" } )
local lists_dir = script_dir .. '/misc_lists/?.lua'
package.path = lists_dir .. ";" .. package.path
local list_maker = require "scroll-list"
local history_list = list_maker()
local utils = require("mp.utils")
-- local history_path = utils.join_path(script_dir, "../../mpvHistory.log")
local history_path = mp.command_native({"expand-path", "~~/mpvHistory.log"})
local only_this_file = false

local function history_open_file() 
    if only_this_file == true then 
        mp.commandv('seek', history_list.list[history_list.selected].timestamp, 'absolute', 'exact')
    else
        if history_list.list[history_list.selected] then
            mp.commandv('loadfile', history_list.list[history_list.selected].filePath)
            history_list:close()
        end
    end
end

local function history_open_file_timestamped()
    if history_list.list[history_list.selected] then
        mp.command_native({
            name='loadfile', 
            url=history_list.list[history_list.selected].filePath, 
            options='start=' .. tostring(history_list.list[history_list.selected].timestamp)
            }
        )
    end
end

local function history_open_file_append()
    if history_list.list[history_list.selected] then
        mp.commandv('loadfile', history_list.list[history_list.selected].filePath, 'append-play')
    end
end

history_list.keybinds = {
    {'j', 'scroll_down', function() history_list:scroll_down() end, {repeatable = true}},
    {'k', 'scroll_up', function() history_list:scroll_up() end, {repeatable = true}},
    {'ENTER', 'history_open_file', history_open_file, {} },
    {'BS', 'history_open_file_timestamped', history_open_file_timestamped, {} },
    {'SHIFT+ENTER', 'history_open_file_append', history_open_file_append, {} },
    {'ESC', 'close_browser', function() history_list:close() end, {}}
}

local function read_history_log()
    only_this_file = false
    local copyLogAdd = io.open(history_path, 'r+')
    local history = {}
    local item, b1_ind, b2_ind, l1_ind, l2_ind
    local index = 1, maxind 
    for line in copyLogAdd:lines() do
        item = {} 
        b1_ind = line:find("%[")
        b2_ind = line:find("%]")
        l1_ind = line:find("|")
        l2_ind = line:find("|", l1_ind+1)

        item.date = string.sub(line, b1_ind+1, b2_ind-1)
        item.filePath = string.sub(line, b2_ind+2, l1_ind-2)
        item.timestamp = tonumber(string.sub(line, l1_ind+6, l2_ind-1))

        time_in_clockform = os.date('!%H:%M:%S', item.timestamp)
        --time_in_clockform = time_in_clockform:gsub("00:","", 2) -- trims leading 0s hours and mins
        --time_in_clockform = time_in_clockform:gsub("00:","", 1) -- trims leading 0s just hours
        date = string.sub(item.date, 11, 15) .. ' ' .. string.sub(item.date, 1, 9)
        if item.filePath:match('http') then 
            title = [[{\i1}]] .. string.sub(line, l2_ind+2) .. [[{\i0}]]  -- Skáletra netvideo
        else
            title = string.sub(line, l2_ind+2)
        end
        item.ass = '[' .. date ..  ', t=' .. time_in_clockform:sub(1,-1) .. '] ' .. title
        --item.style = [[{\c&H33ff66&}]]


        --filePath = string.match(line, "%][^|]*|")
        --filePath = string.sub(filePath, 3, -3)
        history[index] = item
        maxind = index 
        index = index + 1
    end
    copyLogAdd.close()
    return history, maxind
end 

local function read_history_log_only_this()
    local this_filePath = mp.get_property('path')
    if this_filePath == nil then return false end
    only_this_file = true
    local copyLogAdd = io.open(history_path, 'r+')
    local history = {}
    local item, b1_ind, b2_ind, l1_ind, l2_ind
    local index = 1, maxind 
    for line in copyLogAdd:lines() do
        item = {} 
        b1_ind = line:find("%[")
        b2_ind = line:find("%]")
        l1_ind = line:find("|")
        l2_ind = line:find("|", l1_ind+1)

        item.date = string.sub(line, b1_ind+1, b2_ind-1)
        item.filePath = string.sub(line, b2_ind+2, l1_ind-2)
        if this_filePath ~= item.filePath then goto continue end
        item.timestamp = tonumber(string.sub(line, l1_ind+6, l2_ind-1))

        time_in_clockform = os.date('!%H:%M:%S', item.timestamp)
        --time_in_clockform = time_in_clockform:gsub("00:","", 2) -- trims leading 0s hours and mins
        --time_in_clockform = time_in_clockform:gsub("00:","", 1) -- trims leading 0s just hours
        date = string.sub(item.date, 11, 15) .. ' ' .. string.sub(item.date, 1, 9)
        if item.filePath:match('http') then 
            title = [[{\i1}]] .. string.sub(line, l2_ind+2) .. [[{\i0}]]  -- Skáletra netvideo
        else
            title = string.sub(line, l2_ind+2)
        end
        item.ass = '[' .. date ..  ', t=' .. time_in_clockform:sub(1,-1) .. '] ' .. title
        --item.style = [[{\c&H33ff66&}]]


        --filePath = string.match(line, "%][^|]*|")
        --filePath = string.sub(filePath, 3, -3)
        history[index] = item
        maxind = index 
        index = index + 1
        ::continue::
    end
    copyLogAdd.close()
    return history, maxind
end 

local function make_list(only_this_file)
    history_list.header = "History \\N ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
    local historytable, history_length
    if only_this_file == 'only_this_file' then 
        historytable, history_length = read_history_log_only_this()
        if historytable == false then 
            historytable, history_length = read_history_log()
        end
    else 
        historytable, history_length = read_history_log()
    end

    history_list.list = {}
    local item
    for k, v in pairs(historytable) do 
        --item = {}
        --item.ass = v
        history_list.list[history_length + 1 - k] = v
    end
    history_list:update()
end

local function toggle_history()
    make_list()
    history_list:toggle()
end

local function toggle_history_this_file()
    make_list('only_this_file')
    history_list:toggle()
end


mp.add_key_binding(nil, "toggle-history", toggle_history)
mp.add_key_binding(nil, "toggle-history-this-file", toggle_history_this_file)
