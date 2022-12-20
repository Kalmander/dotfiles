
local function search_in_subs(mes)
    tracks_count = mp.get_property_number('track-list/count')
    for i=0, tracks_count-1 do 
        local track_type = mp.get_property(string.format("track-list/%d/type", i))
        local track_index = mp.get_property_number(string.format("track-list/%d/ff-index", i))
        local track_selected = mp.get_property(string.format("track-list/%d/selected", i))
        local track_lang = mp.get_property(string.format("track-list/%d/lang", i))
        local track_external = mp.get_property(string.format("track-list/%d/external", i))
        local track_external_filepath = mp.get_property(string.format("track-list/%d/external-filename", i))
        local track_codec = mp.get_property(string.format("track-list/%d/codec", i))

        print(' ')
        print(' ')
        print(track_type)
        print(track_index)
        print(track_selected)
        print(track_lang)
        print(track_external)
        print(track_external_filepath)
        print(track_codec)
        print(' ')
        print(' ')

        if track_external ~= 'yes' then 
            print('Sub track is not external rip')
            return 
        end

        subs_file = io.open(track_external_filepath, 'r')

        line_count = 0
        found = false
        for line in subs_file:lines() do 
            line_count = line_count + 1
            if line:match(mes) ~= nil then 
                print('Found at line ' .. line_count)
                found = true
                break
            end
        end

        subs_file:close()

    end

    -- líklega enda á einhvers konar "close console" command?
end

mp.register_script_message('search-in-subs', search_in_subs)
mp.add_key_binding(nil,'open-search-in-subs', function()
    mp.commandv('script-message-to', 'console', 'type', 'script-message search-in-subs ')
end)
