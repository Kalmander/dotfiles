local utils = require 'mp.utils'
local script_dir =  mp.get_script_directory() 

bookmarks  = utils.join_path(script_dir, "bookmarks.lua")
file_browser  = utils.join_path(script_dir, "file-browser.lua")
metadata  = utils.join_path(script_dir, "display-metadata.lua")

dofile(bookmarks)
dofile(file_browser)
dofile(metadata)
