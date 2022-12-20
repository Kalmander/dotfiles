local utils = require 'mp.utils'
local script_dir =  mp.get_script_directory() 

mpv_webm = utils.join_path(script_dir, "mpv_webm.lua")
trim = utils.join_path(script_dir, "trim.lua")
dump_cache = utils.join_path(script_dir, "dump-cache.lua")

dofile(mpv_webm)
dofile(trim)
dofile(dump_cache)
