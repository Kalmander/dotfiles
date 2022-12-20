local misc_script = mp.command_native({"expand-path", "~~/scripts/miscellaneous_scripts/miscellaneous.lua"})
package.path = misc_script .. ";" .. package.path
local misc = require 'miscellaneous.lua'
local utils = require 'mp.utils'

local historyLog = mp.command_native({"expand-path", "~~/mpvHistory.log"})
local playlistHistoryLog = mp.command_native({"expand-path", "~~/mpvPlaylistHistory.log"})

local offset = -5
local lastM3u
local currentlyPlayingPlaylist = false
local justLoadedM3u = false
local lastFolder, lastM3u

local function add_to_history_log()
    local filePath = mp.get_property('path')
    local title =  mp.get_property('media-title')
    local historyLogAdd = io.open(historyLog, 'a+')
    local time_pos = mp.get_property_native('time-pos')
    if type(time_pos) ~= "number" then return end
    local seconds = math.floor(time_pos)
    if (filePath ~= nil) then
        historyLogAdd:write(('[%s] %s\n'):format(os.date('%d/%b/%y %X'), filePath..' |time='..tostring    (seconds) .. '| ' .. title))
        historyLogAdd:close()

        if currentlyPlayingPlaylist then
            lastFolder, _ = utils.split_path(filePath)

            if (lastM3u ~= nil) and (lastM3u:match('AppData\\Local\\Temp\\') == nil) then 
                historyLogAdd = io.open(playlistHistoryLog, 'a+')
                --entry = mp.get_property('playlist-pos') -- ef þú ert alveg að klára skjal getur þetta verið næsta skjal á     playlistanum
                entry = mp.get_property('playlist-playing-pos')
                historyLogAdd:write(('[%s] %s\n'):format(os.date('%d/%b/%y %X'), lastM3u .. ' |pos=' .. entry .. ' |time='..    tostring(seconds) .. ' |title=' .. title))
                historyLogAdd:close()
            elseif (lastFolder ~= nil) and ((lastFolder:lower():match('tv show') ~= nil) or (lastFolder:lower():match('þættir') ~= nil)) then
                historyLogAdd = io.open(playlistHistoryLog, 'a+')
                entry = mp.get_property('playlist-playing-pos')
                historyLogAdd:write(('[%s] %s\n'):format(os.date('%d/%b/%y %X'), lastFolder .. ' |pos=' .. entry .. ' |time='..    tostring(seconds) .. ' |title=' .. title))
                historyLogAdd:close()
            end
        end
    end
end 

local function resume()
    local historyLogOpen = io.open(historyLog, 'r')
    local historyLogAdd = io.open(historyLog, 'a+')
    local filePath = mp.get_property('path')
    local linePosition
    local videoFound
    local currentVideo
    local currentVideoTime
    local seekTime

    if (filePath ~= nil) then
        for line in historyLogOpen:lines() do
        
            linePosition = line:find(']')
            line = line:sub(linePosition + 2)
            
            if line.match(line, '(.*) |time=') == filePath then
                videoFound = line
            end
        end
    
    if (videoFound ~= nil) then
        currentVideo = string.match(videoFound, '(.*) |time=')
        currentVideoTime = string.match(videoFound, ' |time=(.*)|')
        if currentVideoTime:match('|') ~= nil then 
            loc = currentVideoTime:find('|')
            currentVideoTime = currentVideoTime:sub(1, loc-1)
        end
        
        if (filePath == currentVideo) and (currentVideoTime ~= nil) then
        
            seekTime = currentVideoTime + offset
            if (seekTime < 0) then
                seekTime = 0
            end
        
            mp.commandv('seek', seekTime, 'absolute', 'exact')
            mp.osd_message('Resumed Last Position')
        end
    else
        mp.osd_message('No Resume Position')
    end
    else
        empty = true
        lastPlay()
    end
    historyLogAdd:close()
    historyLogOpen:close()
end

function lastPlay()
    local historyLogAdd = io.open(historyLog, 'a+')
    local historyLogOpen = io.open(historyLog, 'r+')
    local linePosition
    local videoFile
    local lastVideoFound

    for line in historyLogOpen:lines() do
        lastVideoFound = line
    end
    historyLogAdd:close()
    historyLogOpen:close()

    if (lastVideoFound ~= nil) then
        linePosition = lastVideoFound:find(']')
        lastVideoFound = lastVideoFound:sub(linePosition + 2)
        
        if string.match(lastVideoFound, '(.*) |time=') then
            videoFile = string.match(lastVideoFound, '(.*) |time=')
            --_, lastVideoTime = string.match(lastVideoFound, '(|time=)([^|]*)')
            VideoTime = string.match(lastVideoFound, ' |time=(.*)|')
            if VideoTime:match('|') ~= nil then 
                loc = VideoTime:find('|')
                VideoTime = VideoTime:sub(1, loc-1)
            end
        
        else
            videoFile = lastVideoFound
        end
        
        if (filePath ~= nil) then
            mp.osd_message('Added Last Item Into Playlist:\n'..videoFile)
            mp.commandv('loadfile', videoFile, 'append-play')
        else
            if (empty == false) then
                mp.osd_message('Loaded Last Item:\n'..videoFile)
            else 
                mp.osd_message('Resumed Last Item:\n'..videoFile)
            end
            if VideoTime == nil then 
                mp.commandv('loadfile', videoFile)
            else
                mp.commandv('loadfile', videoFile, 'replace', 'start=' .. VideoTime)
            end
        end
    else
        mp.osd_message('History is Empty')
    end
end

local skipping_already_done = false
local function skip_after_timeout_if_possible(timeout, timestamp)
    mp.add_timeout(timeout, function() 
            if (mp.get_property_number('time-pos') == nil) then return end
            if skipping_already_done then return end
            mp.commandv('seek', timestamp, 'absolute', 'exact') 
            skipping_already_done = true
    end)
end

function lastPlayPlaylist()
    local historyLogAdd = io.open(playlistHistoryLog, 'a+')
    local historyLogOpen = io.open(playlistHistoryLog, 'r+')
    local linePosition
    local videoFile
    local lastVideoFound 

    for line in historyLogOpen:lines() do
        lastVideoFound = line
    end
    historyLogAdd:close()
    historyLogOpen:close()

    if (lastVideoFound == nil) then
        mp.osd_message('History is Empty')
        return
    end

    local filePath = lastVideoFound:match('%] (.*) |pos=')
    local vidTitle = lastVideoFound:match(' |title=(.*)')
    local pos = tonumber(lastVideoFound:match('|pos=(.*) |time='))
    local timestamp = tonumber(lastVideoFound:match('|time=(.*) |title='))
    local time_in_clockform = os.date('!%H:%M:%S', timestamp)
    local playlist_name
    _, playlist_name = utils.split_path(filePath)

    if (filePath ~= nil) then
        local osd_msg = 'Opened:\n'
        osd_msg = osd_msg .. playlist_name .. '\n'
        osd_msg = osd_msg .. 'at pos=' .. pos .. ' and t=' .. time_in_clockform .. '\n'
        osd_msg = osd_msg .. vidTitle
        mp.osd_message(osd_msg, 7)
        mp.command_native({
            name='loadfile', 
            url=filePath, 
            options='playlist-start=' .. tostring(pos)
        })
        -- Þó það virkar að keyra td "mpv FILEPATH.m3u --playlist-start=4,start=400" þá virðist þetta
        -- ekki virka með loadfile því miður (sér í lagi start), þetta workaround virðist virka:
        if timestamp > 10 then -- óþarfi ef videoið var varla byrjað síðast
            skip_after_timeout_if_possible(3.0, timestamp)
            skip_after_timeout_if_possible(3.5, timestamp)
            skip_after_timeout_if_possible(4.0, timestamp)
            skip_after_timeout_if_possible(4.5, timestamp)
            skip_after_timeout_if_possible(5.0, timestamp)
            skip_after_timeout_if_possible(5.5, timestamp)
            skip_after_timeout_if_possible(6.0, timestamp)
            skip_after_timeout_if_possible(6.5, timestamp)
            skip_after_timeout_if_possible(7.0, timestamp)
            skip_after_timeout_if_possible(7.5, timestamp)
            skip_after_timeout_if_possible(8.0, timestamp)
            skip_after_timeout_if_possible(8.5, timestamp)
            skip_after_timeout_if_possible(9.0, timestamp)
            skip_after_timeout_if_possible(9.5, timestamp)
            mp.add_timeout(12, function() skipping_already_done = false end) -- resetta skipping already done
        end

    end

end

local function set_playlist_currently_playing(property_name, second_playlist_entry)
    if second_playlist_entry == nil then 
        currentlyPlayingPlaylist = false
        lastM3u = nil
        return
    end
    currentlyPlayingPlaylist = true

    if justLoadedM3u then 
        justLoadedM3u = false
        -- maybe do something else? 
    elseif lastM3u ~= nil then 
        lastM3u = nil -- if new playlist loaded then clear lastM3u
    end 
end

local function handle_m3u()
    local loaded_file = mp.get_property('path')
    if loaded_file == nil then return end
    ext = misc.GetFileExtension(loaded_file)
    if (ext ~= '.m3u') and (ext ~= '.m3u8') then return end
    lastM3u = loaded_file
    justLoadedM3u = true
end

---------------------------KEYBINDS CUSTOMIZATION SETTINGS---------------------------------
mp.add_hook('on_unload', 50, add_to_history_log)
mp.add_key_binding(nil, "resume-from-history", resume)
mp.add_key_binding(nil, "open-lastPlayed-from-playlist-history", lastPlayPlaylist)
mp.add_key_binding(nil, "open-lastPlayed-from-history", lastPlay)
mp.register_event('start-file', handle_m3u)
mp.observe_property('playlist/2/filename', 'string', set_playlist_currently_playing)