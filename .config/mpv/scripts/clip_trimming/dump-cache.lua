ON_WINDOWS = (package.config:sub(1,1) ~= '/')
local clips_dir
if ON_WINDOWS then
    clips_dir = mp.command_native({"expand-path", "~~exe_dir/clips/"})
else
    clips_dir = mp.command_native({"expand-path", "~~/clips/"})
end 
local startPosition, endPosition

local function mark_start()
    startPosition = mp.get_property_number('time-pos')
    startPosFormatted = os.date('!%H:%M:%S', startPosition)
    startPosFormatted = startPosFormatted:gsub("00:","", 1) -- trims leading 0s just hours
    startPosFormatted = startPosFormatted:gsub(':', '.')

    mp.osd_message('dump-cache start marked at ' .. startPosFormatted, 6)
end

local function mark_end()
    endPosition = mp.get_property_number('time-pos')
    endPosFormatted = os.date('!%H:%M:%S', endPosition)
    endPosFormatted = endPosFormatted:gsub("00:","", 1) -- trims leading 0s just hours
    endPosFormatted = endPosFormatted:gsub(':', '.')

    mp.osd_message('dump-cache end marked at ' .. endPosFormatted, 6)
end 

local function dump_cache_using_marks()
    if type(startPosition) ~= "number" then 
        mp.osd_message('You must specify a start location to do that!')
        return
    elseif type(endPosition) ~= "number" then 
        mp.osd_message('You must specify an end location to do that!')
        return
    else

        media_title =  mp.get_property('media-title')
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
    
        local ext 
        if mp.get_property('file-format') == 'hls' then 
            ext = '.ts'
        else
            ext = '.mp4' -- Mætti bæta þetta
        end

        local time_marker = '[' .. startPosFormatted .. ' -- ' .. endPosFormatted .. ']'
        filePath = clips_dir .. media_title .. ' ' .. time_marker .. ext
        
        mp.commandv('dump-cache', startPosition, endPosition, filePath)

        mp.osd_message('Dumped cache from ' .. startPosFormatted .. ' to ' .. endPosFormatted .. ' to file ' .. filePath, 8)
    end
end 

local function dump_entire_cache()
    media_title =  mp.get_property('media-title')
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

    local ext 
    if mp.get_property('file-format') == 'hls' then 
        ext = '.ts'
    else
        ext = '.mp4' -- Mætti bæta þetta
    end


    demux_cache_state = mp.get_property_native('demuxer-cache-state')
    for k, ranges in pairs(demux_cache_state['seekable-ranges']) do 
        cacheStart = math.ceil(ranges['start'])
        cacheEnd = math.floor(ranges['end'])


        local time_marker = '[' .. tostring(cacheStart) .. ' -- ' .. tostring(cacheEnd) .. ']'
        filePath = clips_dir .. media_title .. ' ' .. time_marker .. ext
        
        mp.commandv('dump-cache', cacheStart, cacheEnd, filePath)

        mp.osd_message('Dumped cache from to file ' .. filePath)
    end
end 


mp.add_key_binding(nil, 'mark-dump-cache-start', mark_start)
mp.add_key_binding(nil, 'mark-dump-cache-end', mark_end)
mp.add_key_binding(nil, 'dump-cache-using-marks', dump_cache_using_marks)
mp.add_key_binding(nil, 'dump-entire-cache', dump_entire_cache)
