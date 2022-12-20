local misc_scripts = mp.command_native( {"expand-path", "~~exe_dir/scripts/miscellaneous_scripts" } )
package.path = misc_scripts .. "/?.lua;" .. package.path
local utils = require("mp.utils")
local misc = require "miscellaneous"
local custom_chap_counter = 0

local function find_chapter_at(time)
    local all_chapters = mp.get_property_native("chapter-list")
    local time_pos = mp.get_property_number("time-pos")
    local last_chapter = 1 
    for curr, chapter in pairs(all_chapters) do 
        curr_time = chapter['time']
        curr_title = chapter['title']
        if curr == 1 then 
            -- do nothing
        elseif time < curr_time then 
            return last_chapter - 1 -- Þessi mínus einn er held ég út af mpv lua byrja 0 og 1 ruslinu
        end
        last_chapter = curr
    end
    return last_chapter - 1
end

local function create_chapter(time, title)
    local curr_chapter = find_chapter_at(time)
    local chapter_count = mp.get_property_number("chapter-list/count")
    local all_chapters = mp.get_property_native("chapter-list")

    if chapter_count == 0 then
        all_chapters[1] = {
            title = title,
            time = time
        }
        curr_chapter = 0
    else
        for i = chapter_count, curr_chapter + 2, -1 do
            all_chapters[i + 1] = all_chapters[i]
        end
        all_chapters[curr_chapter+2] = {
            title = title,
            time = time
        }
    end
    mp.set_property_native("chapter-list", all_chapters)
    print('Chapter created at ' .. time)
end

local function create_chapter_here()
    local time_pos = mp.get_property_number("time-pos")
    local time_pos_osd = mp.get_property_osd("time-pos")
    mp.osd_message('Chapter created at ' .. time_pos_osd, 1)
    custom_chap_counter = custom_chap_counter + 1
    create_chapter(time_pos, 'Custom chapter ' .. tostring(custom_chap_counter))
end

local function create_chapter_here_with_title(...)
    local arg = {...}
    local chapter_name = table.concat(arg, ' ')
    local time_pos = mp.get_property_number("time-pos")
    local time_pos_osd = mp.get_property_osd("time-pos")
    mp.osd_message('Chapter "' .. chapter_name .. '" created at ' .. time_pos_osd, 1)
    create_chapter(time_pos, chapter_name)
end
mp.register_script_message('create-chapter-here-with-title', create_chapter_here_with_title)
mp.add_key_binding(nil, "create-chapter-here-with-title-shortcut", function()
    mp.commandv('script-message-to', 'console', 'type', 'script-message create-chapter-here-with-title ')
 end)
 

local function format_time(seconds)
    local result = ""
    if seconds <= 0 then
        return "00:00:00.000";
    else
        hours = string.format("%02.f", math.floor(seconds/3600))
        mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
        secs = string.format("%02.f", math.floor(seconds - hours*60*60 - mins*60))
        msecs = string.format("%03.f", seconds*1000 - hours*60*60*1000 - mins*60*1000 - secs*1000)
        result = hours..":"..mins..":"..secs.."."..msecs
    end
    return result
end

local function write_chapters()
    local chapter_count = mp.get_property_number("chapter-list/count")
    local all_chapters = mp.get_property_native("chapter-list")
    local curr = nil
    local file_text = ''

    mp.osd_message('Writing chapters to ffmetadatafile...')

    file_text = file_text .. ';FFMETADATA1\n'
    file_text = file_text .. '\n'
    

    for i = 1, chapter_count do
        curr = all_chapters[i]
        --local time_pos = format_time(curr.time)
        file_text = file_text .. '[CHAPTER]\n'
        file_text = file_text .. 'TIMEBASE=1/1\n'    
        file_text = file_text .. 'START=' .. curr.time   .. '\n'
        file_text = file_text .. 'END='   .. curr.time   .. '\n'  --Skilyrði að hafa líka end en virðist vera í lagi að hafa það bara sömu tölu
        file_text = file_text .. 'TITLE=' .. curr.title .. '\n'
        file_text = file_text .. '\n'
    end

    local path = mp.get_property("path")
    dir, name_ext = utils.split_path(path)
    local name = string.sub(name_ext, 1, (string.len(name_ext)-4))
    local out_path = utils.join_path(dir, name..".ffmdf")
    local file = io.open(out_path, "w")

    if file == nil then 
        mp.osd_message('Failed to write chapters to file')
    else
        file:write(file_text)
        file:close()    
        mp.osd_message('Chapters written to ' .. out_path)
        print('Chapters written to ' .. out_path)
    end

end

local function load_chapters(verbosity)
    local curr_chapter = mp.get_property_number("chapter")
    local chapter_count = mp.get_property_number("chapter-list/count")
    local all_chapters = mp.get_property_native("chapter-list")
    local new_chapters = {}
    local path = mp.get_property("path")
    dir, name_ext = utils.split_path(path)
    local name = string.sub(name_ext, 1, (string.len(name_ext)-4))
    local chapter_file = utils.join_path(dir, name..".ffmdf")
    if misc.file_exists(chapter_file) then 
        if verbosity ~= 'silent' then 
            mp.osd_message("Loading chapters from file...")
        end
    else
        if verbosity ~= 'silent' then 
            mp.osd_message("Couldn't find .ffmdf to load chapters")
        end
        return
    end

    local time_list = {}
    local title_list = {}
    local curr = 0
    for line in io.lines(chapter_file) do 
        if line:match('%[CHAPTER%]') ~= nil then
            curr = curr + 1
        elseif line:match('START') ~= nil then
            curr_time = tonumber(line:sub(7,-1))
        elseif line:match('TITLE') ~= nil then
            curr_title = line:sub(7,-1)
            create_chapter(curr_time, curr_title)
        end
    end
end

local function clear_chapters()
    mp.set_property_native("chapter-list", {})
    mp.osd_message('Chapters cleared')
    print('Chapters cleared')
end

local function bake_chapters_in()
    local path = mp.get_property("path")
    dir, name_ext = utils.split_path(path)
    local name = string.sub(name_ext, 1, (string.len(name_ext)-4))
    local chapter_file = utils.join_path(dir, name..".ffmdf")
    if misc.file_exists(chapter_file) then 

        local newpath = path:sub(1, -4) .. '_chaptered' .. path:sub(-4, -1)
        mp.osd_message('Rewriting file with chapters...')
        print('Running ffmpeg to bake chapters into ' .. path)
        args = {
            'ffmpeg', 
            '-i', path,
            '-i', chapter_file, 
            '-map_metadata', '1',
            '-hide_banner', 
            '-loglevel', 'warning',
            '-codec', 'copy',
            newpath
        }
        mp.command_native({name = "subprocess", args = args})
        mp.osd_message('Completed')
        print('ffmpeg has completed writing chapters to the file ' .. newpath)
    else 
        mp.osd_message('No chapters file (.ffmdf) found!')
    end

end


mp.add_key_binding(nil, "create-chapter", create_chapter_here, {repeatable=true})
mp.add_key_binding(nil, "write-chapters", write_chapters)
mp.add_key_binding(nil, "clear-chapters", clear_chapters)
mp.add_key_binding(nil, "bake-chapters-in", bake_chapters_in)
mp.add_key_binding(nil, "load-chapters", load_chapters)
mp.register_event('file-loaded', function () load_chapters('silent') end)