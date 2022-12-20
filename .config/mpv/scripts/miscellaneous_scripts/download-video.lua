local utils = require 'mp.utils'
local open_directory = true
local youtube_playlist_url = nil
local ON_WINDOWS = (package.config:sub(1,1) ~= '/')

local videos_path
if ON_WINDOWS then 
    videos_path = 'A:/youtube'
else
    videos_path = 'VANTAR LINUX PATH'
end

local function fix_url(VideoURL)
    local VideoURLModded = VideoURL

    if string.match(VideoURLModded, "&list=") then 
        s, e = string.find(VideoURLModded, "&list=")
        VideoURLModded = string.sub(VideoURLModded, 1, s-1) 
    end 
    if string.match(VideoURLModded, "youtu.be") then 
        s, e = string.find(VideoURLModded, "youtu.be")
        VideoURLModded = string.sub(VideoURLModded, 1, s-1) .. "youtube.com/watch?v=" .. string.sub(VideoURLModded, e+2, -1) 
    end

    return VideoURLModded
end


local function download_video()
    mp.osd_message('Attempting to download video...', 4)
    videoUrl = fix_url(mp.get_property('path'))
    timestamp = os.date('%Y%m%d%H%M%S')
    cmds = {
        'yt-dlp', 
        '-o', videos_path .. '/%(title)s [%(uploader)s].%(ext)s', 
        '-o', 'thumbnail:' .. videos_path .. '/.metadata/thumbnails/%(id)s_' .. timestamp,
        '-o', 'infojson:' .. videos_path .. '/.metadata/infojsons/%(id)s_' .. timestamp,
        '--embed-metadata',
        '--embed-subs',
        '--embed-chapters',
        "--write-info-json",
        '--write-comments',
        '--write-thumbnail',
        '--sponsorblock-mark', 'sponsor', 
        '--extractor-args', 'youtube:comment_sort=top;max_comments=100',
        '--exec', 'echo Output name is ###{}###',
        videoUrl
    }
    res = mp.command_native({name = "subprocess", args = cmds})

    print('Results of downloading video ' .. videoUrl .. ' are: ')
    for k,v in pairs(res) do 
        print(k, v)
    end
end


local function open_new_video(message)
    local path = string.match(message, [[Output name is ###"(.*)"###]])
    if (path ~= nil) and open_directory then

        args = {'mpv'}
        if mp.get_property('pause') == 'yes' then 
             table.insert(args, '--pause')
        end
        if mp.get_property('fullscreen') == 'yes' then 
            table.insert(args, '--fs')
        end
        pos = tostring(mp.get_property_number('time-pos') + 0.6)
        table.insert(args, '--start=' .. pos)
        table.insert(args, '--window-scale=' .. mp.get_property('current-window-scale'))
        table.insert(args, '--script-opts=misc-print_local_notification=yes')
        table.insert(args, '--playlist-start=' .. mp.get_property('playlist-pos'))
        table.insert(args, path)

        mp.command_native({
            name = "subprocess", 
            args = args, 
            detach = true
        })

        mp.add_timeout(0.7, function()
            mp.command('quit')
        end)
    end
end
mp.register_script_message('ytdlp-output-name', open_new_video)

-- GERA ANNAÐ FYRIR BARA AUDIO, KANNSKI LÍKA Í BROWSER
-- HMM KANNSKI EKKIS AMT OG CONVERTA BARA HMMM............

local function get_youtube_playlist_name(URL)
    args  =  {"yt-dlp",  "--get-filename",  "-o",  "'%(playlist_title)s'",  "--playlist-items",  "1",  URL}
    command_native_output  =  mp.command_native({
            name  =  "subprocess",
            capture_stdout  =  true,
            args  =  args
    })
    playlist_name = command_native_output['stdout']:sub(1,  -2)  --  tekur auka / sem við viljum ekki
    playlist_name = playlist_name:gsub("'", "")
    return playlist_name
end

local function download_yturl_playlist(url, a, b)
    cmds = {
        'yt-dlp', 
        '-o', videos_path .. '/.playlists/%(playlist)s/%(playlist_index)s. %(title)s [%(uploader)s].%(ext)s', 
        '--embed-metadata',
        '--embed-subs',
        '--embed-chapters',
        '--sponsorblock-mark', 'sponsor', 
        youtube_playlist_url
    }
    if (a ~= nil) and (b ~= nil) then 
        table.insert(cmds, '--playlist-start')
        table.insert(cmds, tostring(a))
        table.insert(cmds, '--playlist-end')
        table.insert(cmds, tostring(b))
    end
    res = mp.command_native({name = "subprocess", args = cmds})
    playlist_name = get_youtube_playlist_name(url)
    playlist_dir_path = utils.join_path(videos_path,  playlist_name)
    return playlist_dir_path
end

local function make_directory(path)
    cmds = {'powershell', '-NoProfile', 'mkdir', path}
    res = mp.command_native({name = "subprocess", args = cmds})
end


local function delete_file(path)
    -- Þetta var skringilega mikið vesen að fá til að virka
    -- Gat ekki notað powershell til að eyða skjali á external drive
    -- Til að nota command prompt þarf /k switchið eins og sést hér
    -- Í command prompt þarf pathið að vera á nákvæmlega þessu formatti:
    --      með einföldum "\" og ekki með "" utan um
    path_fixed = path:gsub('/', '\\')
    cmds = {'cmd', '/k', 'del', '/f', path_fixed}
    res = mp.command_native({name = "subprocess", args = cmds})
end


local function make_batch_file(list_path, a, b)
    if (a == nil) then 
        a = 0
    else
        a = a - 1
    end

    if (b == nil) or (b == 'last') then 
        b = mp.get_property_number('playlist-count')
    end

    list_path_info = utils.file_info(list_path)
    if list_path_info ~= nil then
        if list_path_info.is_file then 
            print('Already exists!')
            mp.osd_message("Already exists!",  4)
            return 
        end
    end

    local file, err = io.open(list_path, "w")
    if not file then
        msg.error("Error in creating playlist file, check permissions. Error: "..(err  or  "unknown"))
    else
        local i = a
        while i < b do
            local filename = mp.get_property('playlist/'..i..'/filename')
            file:write(filename, "\n")
            i=i+1
        end
        file:close()
    end
end


local function download_current_mpv_playlist(a, b)
    local date  =  os.date("*t")
    local datestring  =  ("[%02d.%02d.%02d_%02d.%02d.%02d]"):format(date.year,  date.month,  date.day,  date.hour,  date.min,  date.sec)
    local playlist_name = "mpvplaylist_" .. datestring
    local playlist_dir_path = utils.join_path(utils.join_path(videos_path,  '.playlists'), playlist_name)
    local list_path  =  utils.join_path(playlist_dir_path,  playlist_name .. ".txt")

    make_directory(playlist_dir_path)
    make_batch_file(list_path, a, b)

    cmds = {
        'yt-dlp', 
        '-o', playlist_dir_path .. '/%(autonumber)s. %(title)s [%(uploader)s].%(ext)s',  -- 
        '--embed-metadata',
        '--embed-subs',
        '--embed-chapters',
        '--sponsorblock-mark', 'sponsor', 
        '--batch-file',
        list_path
    }
    if (a ~= nil) and (b ~= nil) then 
         table.insert(cmds, '--autonumber-start')
         table.insert(cmds, tostring(a))
    end
    res = mp.command_native({name = "subprocess", args = cmds})

    delete_file(list_path)
    return
end

local function download_playlist()
    mp.osd_message('Attempting to download playlist...', 4)
    if  youtube_playlist_url  ~=  nil  then  
        playlist_path = download_yturl_playlist(youtube_playlist_url)
    else
        playlist_path = download_current_mpv_playlist()
    end
    open_new_video([[Output name is ###"]] .. playlist_path .. [["###]])    
end


local function download_playlist_entires(a, b)
    a = tonumber(a)
    if (b ~= 'last') then
        b = tonumber(b)
    end

    if (a == nil) or (b == nil) then 
        print('download_playlist_entries: Input must be two numbers in increasing order')
        print('download_playlist_entries: (except the latter number may be replaced by the string "last")')
        return 
    end

    if (b ~= 'last') and (b < a) then 
        print('download_playlist_entries: Specify the entries in increasing order')
        print('download_playlist_entries: ' .. tostring(a) .. ' > ' .. tostring(b))
        return 
    end

    mp.osd_message('Attempting to download playlist entries ' .. tostring(a) .. ' to ' .. tostring(b) .. '...', 4)
    print('Attempting to download playlist entries ' .. tostring(a) .. ' to ' .. tostring(b))
    if  youtube_playlist_url  ~=  nil  then  
        download_yturl_playlist(youtube_playlist_url, a, b)
    else
        download_current_mpv_playlist(a, b)
    end

    mp.osd_message('Downloading playlist entries ' .. tostring(a) .. ' to ' .. tostring(b) .. ' completed.', 4)
    print('Downloading playlist entries ' .. tostring(a) .. ' to ' .. tostring(b) .. ' completed.')
end
mp.register_script_message('download-playlist-entries', download_playlist_entires)


local function download_video_portion(a, b)
    -- download video only from a to b
    -- a and b may be specified either as 
    -- seconds or as timestamps eg 00:00:10.00 (ffmpeg notation)
    mp.osd_message('Attempting to download video portion from t=' .. a .. ' to t=' .. b, 4)
    print('Attempting to download video portion from t=' .. a .. ' to t=' .. b)
    videoUrl = fix_url(mp.get_property('path'))

    cmds = {
        'yt-dlp', 
        '-o', videos_path .. '/%(title)s [%(uploader)s][' .. a .. '-' .. b .. '].%(ext)s', 
        '--embed-metadata',
        '--embed-subs',
        '--embed-chapters',
        '--sponsorblock-mark', 'sponsor', 
        '--external-downloader', 'ffmpeg',
        '--external-downloader-args', '-ss ' .. a .. ' -to ' .. b,
        videoUrl
    }
    res = mp.command_native({name = "subprocess", args = cmds})

    print('Results of downloading video portion ' .. videoUrl .. ' from t=' .. a .. ' to t=' .. b .. ' are : ')
    for k,v in pairs(res) do 
        print(k, v)
    end
end
mp.register_script_message('download-video-portion', download_video_portion)


local function set_playlist_url(url)
    youtube_playlist_url  =  url
end
mp.register_script_message('downloader-youtube-playlist-url',  set_playlist_url)

mp.add_key_binding(nil, "download-video", download_video)
mp.add_key_binding(nil, "download-playlist", download_playlist)
mp.add_key_binding(nil, "download-playlist-entries-shortcut", function()
   mp.commandv('script-message-to', 'console', 'type', 'script-message download-playlist-entries ')
end)
mp.add_key_binding(nil, "download-video-portion-shortcut", function()
    mp.commandv('script-message-to', 'console', 'type', 'script-message download-video-portion ')
 end)
 