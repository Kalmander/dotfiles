local chapters_scripts = mp.command_native({"expand-path", "~~/scripts/chapters/?.lua"})
local misc_script = mp.command_native({"expand-path", "~~/scripts/miscellaneous_scripts/miscellaneous.lua"})
package.path = chapters_scripts .. ";" .. misc_script .. ";" .. package.path

local mp = require 'mp'
local list = require "scroll-list-chapters"
local misc = require 'miscellaneous'

local function toggle_chapterlist()
    list.header = "Chapter List \\N ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾"
    list:update()
    list:toggle() 
end
--jump to the selected chapter
local function open_chapter()
    if list.list[list.selected] then
        mp.set_property_number('chapter', list.selected - 1)
    end
end

--dynamic keybinds to bind when the list is open
list.keybinds = {
    {'DOWN', 'scroll_down', function() list:scroll_down() end, {repeatable = true}},
    {'UP', 'scroll_up', function() list:scroll_up() end, {repeatable = true}},
    {'ENTER', 'open_chapter', open_chapter, {} },
    {'ESC', 'close_browser', function() list:close() end, {}}
}

--update the list when the current chapter changes
mp.observe_property('chapter', 'number', function(_, curr_chapter)
    list.list = {}
    local chapter_list = mp.get_property_native('chapter-list', {})
    for i = 1, #chapter_list do
        local item = {}
        if (i-1 == curr_chapter) then
            item.style = [[{\c&H33ff66&}]]
        end

        item.ass = list.ass_escape('[' .. misc.disp_time(chapter_list[i].time) .. '] ' .. chapter_list[i].title)
        list.list[i] = item
    end
    list:update()
end)

mp.add_key_binding(nil, "toggle-chapter-browser", toggle_chapterlist)
