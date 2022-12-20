local lists_dir = mp.command_native({"expand-path", "~~/scripts/misc_lists/?.lua"})
local misc_script = mp.command_native({"expand-path", "~~/scripts/miscellaneous_scripts/miscellaneous.lua"})
package.path = lists_dir .. ";" .. misc_script .. ";" .. package.path 

local list_maker = require "scroll-list"
local utils = require 'mp.utils'
local misc = require 'miscellaneous'
local xml = require 'xmlparser'
local assdraw = require 'mp.assdraw'
local ON_WINDOWS = (package.config:sub(1,1) ~= '/')

local videos_path, firefox_path
if ON_WINDOWS then 
    videos_path = 'A:/youtube'
    --firefox_path = 'C:\\Program Files\\Mozilla Firefox\\firefox.exe'
    firefox_path = "C:\\Program Files\\Firefox Developer Edition\\firefox.exe"
else
    videos_path = 'VANTAR LINUX PATH'
    firefox_path = "firefox" 

end

local metatable = nil
local overlays = {
    [0] = 'commands',
    [1] = 'metadata', 
    [2] = 'comments'
}
local selected_page = 2
local prime_color = '0000ff'
local text_color = 'dddddd'
local faded_text_color = 'aaaaaa'
local state = {
    list_includes_channel = false,
    list_includes_release_date = false
}
local current_infojson = 'No infojson found'
local collapsed_comments = {}
-- Ath infojson skrárnar hafa sirka eftirfarandi keys:
-- [
--     'id', 'title', 'formats', 'thumbnails', 'description', 
--     'upload_date', 'uploader', 'uploader_id', 'uploader_url',
--     'channel_id', 'channel_url', 'duration', 'view_count', 
--     'average_rating', 'age_limit', 'webpage_url', 'categories', 
--     'tags', 'playable_in_embed', 'is_live', 'was_live', 
--     'live_status', 'automatic_captions', 'subtitles', 'like_count', 
--     'dislike_count', 'channel', 'availability', 'webpage_url_basename', 
--     'extractor', 'extractor_key', 'n_entries', 'playlist_index', 
--     'playlist', 'playlist_id', 'playlist_title', 'playlist_uploader', 
--     'playlist_uploader_id', 'thumbnail', 'display_id', 'format', 
--     'format_id', 'ext', 'width', 'height', 'resolution', 'fps', 
--     'vcodec', 'vbr', 'acodec', 'abr', 'fulltitle', 'comments', 
--     'comment_count', 'epoch'
-- ]
-- Tek eftir að comment count er ekki á þessum lista 
-- það er hægt að komast í það td með output template-inu 
-- en gæti orðið maus að incorpa það vel


------------------------------------------------------------------------------------------
--local list = list_maker()
-- list.header = [[{\b1}]] .. "Metadata" .. [[{\b0}\N]] .."‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"



------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Utility functions --------------------------------------------------------------------------------------------------------------------------------------------------------------
local function get_movie_metadata(metdat, filePath)
    local exe_dir = mp.command_native({"expand-path", "~~exe_dir/"}) 
    local fetchImetdatbByPath = utils.join_path(exe_dir, '../python_scripts/scraping/fetchImetdatbByPath.py') 

    args = {"powershell", "python", fetchImetdatbByPath, [["]] .. filePath .. [["]]}
    command_native_output = mp.command_native({
        name = "subprocess",
        capture_stdout = true,
        args = args}
    )
    subprocess_output = command_native_output['stdout']
    metdat = utils.parse_json(subprocess_output) -- The metadata table
    -- List of keys: 
    -- title
    -- year
    -- rating 
    -- voteCount
    -- metascore (sýnist bilað atm)
    -- genres
    -- runtime
    -- certificate 
    -- plot

    list.header = metdat['title'] .. "\\N ___________________________________________________"
    ----jump to the selected chapter


    list.keybinds = {
        {'DOWN', 'scroll_down', function() list:scroll_down() end, {repeatable = true}},
        {'UP', 'scroll_up', function() list:scroll_up() end, {repeatable = true}},
        {'ESC', 'close_browser', function() list:close() end, {}}
    }

    local ind = 1
    list.list = {}
    local item

    item = {}
    item.ass = 'Year: ' .. metdat['year']
    list.list[ind] = item
    ind = ind + 1

    item = {}
    item.ass = 'ImetdatB Rating: ' .. metdat['rating']
    list.list[ind] = item
    ind = ind + 1

    item = {}
    item.ass = 'Vote Count: ' .. misc.comma_value(metdat['voteCount'])
    list.list[ind] = item
    ind = ind + 1

    item = {}
    item.ass = 'Runtime: ' .. metdat['runtime']
    list.list[ind] = item
    ind = ind + 1

    if metdat['genres'][1] ~= nil then
        item = {}
        item.ass = 'Genres: ' .. metdat['genres'][1]
        for i, gen in pairs(metdat['genres']) do 
            item.ass = item.ass ..  ', ' .. gen
        end
        list.list[ind] = item
        ind = ind + 1
    end

    item = {}
    item.ass = 'Certificate: ' .. metdat['certificate'] .. '\\N_____________________________________________________________'
    list.list[ind] = item
    ind = ind + 1

    item = {}
    item.ass = 'Plot: '
    list.list[ind] = item
    ind = ind + 1


    description = misc.wrap(metdat['plot'], 120)
    lines = {}
    for s in description:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

    for i = 1, #lines do
        item = {}
        item.ass = lines[i]
        list.list[ind-1+i] = item
    end
    list:update()
    return metdat
end

local function wait(seconds)
    local start = os.time()
    repeat until os.time() > start + seconds
end  

local function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

local function get_url()
    local filePath = mp.get_property('path')
    local metadata_tags = mp.get_property_native('metadata')
    local url

    if filePath:match("http") then
        url = filePath
    elseif metadata_tags ~= nil then 
        -- Capitalization is not consistent so try them all
        url = metadata_tags['COMMENT']
        if url == nil then
            url = metadata_tags['comment']
        end
        if url == nil then
            url = metadata_tags['Comment']
        end
    end
    return url
end

local function get_ytid()
    local url = get_url()
    if url == nil then return end
    return url:match("[?&]v=(...........)") 
end

local function clean_url(url)
    local urlModded = url
    if string.match(urlModded, "&") then 
        s, e = string.find(urlModded, "&")
        urlModded = string.sub(urlModded, 1, s-1) 
    end 
    if string.match(urlModded, "youtu.be") then 
        s, e = string.find(urlModded, "youtu.be")
        urlModded = string.sub(urlModded, 1, s-1) .. "youtube.com/watch?v=" .. string.sub(urlModded, e+2, -1) 
    end
    return urlModded
end 

local function read_file(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

local function mod(x, m)
    return math.fmod(math.fmod(x,m) + m, m)
end

local function rgb_to_bgr(rgb)
    return rgb:sub(5, 6) .. rgb:sub(3, 4) .. rgb:sub(1, 2)
end

local function set_clipboard(text)
    local device = 'windows'
    local windows_copy = 'powershell'
    local pipe

    if device == 'linux' then
        pipe = io.popen(linux_copy, 'w')
        pipe:write(text)
        pipe:close()

    elseif device == 'windows' then
        if windows_copy == 'powershell' then
            local res = utils.subprocess({ args = {
                'powershell', '-NoProfile', '-Command', string.format([[& {
                    Trap {
                        Write-Error -ErrorRecord $_
                        Exit 1
                    }
                    Add-Type -AssemblyName PresentationCore
                    [System.Windows.Clipboard]::SetText('%s')
                }]], text)
            } })
        else
            pipe = io.popen(windows_copy,'w')
            pipe:write(text)
            pipe:close()
        end

    elseif device == 'mac' then
        pipe = io.popen(mac_copy,'w')
        pipe:write(text)
        pipe:close()
    end

    print([[Copied "]] .. text .. [[" to clipboard]])
    mp.osd_message([[Copied "]] .. text .. [[" to clipboard]])
    return ''
end

local function parse_timestamp_from_infojson(infojson)
    if not (type(infojson) == 'string') then return '' end
    local infojson_dir, name = utils.split_path(infojson)
    local date = name:match([[%d%d%d%d%d%d%d%d%d%d%d%d%d%d]])
    if date == nil then return infojson end
    return  'Metadata sótt ' .. misc.format_datestring(date)
end

local function parseEpisodeNfo(path)
    -- xml_outp layout :
    --      Mjög cluttered tafla, skiptir öllu í tré þar sem flest nodes hafa keys
    --          attrs, orderedattrs, children, tag
    --      þó þessir keys séu oft tómir. þeir þýða:
    --          attrs og orderedattrs það sama bara öðruvísi formattaðir
    --              eru oft tómir, er ekki 100% hvenær þeir eru notaðir
    --          children: gögnin sjálf, númeruð, þannig undir children 
    --              er alltaf [1], [2], etc þó oft sé bara eitt bar
    --              og þá er bara [1]. getur líka verið tómt
    --          tag: þetta er held ég aldrei tómt því þetta er nafnið á umræddu node

    --      Í nfo skránum sem ég skrifaði þetta fall fyrir
    --      er í raun allt inní xml_outp['children'][1]
    --      þar er tagið 'episodedetails'
    --      attrs og orderedattrs tómt og svo fullt af börnum (td 63, númerað frá 1)
    --      þeas: xml_outp['children'][1]['tag'] == 'episodedetails'
    --      og svo 'children' sem inniheldur öll alvöru gögnin númeruð
    --      td frá 1 til 63 í dæminu sem ég er að skoða, þeas dæmi um alvöru entry:
    --      xml_outp['children'][1]['children'][4] eða xml_outp['children'][1]['children'][38] etc...
    --      
    --      tag segir alltaf hvurs lags upplýsingar þetta eru, dæmi um tags:
    --          season, episode, displayseason, displayepisode, id, runtime
    --      
    --      nokkur dæmi þar sem attrs er tómt og children inniheldur bara 1 stak: 
    --          xml_outp['children'][1]['children'][1]['tag'] == 'title'
    --          xml_outp['children'][1]['children'][1]['children'][1]['text'] == 'Emissary (1)'
    --      annað dæmi
    --          xml_outp['children'][1]['children'][3]['tag'] == 'showtitle'
    --          xml_outp['children'][1]['children'][3]['children'][1]['text'] == 'Star Trek: Deep Space Nine'
    --      lokadæmi
    --          xml_outp['children'][1]['children'][4]['tag'] == 'season'
    --          xml_outp['children'][1]['children'][4]['children'][1]['text'] == '1'
    --
    --      dæmi þar sem attrs er ekki tómt:
    --          xml_outp['children'][1]['children'][9]['attrs'] == 
    --              {
    --                  ["type"] = tmdb,
    --                  ["default"] = false,    
    --              }
    --          xml_outp['children'][1]['children'][9]['orderedattrs'] == 
    --              {
    --                  [1] = 
    --                  { 
    --                      ["name"] = default,
    --                      ["value"] = false,
    --                  } ,
    --                  [2] = 
    --                  { 
    --                      ["name"] = type,
    --                      ["value"] = tmdb,
    --                  } ,
    --              }
    --          xml_outp['children'][1]['children'][9]['children'][1]['text'] == '969525'
    --          xml_outp['children'][1]['children'][9]['tag'] == 'uniqueid'
    --      svo var annað alveg eins dæmi nema fyrir ID-ið á imdb

    local actors = {}
    local num_actors = 0
    local ratings = {}
    local num_ratings = 0
    local xml_outp = xml.parseFile(path)
    local details = xml_outp['children'][1]['children']

    local title     = ''
    local showtitle = ''
    local season    = ''
    local episode   = ''
    local runtime   = ''
    local premiered = ''
    local aired     = ''
    local studio    = ''
    local credits   = ''
    local director  = ''
    local source    = ''
    local plot      = ''


    for i, node in pairs(details) do 
        if node['tag'] == 'title' then
            title = node['children'][1]['text']
        elseif node['tag'] == 'showtitle' then 
            showtitle = node['children'][1]['text']
        elseif node['tag'] == 'season' then 
            season = node['children'][1]['text']
        elseif node['tag'] == 'episode' then 
            episode = node['children'][1]['text']
        elseif node['tag'] == 'runtime' then 
            runtime = node['children'][1]['text']
        elseif node['tag'] == 'premiered' then 
            premiered = node['children'][1]['text']
        elseif node['tag'] == 'aired' then 
            aired = node['children'][1]['text']
        elseif node['tag'] == 'studio' then 
            studio = node['children'][1]['text']
        elseif node['tag'] == 'credits' then 
            credits = node['children'][1]['text']
        elseif node['tag'] == 'director' then 
            director = node['children'][1]['text']
        elseif node['tag'] == 'source' then 
            source = node['children'][1]['text']
        elseif node['tag'] == 'plot' then 
            plot = node['children'][1]['text']
        

        elseif node['tag'] == 'actor' then 
            actors[num_actors] = {
                name    = '',
                role    = '',
                profile = ''
            }
            for ii, actornode in pairs(node['children']) do
                if actornode['tag'] == 'name' then 
                    actors[num_actors]['name'] = actornode['children'][1]['text']
                elseif actornode['tag'] == 'role' then
                    actors[num_actors]['role'] = actornode['children'][1]['text']
                elseif actornode['tag'] == 'profile' then
                    actors[num_actors]['profile'] = actornode['children'][1]['text']
                end 
            end
            num_actors = num_actors + 1
        

        elseif node['tag'] == 'ratings' then 
            for ii, ratenode in pairs(node['children']) do 
                ratings[num_ratings] = {
                    name        = ratenode['attrs']['name'],
                    maxrating   = ratenode['attrs']['max'],
                    value       = '',
                    votes       = ''
                }
                for iii, ratenodechild in pairs(ratenode['children']) do 
                    if ratenodechild['tag'] == 'value' then 
                        ratings[num_ratings]['value'] = ratenodechild['children'][1]['text']
                    elseif ratenodechild['tag'] == 'votes' then 
                        ratings[num_ratings]['votes'] = ratenodechild['children'][1]['text']
                    end
                end
                num_ratings = num_ratings + 1
            end
        end

        
    end

    local nfo_table = {
        -- single field
        title       = title,
        showtitle   = showtitle,
        season      = season,
        episode     = episode,
        plot        = plot,
        runtime     = runtime,
        premiered   = premiered,
        aired       = aired,
        studio      = studio,
        credits     = credits,
        director    = director,
        source      = source,

        -- multifield
        ratings     = ratings,
        actors      = actors
        
    }

    return nfo_table
end

local function parseTVShowNfo(path)
    local xml_outp = xml.parseFile(path)
    local details = xml_outp['children'][1]['children']

    local title     = ''
    local year      = ''
    local plot      = ''
    local runtime   = ''
    local premiered = ''
    local status    = '' -- Ended or not
    local studio    = ''

    local actors = {}
    local num_actors = 0
    local ratings = {}
    local num_ratings = 0
    local genres = {}
    local num_genres = 0
    local tags = {}
    local num_tags = 0


    for i, node in pairs(details) do 
        if node['tag'] == 'title' then
            title = node['children'][1]['text']
        elseif node['tag'] == 'year' then 
            year = node['children'][1]['text']
        elseif node['tag'] == 'plot' then 
            plot = node['children'][1]['text']
        elseif node['tag'] == 'runtime' then 
            runtime = node['children'][1]['text']
        elseif node['tag'] == 'premiered' then 
            premiered = node['children'][1]['text']
        elseif node['tag'] == 'status' then 
            status = node['children'][1]['text']
        elseif node['tag'] == 'studio' then 
            studio = node['children'][1]['text']
        

        elseif node['tag'] == 'genre' then 
            genres[num_genres] = node['children'][1]['text']
            num_genres = num_genres + 1
        elseif node['tag'] == 'tag' then 
            tags[num_tags] = node['children'][1]['text']
            num_tags = num_tags + 1


        elseif node['tag'] == 'actor' then 
            actors[num_actors] = {
                name    = '',
                role    = '',
                profile = ''
            }
            for ii, actornode in pairs(node['children']) do
                if actornode['tag'] == 'name' then 
                    actors[num_actors]['name'] = actornode['children'][1]['text']
                elseif actornode['tag'] == 'role' then
                    actors[num_actors]['role'] = actornode['children'][1]['text']
                elseif actornode['tag'] == 'profile' then
                    actors[num_actors]['profile'] = actornode['children'][1]['text']
                end 
            end
            num_actors = num_actors + 1
        

        elseif node['tag'] == 'ratings' then 
            for ii, ratenode in pairs(node['children']) do 
                ratings[num_ratings] = {
                    name        = ratenode['attrs']['name'],
                    maxrating   = ratenode['attrs']['max'],
                    value       = '',
                    votes       = ''
                }
                for iii, ratenodechild in pairs(ratenode['children']) do 
                    if ratenodechild['tag'] == 'value' then 
                        ratings[num_ratings]['value'] = ratenodechild['children'][1]['text']
                    elseif ratenodechild['tag'] == 'votes' then 
                        ratings[num_ratings]['votes'] = ratenodechild['children'][1]['text']
                    end
                end
                num_ratings = num_ratings + 1
            end
        end

        
    end

    local nfo_table = {
        -- single field
        title       = title,
        year        = year,
        plot        = plot,
        runtime     = runtime,
        premiered   = premiered,
        status      = status,
        studio      = studio,

        -- multifield
        ratings     = ratings,
        actors      = actors,
        genres      = genres,
        tags        = tags
        
    }

    return nfo_table
end

function addToSet(set, key)
    set[key] = true
end

function removeFromSet(set, key)
    set[key] = nil
end

function setContains(set, key)
    return set[key] ~= nil
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------ Fetch metadata --------------------------------------------------------------------------------------------------------------------------------------------------------------

local function add_tag_to_list(tag, tag_name, ind)

    if metatable[tag] then 
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. tag_name .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. metatable[tag]
        list.list[ind] = item
        ind = ind + 1
    end

    return ind
end

local function write_youtube_metadata(ind)
    local item
    
    if (metatable['view_count'] ~= nil) then
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Views: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. misc.comma_value(metatable['view_count'])
        list.list[ind] = item
        ind = ind + 1
    end

    if (metatable['dislike_count'] ~= nil) and (metatable['like_count'] ~= nil) then  
        local like_ratio = metatable['like_count']/(metatable['like_count']   +metatable['dislike_count'])
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Likes: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. string.format("%.2f", 100*like_ratio)  .. '%  (👍 ' .. misc.comma_value(metatable['like_count']) .. [[  /  ]] .. misc.comma_value(metatable['dislike_count']) .. ' 👎)'
        list.list[ind] = item
        ind = ind + 1
    elseif (metatable['like_count'] ~= nil) then 
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Likes: ' .. [[{\b0}{\c&H]] .. text_color ..  [[&}]] .. '👍 ' .. misc.comma_value(metatable['like_count'])
        list.list[ind] = item
        ind = ind + 1
    end

    if (metatable['uploader'] ~= nil) then
        state.list_includes_channel = true
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Channel: ' ..  [[{\b0}{\c&H]] .. text_color .. [[&}]] .. metatable['uploader']
        list.list[ind] = item
        ind = ind + 1
    end

    if (metatable['upload_date'] ~= nil) then
        state.list_includes_release_date = true
        date = misc.format_datestring(metatable['upload_date'], 'include_diff')
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Upload date: ' ..  [[{\b0}{\c&H]] .. text_color .. [[&}]] .. date
        list.list[ind] = item
        ind = ind + 1
    end

    if (metatable['description'] ~= nil) then 
        item = {}
        item.style = [[{\c&]] .. prime_color .. [[&}]]
        item.ass = '\\N ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾'
        list.list[ind] = item
        ind = ind + 1
        
        item = {}
        --item.style = [[{\q2\fs22&}]]
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Description: ' ..  [[{\b0}\N]] 
        list.list[ind] = item
        ind = ind + 1


        description = misc.wrap(metatable['description'], 140)
        -- description = metatable['description']
        lines = {}
        for s in description:gmatch("[^\r\n]+") do
            table.insert(lines, s)
        end

        for i = 1, #lines do
            item = {}
            item.ass = [[{\q2\fs22&}]] .. lines[i]
            list.list[ind] = item
            ind = ind + 1
        end
    end

    return ind
end

local function write_music_metadata(ind)
    local item

    if not state.list_includes_channel then 
        ind = add_tag_to_list('artist', 'Artist: ', ind)
    end
    ind = add_tag_to_list('album',  'Album: ', ind)
    if not state.list_includes_release_date then
        ind = add_tag_to_list('date',   'Release Year: ', ind)
    end
    ind = add_tag_to_list('track',  'Track #', ind)

    return ind
end

local function write_nfo_episode_metadata(ind)
    local item
    local ep = metatable['episode_metadata']

    if (ep['season'] ~= nil) and (ep['episode'] ~= nil) and (ep['showtitle'] ~= nil)then
        item = {}
        SE_string = string.format('S%02dE%02d', tonumber(ep['season']), tonumber(ep['episode']))
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. SE_string .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. ' of ' .. [[{\b1}{\c&]] .. prime_color .. [[&}]] .. ep['showtitle']
        list.list[ind] = item
        ind = ind + 1
    end

    if (ep['aired'] ~= nil) then
        item = {}
        local date = misc.format_datestring(ep['aired'], 'include_diff', true)
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Episode Aired: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. date
        list.list[ind] = item
        ind = ind + 1
    end

    if (ep['credits'] ~= nil) then
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Credits: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. ep['credits']
        list.list[ind] = item
        ind = ind + 1
    end

    if (ep['director'] ~= nil) then
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Director: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. ep['director']
        list.list[ind] = item
        ind = ind + 1
    end

    if (ep['ratings'] ~= nil) then
        for i, rating_table in pairs(ep['ratings']) do 
            local tag, value, maxstring, votes

            if rating_table['name'] == 'imdb' then 
                tag = 'IMDB Rating: '
                value = string.format('%.1f', tonumber(rating_table['value']))
                maxstring = [[ / 10]]
                votes = misc.comma_value(rating_table['votes'])
    
            elseif rating_table['name'] == 'themoviedb' then
                tag = 'TheMovieDB Rating: '
                value = string.format('%.1f', tonumber(rating_table['value']))
                maxstring = [[ / 10]]
                votes = misc.comma_value(rating_table['votes'])
    
            end

            item = {}
            item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. tag .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. value .. maxstring .. ' (' .. votes .. [[ votes)]]
            list.list[ind] = item
            ind = ind + 1
        end
    end


    if (ep['plot'] ~= nil) then
        item = {}
        item.style = [[{\c&]] .. prime_color .. [[&}]]
        item.ass = '\\N ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾'
        list.list[ind] = item
        ind = ind + 1
        
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Plot Synopsis: ' ..  [[{\b0}]] 
        list.list[ind] = item
        ind = ind + 1


        local plot = misc.wrap(ep['plot'], 100)
        local lines = {}
        for s in plot:gmatch("[^\r\n]+") do
            table.insert(lines, s)
        end

        for i = 1, #lines do
            item = {}
            item.ass = [[{\q2\fs22&}]] .. lines[i]
            list.list[ind] = item
            ind = ind + 1
        end
    end

    if (ep['actors'] ~= nil) then
        local actors = ep['actors']
        item = {}
        item.style = [[{\c&]] .. prime_color .. [[&}]]
        item.ass = '\\N ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾'
        list.list[ind] = item
        ind = ind + 1
        
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Cast: ' ..  [[{\b0}]] 
        list.list[ind] = item
        ind = ind + 1

        for i = 1, #actors do
            act = actors[i]
            item = {}
            item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. act['name'] .. ': ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. act['role']
            list.list[ind] = item
            ind = ind + 1
        end
    end



    return ind
end

local function write_nfo_series_metadata()
    local item
    local series = metatable['series_metadata']
    local ind = 0
    if series == nil then return end 

    item = {}
    item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Series Metadata\n' .. [[{\b0}{\c&H]]
    list.list[ind] = item
    ind = ind + 1

    if (series['title'] ~= nil) then
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'TV Show: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. series['title']
        list.list[ind] = item
        ind = ind + 1
    end

    if (series['premiered'] ~= nil) then
        item = {}
        local date = misc.format_datestring(series['premiered'], 'include_diff', true)
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Series Premiere: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. date
        list.list[ind] = item
        ind = ind + 1
    end

    if (series['runtime'] ~= nil) then
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Runtime: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. series['runtime'] .. ' minutes'
        list.list[ind] = item
        ind = ind + 1
    end

    if (series['studio'] ~= nil) then
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Studio: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. series['studio']
        list.list[ind] = item
        ind = ind + 1
    end

    if (series['status'] ~= nil) then
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Status: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. series['status']
        list.list[ind] = item
        ind = ind + 1
    end

    if (series['ratings'] ~= nil) then
        for i, rating_table in pairs(series['ratings']) do 
            local tag, value, maxstring, votes

            if rating_table['name'] == 'imdb' then 
                tag = 'IMDB Rating: '
                value = string.format('%.1f', tonumber(rating_table['value']))
                maxstring = [[ / 10]]
                votes = misc.comma_value(rating_table['votes'])
    
            elseif rating_table['name'] == 'themoviedb' then
                tag = 'TheMovieDB Rating: '
                value = string.format('%.1f', tonumber(rating_table['value']))
                maxstring = [[ / 10]]
                votes = misc.comma_value(rating_table['votes'])
    
            end

            item = {}
            item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. tag .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. value .. maxstring .. ' (' .. votes .. [[ votes)]]
            list.list[ind] = item
            ind = ind + 1
        end
    end

    item = {}
    item.style = [[{\c&]] .. prime_color .. [[&}]]
    item.ass = '\\N ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾'
    list.list[ind] = item
    ind = ind + 1

    if (series['genres'] ~= nil) then
        local genres_text = '' 

        for i, gen in pairs(series['genres']) do 
            genres_text = genres_text .. gen .. ', '
        end
        genres_text =  misc.wrap(genres_text:sub(1, #genres_text-2), 120, '    ', '', [[{\b0}{\c&H]] .. text_color .. [[&}\n]]) 

        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Genre: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. genres_text
        list.list[ind] = item
        ind = ind + 1
    end

    if (series['tags'] ~= nil) then
        local tags_text = '' 

        for i, gen in pairs(series['tags']) do 
            tags_text = tags_text .. gen .. ', '
        end
        tags_text = misc.wrap(tags_text:sub(1, #tags_text-2), 100, '\\h\\h\\h\\h\\h\\h\\h\\h\\h\\h\\h\\h\\h\\h\\h', '', [[{\b0}{\c&H]] .. text_color .. [[&}\n]]) 

        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Tags: ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. tags_text
        list.list[ind] = item
        ind = ind + 1
    end


    if (series['plot'] ~= nil) then
        
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. '\\N\\h\\h\\h\\h\\hPlot Synopsis: ' ..  [[{\b0}]] 
        list.list[ind] = item
        ind = ind + 1


        local plot = misc.wrap(series['plot'], 100)
        local lines = {}
        for s in plot:gmatch("[^\r\n]+") do
            table.insert(lines, s)
        end

        for i = 1, #lines do
            item = {}
            item.ass = [[{\q2\fs22&}]] .. lines[i]
            list.list[ind] = item
            ind = ind + 1
        end
    end

    if (series['actors'] ~= nil) then
        local actors = series['actors']
        item = {}
        item.style = [[{\c&]] .. prime_color .. [[&}]]
        item.ass = '\\N ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾'
        list.list[ind] = item
        ind = ind + 1
        
        item = {}
        item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. 'Starring: ' ..  [[{\b0}]] 
        list.list[ind] = item
        ind = ind + 1

        for i = 1, #actors do
            act = actors[i]
            item = {}
            item.ass = [[{\b1}{\c&]] .. prime_color .. [[&}]] .. act['name'] .. ': ' .. [[{\b0}{\c&H]] .. text_color .. [[&}]] .. act['role']
            list.list[ind] = item
            ind = ind + 1
        end
    end

    return ind

end

local function write_commands_to_list()
    if metatable == nil then return end
    if next(metatable) == nil then return end 

    if (metatable['title'] ~= nil) then 
        list.header = [[{\b1}]] .. metatable['title'] .. [[{\b0}\N]] .."‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
    end

    local ind = 1
    list.list = {}
    local item

    item = {}
    item.ass = [[{\q2\fs20\i1}]] .. 'Copy YouTube URL if available' .. [[{\i0}]] --{\\c&3471bf&}
    list.list[ind] = item
    ind = ind + 1

    item = {}
    item.ass = [[{\q2\fs20\i1}]] .. 'Open in Firefox' .. [[{\i0}]] --{\\c&3471bf&}
    list.list[ind] = item
    ind = ind + 1

    item = {}
    item.style = [[{\c&]] .. prime_color .. [[&}]]
    item.ass = '\\N __________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________'
    item.ass = item.ass .. '\\N' .. parse_timestamp_from_infojson(current_infojson) .. '\\N'
    list.list[ind] = item
    ind = ind + 1

    item = {}
    item.ass = [[{\q2\fs20\i1}]] .. 'Fetch infojson with 100 comments and thumbnail' .. [[{\i0}]] --{\\c&3471bf&}
    list.list[ind] = item
    ind = ind + 1

    item = {}
    item.ass = [[{\q2\fs20\i1}]] .. 'Fetch infojson with no comments' .. [[{\i0}]] --{\\c&3471bf&}
    list.list[ind] = item
    ind = ind + 1

    item = {}
    item.ass = [[{\q2\fs20\i1}]] .. 'Fetch infojson with 100 comments' .. [[{\i0}]] --{\\c&3471bf&}
    list.list[ind] = item
    ind = ind + 1

    item = {}
    item.ass = [[{\q2\fs20\i1}]] .. 'Fetch infojson with all comments' .. [[{\i0}]] --{\\c&3471bf&}
    list.list[ind] = item
    ind = ind + 1
    
    item = {}
    item.ass = [[{\q2\fs20\i1}]] .. 'Fetch thumbnail' .. [[{\i0}]] --{\\c&3471bf&}
    list.list[ind] = item
    ind = ind + 1


    list:update()
end

local function write_comments_to_list()
    if metatable == nil then return end
    if next(metatable) == nil then return end 

    if (metatable['title'] ~= nil) then 
        -- local available_comments_count = tostring(table.getn(metatable['comments']))
        local video_title = [[{\b1}]] .. metatable['title'] .. [[{\b0}\N]] .."‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾" 
        -- Virkar ekki því metatable['comment_count'] gefur bara local fjöldann :(
        -- list.header = available_comments_count .. ' out of ' .. metatable['comment_count'] .. ' comments on ' .. video_title
        list.header = video_title
    end 

    local ind = 1
    list.list = {}
    local item

    if (metatable['comments'] == nil) or (next(metatable['comments']) == nil) then 
        item = {}
        item.ass = "No comments"
        list.list[ind] = item
        ind = ind + 1
        list:update()
        return
    end 

    local padding, author_padding

    for i, com in pairs(metatable['comments']) do
        local comment_is_collapsed = false
        if setContains(collapsed_comments, com['id']) then 
            comment_is_collapsed = true
        end
        if setContains(collapsed_comments, com['parent']) then -- betra að hafa þetta bara if (en ekki elseif)
            goto continue
        end

        item = {}
        
        local is_reply = (com['parent'] ~= 'root')
        if is_reply then 
            author_padding = '\\h\\h\\h\\h\\h\\h\\h'
            item.style = [[{\c&]] .. faded_text_color .. [[&}]]
        else
            author_padding = ''
        end
        padding = author_padding .. '\\h\\h\\h\\h'

        local comment = ''
        local timestamp = os.date("%Y.%m.%d", com['timestamp'])
        local author = author_padding .. [[{\b1}]] .. com['author'] .. [[{\b0}  ]]
        if com['author_is_uploader'] then 
            author = author_padding .. [[{\c&]] .. '8ca2c2' .. [[&}]] .. [[{\b1}]] .. com['author'] .. [[{\b0}  ]]
        end
        comment = author .. com['like_count'] .. ' 👍  -  ' .. timestamp .. ' (' .. com['time_text'] .. ')'
        if com['is_favorited'] then 
            comment = comment .. [[{\c&]] .. '0221ab' .. [[&}]] .. '  ❤' 
        end
        local comment_text
        if not comment_is_collapsed then
            comment_text = com['text']:gsub('\n', '\n' .. padding) -- fyrrverandi newlines fokka shittinu mínu upp
            comment_text = misc.wrap(comment_text, 140, padding)
        else 
            comment_text = ''
        end
        comment = comment .. '\n' .. comment_text .. '\n'

        if is_reply then -- color is reset after every newline
            comment = comment:gsub('\n', '\n' .. [[{\c&]] .. faded_text_color .. [[&}]])
        end
        

        item.ass = comment
        item.metadata = com
        list.list[ind] = item
        ind = ind + 1
        ::continue::
    end 

    list:update()
end

local function write_single_comment_to_list(the_comment)
    if metatable == nil then return end
    if next(metatable) == nil then return end 

    if (metatable['title'] ~= nil) then 
        -- local available_comments_count = tostring(table.getn(metatable['comments']))
        local video_title = [[{\b1}]] .. metatable['title'] .. [[{\b0}\N]] .."‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾" 
        -- Virkar ekki því metatable['comment_count'] gefur bara local fjöldann :(
        -- list.header = available_comments_count .. ' out of ' .. metatable['comment_count'] .. ' comments on ' .. video_title
        list.header = video_title
    end 

    local ind = 1
    list.list = {}
    local item
    local com = metatable['comments'][list.selected]

    item = {}
    local timestamp = os.date("%Y.%m.%d", com['timestamp'])
    local comment_header = [[{\b1}]] .. com['author'] .. [[{\b0}  ]] .. com['like_count'] .. ' 👍  -  ' .. timestamp .. ' (' .. com['time_text'] .. ')'
    if com['is_favorited'] then 
        comment_header = comment_header .. '  ❤' 
    end
    item.ass = comment_header
    list.list[ind] = item
    ind = ind + 1

    comment_body = misc.wrap(com['text'], 140)

    local lines = {}
    for s in comment_body:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

    for i = 1, #lines do
        item = {}
        item.ass = [[{\q2\fs22&}]] .. lines[i]
        list.list[ind] = item
        ind = ind + 1
    end


    list.num_entries = 27
    current_overlay = 5
    list:update()
    selected_page = 2
end

local function write_selected_page(page)
    if metatable == nil then return end
    if next(metatable) == nil then return end 
    local page = selected_page
    state = {
        list_includes_channel = false,
        list_includes_release_date = false
    }
    

    if (metatable['title'] ~= nil) then 
        list.header = [[{\b1}]] .. metatable['title'] .. [[{\b0}\N]] .."‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
    end

    list.list = {}
    local ind = 1


    if page == 1 then 
        list.num_entries = 27
        list.wrapper_message = ' item(s) remaining'
        list.top_wrapper_message = ' item(s) above'
        write_commands_to_list()


    elseif page == 2 then 
        list.num_entries = 27
        list.bottom_wrapper_message = ' item(s) remaining'
        list.top_wrapper_message = ' item(s) above'

        if metatable['metadata_type'] == 'infojson' then 
            ind = write_youtube_metadata(ind)
        elseif metatable['metadata_type'] == 'nfo' then
            ind = write_nfo_episode_metadata(ind)
        elseif metatable['metadata_type'] == 'file' then
            ind = write_music_metadata(ind)
        end


    elseif page == 3 then
        if metatable['metadata_type'] == 'nfo' then
            list.num_entries = 27
            write_nfo_series_metadata()
        else
            list.num_entries = 8
            list.bottom_wrapper_message = ' comment(s) remaining'
            list.top_wrapper_message = ' comment(s) above'    
            write_comments_to_list()
        end


    else
        print('In the write_selected_page function, page must be 1, 2 or 3!')
    end

    list:update()
end

local function load_tags_from_file()
    local metadata_tags = mp.get_property_native('metadata')

    metatable = {}
    for tag, metadata in pairs(metadata_tags) do 
        metatable[tag:lower()] = metadata 
    end
    metatable['metadata_type'] = 'file'

    return metatable
end

local function load_tags_from_json(metatable)
    local vid_dir, vid_path = utils.split_path(mp.get_property('path'))
    local infojson_dir, _ = utils.join_path(utils.join_path(vid_dir, '.metadata'), 'infojsons')
    local yt_id = get_ytid()
    if yt_id == nil then return metatable end

    infojsons = {}
    local infojson_dir_obj = utils.readdir(infojson_dir)
    if infojson_dir_obj ~= nil then 
        for _, infojson in pairs(infojson_dir_obj) do 
            if starts_with(infojson, yt_id) then 
                table.insert(infojsons, utils.join_path(infojson_dir, infojson))
            end
        end
    end

    most_recent_infojson = infojsons[#infojsons]
    if type(most_recent_infojson) == 'string' then 
        current_infojson = most_recent_infojson
    end
    if most_recent_infojson == nil then return metatable end 
    infojson = read_file(most_recent_infojson)
    infojson = utils.parse_json(infojson)

    metatable = {}
    for tag, metadata in pairs(infojson) do 
        metatable[tag:lower()] = metadata
    end
    metatable['metadata_type'] = 'infojson'
    collapsed_comments = {}

    return metatable
end

local function load_tags_from_nfo(metatable)
    local vid_dir, vid_name_with_ext = utils.split_path(mp.get_property('path'))
    local nfo_dir1, _ = utils.join_path(utils.join_path(vid_dir, '.metadata'), 'nfos')
    local nfo_dir2, _ = utils.join_path(utils.join_path(utils.join_path(vid_dir, '..'), '.metadata'), 'nfos')
    local vid_name = misc.RemoveFileExtension(vid_name_with_ext)

    nfos = {}
    tvshow_nfos = {}
    local nfo_dir_obj = utils.readdir(nfo_dir1)
    if nfo_dir_obj ~= nil then 
        for _, nfo in pairs(nfo_dir_obj) do 
            if starts_with(nfo, vid_name) then 
                table.insert(nfos, utils.join_path(nfo_dir1, nfo))
            end
            if nfo == 'tvshow.nfo' then 
                table.insert(tvshow_nfos, utils.join_path(nfo_dir1, nfo))
            end
        end
    end

    local nfo_dir_obj = utils.readdir(nfo_dir2)
    if (nfo_dir_obj ~= nil) and (misc.getTableSize(nfos) == 0) then 
        for _, nfo in pairs(nfo_dir_obj) do 
            if starts_with(nfo, vid_name) then 
                table.insert(nfos, utils.join_path(nfo_dir2, nfo))
            end
            if nfo == 'tvshow.nfo' then 
                table.insert(tvshow_nfos, utils.join_path(nfo_dir2, nfo))
            end
        end
    end

    most_recent_nfo = nfos[#nfos]
    most_recent_tvshow_nfo = tvshow_nfos[#tvshow_nfos]

    -- if type(most_recent_nfo) == 'string' then 
    --     current_nfo = most_recent_nfo
    -- end

    if most_recent_nfo == nil then return metatable end 
    nfo = parseEpisodeNfo(most_recent_nfo)


    if most_recent_tvshow_nfo ~= nil then 
        tvshow_nfo =  parseTVShowNfo(most_recent_tvshow_nfo)
    end

    metatable = {
        title = nfo['title'],
        metadata_type = 'nfo',
        episode_metadata = nfo, 
        series_metadata = tvshow_nfo
    } 
    -- for tag, metadata in pairs(nfo) do 
    --     metatable[tag:lower()] = metadata
    -- end
    return metatable

end

local function load_available_metadata()
    metatable = nil
    
    -- Search for infojson
    metatable = load_tags_from_json(metatable) 

    -- If no infojson is found, search for nfo
    if metatable == nil then 
        metatable = load_tags_from_nfo(metatable)
    end

    -- If no nfo is found, search for tags in the file
    if metatable == nil then 
        metatable = load_tags_from_file()
    end
end 

local function refresh_metadata()
    load_available_metadata()
    write_selected_page()
end

local function refresh_metadata_verbose(success, result, error)
    refresh_metadata()
    local msg = 'Just refreshed metadata!'
    mp.osd_message(msg, 4)
    print(msg)
end


local function download_yt_metadata(what_to_download)
    if what_to_download == nil then 
        what_to_download = 'infojson_100comments thumbnail'
    end

    if url == nil then 
        url = get_url()
        if url == nil then return end
    end
    url = clean_url(url)
    timestamp = os.date('%Y%m%d%H%M%S')

    local vid_dir, vid_path = utils.split_path(mp.get_property('path'))

    args = {
        "yt-dlp", 
        "--ignore-config", 
        '-o', vid_dir .. '.metadata/%(id)s_' .. timestamp .. '.%(ext)s', -- mikilvægt að hafa þetta (video path þó sé ekkert video) annars fokkast thumbnail dótið upp út af permissions
        '-o', 'thumbnail:' .. vid_dir .. '.metadata/thumbnails/%(id)s_' .. timestamp,
        '-o', 'infojson:' .. vid_dir .. '.metadata/infojsons/%(id)s_' .. timestamp,
        "--skip-download", 
    }


    if what_to_download:match('infojson_nocomments') then 
        table.insert(args, "--write-info-json")
        table.insert(args, "--sponsorblock-mark")
        table.insert(args, "sponsor")

    elseif what_to_download:match('infojson_100comments') then 
        table.insert(args, "--write-info-json")
        table.insert(args, "--sponsorblock-mark")
        table.insert(args, "sponsor")
        table.insert(args, "--write-comments")
        table.insert(args, "--extractor-args")
        table.insert(args, "youtube:comment_sort=top;max_comments=100")

    elseif what_to_download:match('infojson_allcomments') then 
        table.insert(args, "--write-info-json")
        table.insert(args, "--sponsorblock-mark")
        table.insert(args, "sponsor")
        table.insert(args, "--write-comments")
        table.insert(args, "--extractor-args")
        table.insert(args, "youtube:comment_sort=top")
    end

    if what_to_download:match('thumbnail') then 
        table.insert(args, "--write-thumbnail")
    end
    
    table.insert(args, url)
    
    command_native_output = mp.command_native_async({
        name = "subprocess",
        args = args,
    }, refresh_metadata_verbose)
end


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
local function goto_list_bottom()
    list.selected = #list.list
    list:update_ass()
end

local function goto_list_top()
    list.selected = 1
    list:update_ass()
end

local function display_centered_message(base_text)
    local centered_msg = mp.create_osd_overlay('ass-events')
    local base_ass = "{\\fs" .. 36 .. "}{\\1c&H" .. rgb_to_bgr('b3a788') .. "}{\\bord1.0}" .. base_text

    a = assdraw:ass_new()
    a:new_event()
    a:an(5)
    a:append(base_ass)

    centered_msg.z = 1
    centered_msg.data = a.text
    centered_msg:update()

    local timestep = 0.8
    mp.add_timeout(timestep*1, function()
        a = assdraw:ass_new()
        a:new_event()
        a:an(5)
        a:append(base_ass .. '.')
        centered_msg.data = a.text
        centered_msg:update()
    end)
    mp.add_timeout(timestep*2, function()
        a = assdraw:ass_new()
        a:new_event()
        a:an(5)
        a:append(base_ass .. '..')
        centered_msg.data = a.text
        centered_msg:update()
    end)
    mp.add_timeout(timestep*3, function()
        a = assdraw:ass_new()
        a:new_event()
        a:an(5)
        a:append(base_ass .. '...')
        centered_msg.data = a.text
        centered_msg:update()
    end)
    mp.add_timeout(timestep*4, function()
        centered_msg:remove()
    end)
    

end

local function collapse_comment()
    if not (selected_page == 3) then return end 
    if metatable == nil then return end 
    if not (metatable['metadata_type'] == 'infojson') then return end
    local selected = list.list[list.selected]

    local comment_id = selected['metadata']['id']
    if not setContains(collapsed_comments, comment_id) then 
        addToSet(collapsed_comments, comment_id)
    else
        removeFromSet(collapsed_comments, comment_id)
    end
    write_comments_to_list()
end

local function collapse_all_comms()
    if not (selected_page == 3) then return end 
    if metatable == nil then return end 
    if not (metatable['metadata_type'] == 'infojson') then return end

    if next(collapsed_comments) == nil then 
        for _, item in pairs(list.list) do 
            comment_id = item['metadata']['id']
            addToSet(collapsed_comments, comment_id)
        end
        list.selected = 1
    else 
        collapsed_comments = {}
    end
    write_comments_to_list()
end


local function execute_command_page1()
    local selected_text = list.list[list.selected].ass

    if selected_text:match('Copy YouTube URL if available') then
        local url = get_url()
        if type(url) == 'string' then 
            set_clipboard(url)
        end

    elseif selected_text:match('Open in Firefox') then
        local url = get_url()
        args = {firefox_path, url}
        res = mp.command_native({name = "subprocess", args = args, detach=true})

    elseif selected_text:match('Fetch infojson with 100 comments and thumbnail') then  
        download_yt_metadata('infojson_100comments thumbnail')
        display_centered_message('Fetching infojson with 100 comments and thumbnail')

    elseif selected_text:match('Fetch infojson with no comments') then  
        download_yt_metadata('infojson_nocomments thumbnail')
        display_centered_message('Fetching infojson with no comments')

    elseif selected_text:match('Fetch infojson with 100 comments') then  
        download_yt_metadata('infojson_100comments')
        display_centered_message('Fetching infojson with 100 comments')

    elseif selected_text:match('Fetch infojson with all comments') then  
        download_yt_metadata('infojson_allcomments')
        display_centered_message('Fetching infojson with all comments')

    elseif selected_text:match('Fetch thumbnail') then  
        download_yt_metadata('thumbnail')
        display_centered_message('Fetching thumbnail')

    end
end

local function execute_command_page2()
    local timestamp_pattern = '[0-9]?:?[0-5]?[0-9]:[0-5][0-9]'
    local selected_text = list.list[list.selected].ass

    if selected_text:match(timestamp_pattern) and not (selected_text:match('\n')) then 
        timestamp = selected_text:match(timestamp_pattern)
        total_secs = misc:time_string_to_secs(timestamp)
        mp.command("no-osd seek " .. total_secs .. " absolute exact")
    end

end

local function execute_command_page3()
    local selected = list.list[list.selected]
    write_single_comment_to_list(selected)
end

local function execute_line()
    if selected_page == 1 then 
        execute_command_page1()
    elseif selected_page == 2 then 
        execute_command_page2()
    elseif selected_page == 3 then
        execute_command_page3()
    end
end

local function change_overlay(direction)
    -- Annað jaðarskilyrði
    -- if direction == 'left' then 
    --     current_overlay = mod(current_overlay - 1, 3)
    -- else
    --     current_overlay = mod(current_overlay + 1, 3)
    -- end
    if direction == 'left' then 
        selected_page = selected_page - 1
    else
        selected_page = selected_page + 1
    end
    if selected_page < 1 then 
        selected_page = 1
    elseif selected_page > 3 then 
        selected_page = 3
        collapse_comment()
    end

    write_selected_page()
end

prime_color = rgb_to_bgr('c42323')
text_color = rgb_to_bgr('dddddd')

list = list_maker() -- Mostly defaults
list.header = [[{\b1}Metadata{\b0}\N]] .."‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
list.header_style = [[{\bord0\1a33&\q2\fs26\c&]] .. prime_color .. [[&}]]
list.list_style = [[{\q2\fs21\c&H]] .. text_color .. [[&}]]
list.wrapper_style = [[{\c&bbbbbb&\fs16}]]
list.cursor = [[➤\h]]
list.indent = [[\h\h\h\h\h]]
list.cursor_style = [[{\c&]] .. rgb_to_bgr('870505') .. [[&}]]
--list.selected_style = [[{\c&]] .. rgb_to_bgr('cf463c') .. [[&}]]
list.selected_style = list.list_style
list.empty_text = "No available metadata."
list.wrap = false

list.keybinds = {
    {'DOWN',        'scroll_down',          function() list:scroll_down() end,      {repeatable = true}},
    {'UP',          'scroll_up',            function() list:scroll_up() end,        {repeatable = true}},
    {'ESC',         'close_browser',        function() list:close() end,            {}},
    {'ENTER',       'execute_line',         execute_line,                           {}},
    {'LEFT',        'change_overlay_left',  function() change_overlay('left') end,  {}},
    {'RIGHT',       'change_overlay_right', function() change_overlay('right') end, {}},
    {'CTRL+LEFT',   'goto_list_top',        goto_list_top,                          {}},
    {'CTRL+RIGHT',  'goto_list_bottom',     goto_list_bottom,                       {}},
    {'SHIFT+bs',    'collapse_all_comms',   collapse_all_comms,                  {}},
}
-- table.insert(list.keybinds, {'ENTER', 'execute_line', execute_line, {} })
-- table.insert(list.keybinds, {'LEFT', 'execute_line', function() change_overlay('left') end, {} })
-- table.insert(list.keybinds, {'RIGHT', 'execute_line', function() change_overlay('left') end, {} })


local function toggle_metadata()
    list:toggle()
end

mp.add_key_binding(nil, "toggle-metadata-page", toggle_metadata)
mp.register_event('file-loaded', refresh_metadata) -- þarf að vera file-loaded frekar en start-file til að mpv sé búið að loada local file metadatað 
mp.register_event('start-file', function() current_infojson = 'No infojson found' end)
