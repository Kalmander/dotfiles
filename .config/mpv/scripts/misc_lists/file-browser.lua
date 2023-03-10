--[[
    mpv-file-browser

    This script allows users to browse and open files and folders entirely from within mpv.
    The script uses nothing outside the mpv API, so should work identically on all platforms.
    The browser can move up and down directories, start playing files and folders, or add them to the queue.

    For full documentation see: https://github.com/CogentRedTester/mpv-file-browser
]]--

local mp = require 'mp'
local msg = require 'mp.msg'
local utils = require 'mp.utils'
local opt = require 'mp.options'
local assdraw = require 'mp.assdraw'

package.path = mp.command_native( {"expand-path", "~~/scripts/miscellaneous_scripts/?.lua" } ) .. ";" .. package.path
package.path = mp.command_native( {"expand-path", "~~/scripts/?.lua" } ) .. ";" .. package.path

local o = {
    --root directories
    root = "~/",

    --number of entries to show on the screen at once
    num_entries = 20,

    --only show files compatible with mpv
    filter_files = true,

    --blacklist compatible files, it's recommended to use this rather than to edit the
    --compatible list directly. A semicolon separated list of extensions without spaces
    extension_blacklist = "",

    --add extra file extensions
    extension_whitelist = "",

    --filter dot directories like .config
    --only usefu on linux systems
    filter_dot_dirs = false,

    dvd_browser = false,

    --ass tags
    ass_header = "{\\q2\\fs35\\c&00ccff&}",
    ass_body = "{\\q2\\fs25\\c&Hffffff&}",
    ass_selected = "{\\c&Hfce788&}",
    ass_multiselect = "{\\c&Hfcad88&}",
    ass_playing = "{\\c&H33ff66&}",
    ass_footerheader = "{\\c&00ccff&\\fs16}",
    ass_cursor = "{\\c&00ccff&}",

    -- List of directories to reverse the order in:
    reversed_dirs = {[[videogamedunkey/$]], [[Elliot Brooks/$]]} 
}

opt.read_options(o, 'file_browser')

local ov = mp.create_osd_overlay('ass-events')
local bg_ov = mp.create_osd_overlay('ass-events')
local list = {}
local cache = {}
local extensions = nil
local state = {
    flag_update = false,
    directory = nil,
    hidden = true,
    selected = 1,
    selection = {},
    prev_directory = nil,
    current_file = {
        directory = nil,
        name = nil
    },
    dvd_device = nil
}
local root = nil
local filter = ''
local hide_dirs = false

local keybinds = {
    {'ENTER', 'open', function() open_file('replace') end, {}},
    {'Shift+ENTER', 'append_playlist', function() open_file('append') end, {}},
    {'ESC', 'exit', function() close_browser() end, {}},
    {'f', 'exit', function() close_browser() end, {}},
    {'RIGHT', 'down_dir', function() down_dir() end, {}},
    {'LEFT', 'up_dir', function() up_dir() end, {}},
    {'DOWN', 'scroll_down', function() scroll_down() end, {repeatable = true}},
    {'UP', 'scroll_up', function() scroll_up() end, {repeatable = true}},
    {'l', 'down_dirv', function() down_dir() end, {}},
    {'h', 'up_dirv', function() up_dir() end, {}},
    {'j', 'scroll_down_vim', function() scroll_down() end, {repeatable = true}},
    {'k', 'scroll_up_vim', function() scroll_up() end, {repeatable = true}},
    {'CTRL+RIGHT', 'scroll_down_large', function()
            for i = 1,10 do
                scroll_down()
            end
        end, {repeatable = true}},
    {'CTRL+LEFT', 'scroll_up_large', function()
            for i = 1,10 do
                scroll_up()
            end
        end, {repeatable = true}},
    {'CTRL+d', 'scroll_down_large_vim', function()
            for i = 1,10 do
                scroll_down()
            end
        end, {repeatable = true}},
    {'CTRL+u', 'scroll_up_large_vim', function()
            for i = 1,10 do
                scroll_up()
            end
        end, {repeatable = true}},
    {'c', 'pwd_c', function() cache = {}; goto_current_dir() end, {}},
    {'H', 'root_H', function() goto_root() end, {}},
    {'HOME', 'pwd', function() cache = {}; goto_current_dir() end, {}},
    {'Shift+HOME', 'root', function() goto_root() end, {}},
    {'Ctrl+r', 'reload', function() cache={}; update() end, {}},
    {'Ctrl+ENTER', 'select', function() toggle_selection() end, {}},
    {'Ctrl+DOWN', 'select_down', function() drag_down() end, {repeatable = true}},
    {'Ctrl+UP', 'select_up', function() drag_up() end, {repeatable = true}},
    -- {'Ctrl+RIGHT', 'select_yes', function() state.selection[state.selected] = true ; update_ass() end, {}},
    -- {'Ctrl+LEFT', 'select_no', function() state.selection[state.selected] = nil ; update_ass() end, {}},

    {'F', 'message_set_filter', function() message_set_filter() end, {}},
    {'d', 'hide_directories', function() hide_directories() end, {}},
    
}

--default list of compatible file extensions
--adding an item to this list is a valid request on github
local compatible_file_extensions = {
    "264","265","3g2","3ga","3ga2","3gp","3gp2","3gpp","3iv","a52","aac","adt","adts","ahn","aif","aifc","aiff","amr","ape","asf","au","avc","avi","awb","ay",
    "bmp","cue","divx","dts","dtshd","dts-hd","dv","dvr","dvr-ms","eac3","evo","evob","f4a","flac","flc","fli","flic","flv","gbs","gif","gxf","gym",
    "h264","h265","hdmov","hdv","hes","hevc","jpeg","jpg","kss","lpcm","m1a","m1v","m2a","m2t","m2ts","m2v","m3u","m3u8","m4a","m4v","mid","mk3d","mka","mkv",
    "mlp","mod","mov","mp1","mp2","mp2v","mp3","mp4","mp4v","mp4v","mpa","mpe","mpeg","mpeg2","mpeg4","mpg","mpg4","mpv","mpv2","mts","mtv","mxf","nsf",
    "nsfe","nsv","nut","oga","ogg","ogm","ogv","ogx","opus","pcm","pls","png","qt","ra","ram","rm","rmvb","sap","snd","spc","spx","svg","thd","thd+ac3",
    "tif","tiff","tod","trp","truehd","true-hd","ts","tsa","tsv","tta","tts","vfw","vgm","vgz","vob","vro","wav","weba","webm","webp","wm","wma","wmv","wtv",
    "wv","x264","x265","xvid","y4m","yuv"
}


local function fix_path(str, directory)
    str = str:gsub([[\]],[[/]])
    str = str:gsub([[/./]], [[/]])
    if directory and str:sub(-1) ~= '/' then str = str..'/' end
    return str
end

--updates the dvd_device
mp.observe_property('dvd-device', 'string', function(_, device)
    if device == "" then device = "/dev/dvd/" end
    state.dvd_device = fix_path(device, true)
end)

--sets up the compatible extensions list
local function setup_extensions_list()
    extensions = {}
    if not o.filter_files then return end

    --adding file extensions to the set
    for i=1, #compatible_file_extensions do
        extensions[compatible_file_extensions[i]] = true
    end

    --adding extra extensions on the whitelist
    for str in string.gmatch(o.extension_whitelist, "([^;]+)") do
        extensions[str] = true
    end

    --removing extensions that are in the blacklist
    for str in string.gmatch(o.extension_blacklist, "([^;]+)") do
        extensions[str] = nil
    end
end

------ TKJ Filter stuff -------------------------------------------------------------------
function set_filter(message)
    mp.command("script-binding console/_console_1") -- slekkur ?? console
    filter = message
    cache={}
    update()
end

function message_set_filter()
    mp.commandv('script-message-to', 'console', 'type', 'script-message filebrowser-set-filter ')
end
mp.register_script_message('filebrowser-set-filter',  set_filter)

function hide_directories()
    if hide_dirs then 
        hide_dirs = false 
    else
        hide_dirs = true 
    end
    cache={}
    update()
end

-- Nota ??etta a?? ne??an ??egar ??g applyja filternum
function case_insensitive_pattern(pattern)
    -- find an optional '%' (group 1) followed by any character (group 2)
    local p = pattern:gsub("(%%?)(.)", function(percent, letter)
      if percent ~= "" or not letter:match("%a") then
        -- if the '%' matched, or `letter` is not a letter, return "as is"
        return percent .. letter
      else
        -- else, return a case-insensitive character class of the matched letter
        return string.format("[%s%s]", letter:lower(), letter:upper())
      end
    end)
    return p
end
--------------------------------------------------------------------------------------------

--sorts the table lexicographically ignoring case and accounting for leading/non-leading zeroes
--the number format functionality was proposed by github user twophyro, and was presumably taken
--from here: http://notebook.kulchenko.com/algorithms/alphanumeric-natural-sorting-for-humans-in-lua
local function sort(t)
    local function padnum(d)
        local r = string.match(d, "0*(.+)")
        return ("%03d%s"):format(#r, r)
    end

    table.sort(t, function(a,b) return a:lower():gsub("%d+",padnum) < b:lower():gsub("%d+",padnum) end)
    return t
end

local function reversed_sort(t)
    local function padnum(d)
        local r = string.match(d, "0*(.+)")
        return ("%03d%s"):format(#r, r)
    end

    table.sort(t, function(a,b) return a:lower():gsub("%d+",padnum) > b:lower():gsub("%d+",padnum) end)
    return t
end

--splits the string into a table on the semicolons
local function setup_root()
    root = {}
    for str in string.gmatch(o.root, "([^;]+)") do
        local path = mp.command_native({'expand-path', str})
        path = fix_path(path, true)

        root[#root+1] = {name = path, type = 'dir', label = str}
    end
end

function update_current_directory(_, filepath)
    --if we're in idle mode then we want to open to the root
    if filepath == nil then 
        state.current_file.directory = ""
        return
    elseif filepath:find("dvd://") == 1 then
        filepath = state.dvd_device
    end

    local workingDirectory = mp.get_property('working-directory', '')
    local exact_path = utils.join_path(workingDirectory, filepath)
    exact_path = fix_path(exact_path, false)
    state.current_file.directory, state.current_file.name = utils.split_path(exact_path)
end

function goto_current_dir()
    --splits the directory and filename apart
    state.directory = state.current_file.directory
    state.selected = 1
    update()
end

function goto_root()
    if root == nil then setup_root() end
    msg.verbose('loading root')
    state.selected = 1
    list = root

    --if moving to root from one of the connected locations,
    --then select that location
    for i,item in ipairs(list) do
        if (state.prev_directory == item.name) then
            state.selected = i
            break
        end
    end
    state.prev_directory = ""
    state.directory = ""
    cache = {}
    state.selection = {}
    update_ass()
end

--prints the persistent header
function print_ass_header()
    local dir_name = state.directory
    if dir_name == "" then dir_name = "Home" end

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

    bg_ov.data = a.text
    ov.z = 1
    ov.data = o.ass_header..dir_name..'\\N ?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????? \\N'
end

--loops through the directory table and creates the ass string to generate the browser page
function update_ass()
    print_ass_header()
    --check for an empty directory
    if #list == 0 then
        ov.data = ov.data.."empty directory"
        ov:update()
        bg_ov:update()
        return
    end

    ov.data = ov.data..o.ass_body
    local start = 1
    local finish = start+o.num_entries-1

    --handling cursor positioning
    local mid = math.ceil(o.num_entries/2)+1
    if state.selected+mid > finish then
        local offset = state.selected - finish + mid

        --if we've overshot the end of the list then undo some of the offset
        if finish + offset > #list then
            offset = offset - ((finish+offset) - #list)
        end

        start = start + offset
        finish = finish + offset
    end

    --making sure that we don't overstep the boundaries
    if start < 1 then start = 1 end
    local overflow = finish < #list
    --this is necessary when the number of items in the dir is less than the max
    if not overflow then finish = #list end

    --adding a header to show there are items above in the list
    if start > 1 then ov.data = ov.data..o.ass_footerheader..(start-1)..' items above\\N\\N' end

    local current_dir = state.directory == state.current_file.directory

    for i=start,finish do
        local v = list[i]
        local playing_file = current_dir and v.name == state.current_file.name
        ov.data = ov.data..o.ass_body

        --handles custom styles for different entries
        if i == state.selected then ov.data = ov.data..o.ass_cursor..[[???\h]]..o.ass_body
        else ov.data = ov.data..[[\h\h\h\h]] end

        --prints the currently-playing icon and style
        if playing_file then ov.data = ov.data..o.ass_playing..[[???\h]] end

        --sets the selection colour scheme
        if state.selection[i] then ov.data = ov.data..o.ass_multiselect
        elseif i == state.selected then ov.data = ov.data..o.ass_selected end

        --sets the folder icon
        if v.type == 'dir' then ov.data = ov.data..[[????\h]] end

        --adds the actual name of the item
        if state.directory == "" then ov.data = ov.data..v.label.."\\N"
        else ov.data = ov.data..v.name.."\\N" end
    end

    ov.data = ov.data..'\\N'..o.ass_footerheader
    if (type(filter) == 'string') and (filter ~='') then 
        ov.data = ov.data .. '[Active filter: "' .. filter .. '"]  (press Shift+f to update filter)\\N'
    end 
    if hide_dirs then 
        ov.data = ov.data .. '[Directories hidden]  (press "d" to show)\\N'
    end
    if overflow then ov.data = ov.data..#list-finish..' items remaining' end
    ov:update()
    bg_ov:update()
end

--scans the current directory and updates the directory table
function update_list()
    msg.verbose('loading contents of ' .. state.directory)
    state.selected = 1
    state.selection = {}
    if extensions == nil then setup_extensions_list() end

    if o.dvd_browser then
        if state.directory == state.dvd_device then
            open_dvd_browser()
            list = {}
            return false
        end
    end

    --loads the current directry from the cache to save loading time
    --there will be a way to forcibly reload the current directory at some point
    --the cache is in the form of a stack, items are taken off the stack when the dir moves up
    if #cache > 0 then
        local cache = cache[#cache]
        if cache.directory == state.directory then
            msg.verbose('found directory in cache')
            list = cache.table

            --sets the cursor to the previously opened file and resets the prev_directory in
            --case we move above the cache source
            state.selected = cache.cursor
            state.prev_directory = state.directory
            return
        end
    end

    local t = mp.get_time()
    list = {}
    local list1 = utils.readdir(state.directory, 'dirs')

    --if we can't access the filesystem for the specified directory then we go to root page
    --this is cuased by either:
    --  a network file being streamed
    --  the user navigating above / on linux or the current drive root on windows
    if list1 == nil then
        goto_root()
        return
    end

    --sorts folders and formats them into the list of directories
    sort(list1)
    if not hide_dirs then 
        for i=1, #list1 do
            local item = list1[i]
            if (state.prev_directory == state.directory..item..'/') then state.selected = i end

            --filters hidden dot directories for linux
            if o.filter_dot_dirs and item:find('%.') == 1 then goto continue end

            msg.debug(item..'/')
            list[#list+1] = {name = item..'/', type = 'dir'}

            ::continue::
        end
    end

    -- tkj fram a?? for i=1, #list2 do var bara 
    -- sort(list2) en b??tti vi?? reverse sortinu
    local dir_name = state.directory
    local reverse_this_dir = false
    if o.reversed_dirs == nil then o.reversed_dirs = {} end
    for _, revdir in pairs(o.reversed_dirs) do
        if dir_name:match(revdir) then 
            reverse_this_dir = true 
        end 
    end
    --appends files to the list of directory items
    local list2 = utils.readdir(state.directory, 'files')
    if reverse_this_dir then 
        reversed_sort(list2)
    else
        sort(list2)
    end
    for i=1, #list2 do
        local item = list2[i]

        --only adds whitelisted files to the browser
        if o.filter_files then
            local index = item:find([[.[^.]*$]])
            if not index then goto continue end
            local fileext = item:sub(index + 1)
            if not extensions[fileext] then goto continue end
        end

        -- minn filter
        if (type(filter) == 'string') and (filter ~= '') then 
            local index = item:find(case_insensitive_pattern(filter))
            if not index then goto continue end
        end 

        msg.debug(item)
        list[#list+1] = {name = item, type = 'file'}

        ::continue::
    end
    msg.debug('load time: ' ..mp.get_time() - t)

    --saves the latest directory at the top of the stack
    cache[#cache+1] = {directory = state.directory, table = list}

    --once the directory has been successfully loaded we set it as the 'prev' directory for next time
    --this is for highlighting the previous folder when moving up a directory
    state.prev_directory = state.directory
end

function update()
    print_ass_header()
    ov:update()
    bg_ov:update()
    if update_list() == nil then
    update_ass() end
end

function scroll_down()
    if state.selected < #list then
        state.selected = state.selected + 1
        update_ass()
    end
end

function scroll_up()
    if state.selected > 1 then
        state.selected = state.selected - 1
        update_ass()
    end
end

function up_dir()
    local dir = state.directory:reverse()
    local index = dir:find("[/\\]")

    while index == 1 do
        dir = dir:sub(2)
        index = dir:find("[/\\]")
    end

    if index == nil then state.directory = ""
    else state.directory = dir:sub(index):reverse() end

    cache[#cache] = nil
    update()
end

function down_dir()
    if not list[state.selected] or list[state.selected].type ~= 'dir' then return end

    state.directory = state.directory..list[state.selected].name
    if #cache > 0 then cache[#cache].cursor = state.selected end
    update()
end

function toggle_selection()
    if list[state.selected] then
        if state.selection[state.selected] then
            state.selection[state.selected] = nil
        else
            state.selection[state.selected] = true
        end
    end
    update_ass()
end

function drag_down()
    state.selection[state.selected] = true
    scroll_down()
    state.selection[state.selected] = true
    update_ass()
end

function drag_up()
    state.selection[state.selected] = true
    scroll_up()
    state.selection[state.selected] = true
    update_ass()
end

function open_browser()
    for _,v in ipairs(keybinds) do
        mp.add_forced_key_binding(v[1], 'dynamic/'..v[2], v[3], v[4])
    end

    state.hidden = false

    if state.directory == nil then
        update_current_directory(nil, mp.get_property('path'))
        goto_current_dir()
        return
    end

    if state.flag_update then
        update_current_directory(nil, mp.get_property('path'))
        update_ass()
    else ov:update() end
end

--sortes a table into an array of its key values
local function sort_keys(t)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    table.sort(keys)
    return keys
end

function close_browser()
    --if multiple items are selection cancel the
    --selection instead of closing the browser
    if next(state.selection) then
        state.selection = {}
        update_ass()
        return
    end

    for _,v in ipairs(keybinds) do
        mp.remove_key_binding('dynamic/'..v[2])
    end
    state.hidden = true
    ov:remove()
    bg_ov:remove()
end

--runs the loadfile or loadlist command
local function loadfile(item, flags)
    local path = state.directory..item.name
    if (path == state.dvd_device) then path = "dvd://"
    elseif item.type == "dir" then return mp.commandv('loadlist', path, flags) end
    return mp.commandv('loadfile', path, flags)
end

--opens the selelected file(s)
function open_file(flags)
    if state.selected > #list or state.selected < 1 then return end

    loadfile(list[state.selected], flags)
    state.selection[state.selected] = nil

    --handles multi-selection behaviour
    if next(state.selection) then
        local selection = sort_keys(state.selection)

        --the currently selected file will be loaded according to the flag
        --the remaining files will be appended
        for i=1, #selection do
            loadfile(list[selection[i]], "append")
        end

        --reset the selection after
        state.selection = {}
        if flags == 'replace' then 
            close_browser()
        else update_ass() end
        return

    elseif flags == 'replace' then
        down_dir()
        close_browser()
    end
end


function toggle_browser()
    --if we're in the dvd-device then pass the request on to dvd-browser

    if o.dvd_browser and state.directory == state.dvd_device then
        mp.commandv('script-message-to', 'dvd_browser', 'dvd-browser')
    elseif state.hidden then
        open_browser()
    else
        close_browser()
    end
end

function open_dvd_browser()
    state.prev_directory = state.dvd_device
    close_browser()
    mp.commandv('script-message', 'browse-dvd')
end

--we don't want to add any overhead when the browser isn't open
mp.observe_property('path', 'string', function(_,path)
    if not state.hidden then 
        update_current_directory(_,path)
        update_ass()
    else state.flag_update = true end
end)
mp.add_key_binding(nil,'browse-files', toggle_browser)

--opens the root directory
mp.register_script_message('goto-root-directory',function()
    goto_root()
    open_browser()
end)

mp.register_script_message('goto-current-directory', function()
    goto_current_dir()
    open_browser()
end)

--allows keybinds/other scripts to auto-open specific directories
mp.register_script_message('browse-directory', function(directory)
    --msg.verbose('recieved directory from script message: '..directory)

    state.directory = directory
    cache = {}
    update()
    open_browser()
end)
