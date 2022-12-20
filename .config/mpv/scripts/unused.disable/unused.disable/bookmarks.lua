local utils = require 'mp.utils'
local script_dir =  mp.command_native( {"expand-path", "~~exe_dir/scripts" } )
local historyBookmarksDir = utils.join_path(script_dir, "../../bookmarks/")

local exe_dir = mp.command_native({"expand-path", "~~exe_dir/"}) 
local exe_path = utils.join_path(exe_dir, 'mpv.exe')
local icon_path = utils.join_path(exe_dir, '../misc/youtube.ico')


local function get_media_title(filePath)
	if string.match(filePath, "http") then
		media_title = mp.get_property('media-title')
	else
		media_title = mp.get_property('filename/no-ext')
	end
	media_title = media_title:gsub(':', '-')
	media_title = media_title:gsub([["]],[[]])
	media_title = media_title:gsub([[']],[[]])
	media_title = media_title:gsub('/', '')
	media_title = media_title:gsub('\\', '')
	media_title = media_title:gsub(':', '')
	media_title = media_title:gsub('*', '')
	media_title = media_title:gsub('?', '')
	media_title = media_title:gsub('>', '')
	media_title = media_title:gsub('<', '')
	media_title = media_title:gsub('|', '')
    return media_title
end


local function save_shortcut(with_timestamp)
	local commands
	local ps = io.popen("powershell -NoProfile -command -", "w")
	local filePath = mp.get_property('path')
	local media_title, playback_time

    if with_timestamp then 
        mp.osd_message('Bookmarked with a timestamp')
    else
        mp.osd_message('Bookmarked (no timestamp)')
    end

    media_title = get_media_title(filePath)
    if with_timestamp then 
        playback_time = math.floor(mp.get_property_number('time-pos'))
        if type(playback_time) == nil then 
            playback_time = 0
        end
    end

    commands = [[$ws = New-Object -ComObject WScript.Shell]]
    if with_timestamp then 
        commands = commands .. [[;$s = $ws.CreateShortcut(']] .. historyBookmarksDir .. media_title .. [[ (]] .. playback_time ..  [[s).lnk')]]
    else
        commands = commands .. [[;$s = $ws.CreateShortcut(']] .. historyBookmarksDir .. media_title .. [[.lnk')]]
    end
    commands = commands .. [[;$s.TargetPath = ']] .. exe_path .. [[']]
    if with_timestamp then 
        commands = commands .. [[;$s.Arguments = '"]] .. filePath ..[[" --start=]] .. tostring(playback_time) .. [[']]
    else
        commands = commands .. [[;$s.Arguments = '"]] .. filePath ..[[" --start=0']]
    end
	if string.match(filePath, "http") then
		commands = commands .. [[;$s.IconLocation = "]] .. icon_path .. [["]]
	end
	commands = commands .. [[;$s.Save()]]
	
	ps:write(commands)
	ps:close()
end


mp.add_key_binding(nil, 'create-bookmark-timestamped', function() save_shortcut(true) end)
mp.add_key_binding(nil, 'create-bookmark-no-timestamp', function() save_shortcut(false) end)
