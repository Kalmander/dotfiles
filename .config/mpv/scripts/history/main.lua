local utils = require 'mp.utils'
local script_dir =  mp.get_script_directory() 

history  = utils.join_path(script_dir, "history.lua")
history_list  = utils.join_path(script_dir, "history-list.lua")
phistory_list = utils.join_path(script_dir, "history-list-playlists.lua")

dofile(history)
dofile(history_list)
dofile(phistory_list)
