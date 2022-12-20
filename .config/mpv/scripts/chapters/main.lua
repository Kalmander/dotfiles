local utils = require 'mp.utils'
local script_dir =  mp.get_script_directory() 

chapter_list = utils.join_path(script_dir, "chapter-list.lua")
manage_chapters = utils.join_path(script_dir, "manage-chapters.lua")

dofile(chapter_list)
dofile(manage_chapters)
