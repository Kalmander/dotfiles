local lists_dir = mp.command_native( {"expand-path", "~~/scripts/misc_lists/?.lua" } )
package.path = lists_dir .. ";" .. package.path
local list_maker = require "scroll-list"
local bookmarks_list = list_maker()
local utils = require("mp.utils")
local bookmarks_path = mp.command_native({"expand-path", "~~/mpvBookmarks.log"})


---- List ----------------------------------------------------------------------------------------
local function bookmarks_open_file()
    selected_bookmark = bookmarks_list.list[bookmarks_list.selected]
    if selected_bookmark then
        mp.commandv('loadfile', selected_bookmark.filePath, 'replace', 'start=' .. selected_bookmark.timestamp)
        bookmarks_list:close()
    end
end

bookmarks_list.keybinds = {
    {'DOWN', 'scroll_down', function() bookmarks_list:scroll_down() end, {repeatable = true}},
    {'UP', 'scroll_up', function() bookmarks_list:scroll_up() end, {repeatable = true}},
    {'ENTER', 'bookmarks_open_file', bookmarks_open_file, {} },
    {'ESC', 'close_browser', function() bookmarks_list:close() end, {}}
}

local function read_bookmarks_log()
    local copyLogAdd = io.open(bookmarks_path, 'r+')
    local bookmarks = {}
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
            title = [[{\i1}]] .. string.sub(line, l2_ind+2, #line-1) .. [[{\i0}]]  -- Skáletra netvideo
        else
            title = string.sub(line, l2_ind+2, #line-1)
        end
        item.ass = '[' .. date ..  ', t=' .. time_in_clockform:sub(1,-1) .. '] ' .. title
        --item.style = [[{\c&H33ff66&}]]


        --filePath = string.match(line, "%][^|]*|")
        --filePath = string.sub(filePath, 3, -3)
        bookmarks[index] = item
        maxind = index 
        index = index + 1
    end
    copyLogAdd.close()
    return bookmarks, maxind
end 

local function make_bookmarkslist()
    bookmarks_list.header = "Bookmarks \\N ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
    local bookmarkstable, bookmarks_length
    bookmarkstable, bookmarks_length = read_bookmarks_log()

    bookmarks_list.list = {}
    local item
    for k, v in pairs(bookmarkstable) do 
        --item = {}
        --item.ass = v
        bookmarks_list.list[bookmarks_length + 1 - k] = v
    end
    bookmarks_list:update()
end

local function toggle_bookmarks()
    make_bookmarkslist()
    bookmarks_list:toggle()
end
---- List ends -----------------------------------------------------------------------------------


---- Record --------------------------------------------------------------------------------------
local function add_to_bookmarks_log()
    local filePath = mp.get_property('path')
    local title =  mp.get_property('media-title')
    local bookmarksLogAdd = io.open(bookmarks_path, 'a+')
    local time_pos = mp.get_property_native('time-pos')
    if type(time_pos) ~= "number" then return end
    local seconds = math.floor(time_pos)
    if (filePath ~= nil) then
        bookmarksLogAdd:write(('[%s] %s\n'):format(os.date('%d/%b/%y %X'), filePath..' |time='..tostring    (seconds) .. '| ' .. title))
        bookmarksLogAdd:close()
    end
    local confirmation_message = 'Bookmarked ' .. title .. ' at ' .. os.date('!%H:%M:%S', seconds)
    print(confirmation_message)
    mp.osd_message(confirmation_message, 4)
end 
---- Record ends ---------------------------------------------------------------------------------


mp.add_key_binding(nil, "toggle-bookmarks", toggle_bookmarks)
mp.add_key_binding(nil, 'create-bookmark-timestamped', add_to_bookmarks_log)
