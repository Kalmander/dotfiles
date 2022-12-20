local utils = require 'mp.utils'
local script_dir =  mp.get_script_directory() 

playlist_view = utils.join_path(script_dir, "playlist_view.lua")
dofile(playlist_view)
