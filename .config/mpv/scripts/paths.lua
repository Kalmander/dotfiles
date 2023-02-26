local on_windows = (package.config:sub(1,1) ~= "/")
Paths = {}


if on_windows then
    Paths.gallery = mp.command_native({"expand-path", "~~exe_dir/thumbnails_gallery/"})
else
    Paths.gallery = mp.command_native({"expand-path", "~/mpv_thumbs/thumbnails_gallery/"})
end

return Paths

