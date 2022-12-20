local utils = require 'mp.utils'
local msg = require 'mp.msg'

local metadataLog = mp.command_native({"expand-path", "~~/mpvMetadata.log"})
local misc_script = mp.command_native({"expand-path", "~~/scripts/miscellaneous_scripts/miscellaneous.lua"})
package.path = misc_script .. ";" .. package.path
local misc = require 'miscellaneous'

local jobs_queue = {} -- queue of thumbnail jobs
local failed = {} -- list of failed output paths, to avoid redoing them
local script_id = mp.get_script_name() .. utils.getpid()
local metadata_table = misc:read_metadata_log(metadataLog)
local video_extensions = { "mkv", "webm", "mp4", "avi", "wmv" }

function is_video(input_path)
    local extension = string.match(input_path, "%.([^.]+)$")
    if extension then
        extension = string.lower(extension)
        for _, ext in ipairs(video_extensions) do
            if extension == ext then
                return true
            end
        end
    end
    return false
end

function get_file_duration(path)
    if path:match('http') ~= nil then -- möuglega breyta í að gá sérstaklega hvort youtube og kannski vimeo 
                                        -- þúst því veit ekki alveg hvað youtube-dl kann að sækja dur á
        args = {
            "yt-dlp", 
            '--ignore-config',
            '--get-filename',
            '-o', '%(duration)s %(upload_date)s',
            path
        }
        command_native_output = mp.command_native({
            name = "subprocess",
            capture_stdout = true,
            args = args}
        )

        dur_and_date = misc.splitstring(command_native_output['stdout'])
        return dur_and_date[1], dur_and_date[2]
    else
        if not is_video(path) then return '' end
        args = {"ffprobe", "-v", "quiet", "-of", "csv=p=0", "-show_entries", "format=duration", path}
        command_native_output = mp.command_native({
            name = "subprocess",
            capture_stdout = true,
            args = args}
        )
        return command_native_output['stdout']
    end
end




function generate_duration(durations_job)
    if metadata_table[durations_job.output_path] ~= nil then return true end -- ATH hvað ef lengd skjalsins hefur breyst? eeeh whatever
    local dir, _ = utils.split_path(durations_job.output_path)
    local tmp_output_path = utils.join_path(dir, script_id)

    duration, date = get_file_duration(durations_job.input_path)

    if (duration == nil) then return false end
    duration = tonumber(duration)
    if (duration == nil) then return false end
    duration_secs = math.floor(duration)
    
    local record = ('duration=%d  |  upload_date=%s  |  thumbnail_path=%s  |\n'):format(duration_secs, date, durations_job.output_path)
    local metadataLogAdd = io.open(metadataLog, 'a+')
    metadataLogAdd:write(record)
    metadataLogAdd:close()
    durations_job.generator_output = record
    metadata_table[durations_job.output_path] = {
        duration=duration_secs,
        date=date
    }
    return true

end

function handle_events(wait)
    e = mp.wait_event(wait)
    while e.event ~= "none" do
        if e.event == "shutdown" then
            return false
        elseif e.event == "client-message" then
            if e.args[1] == "push-metadata-front" or e.args[1] == "push-metadata-back" then
                
                local durations_job = {
                    requester = e.args[2],
                    input_path = e.args[3],
                    output_path = e.args[4],
                    generator_output = ''
                }
                if e.args[1] == "push-metadata-front" then
                    jobs_queue[#jobs_queue + 1] = durations_job
                else
                    table.insert(jobs_queue, 1, durations_job)
                end
            end
        end
        e = mp.wait_event(0)
    end
    return true
end

local registration_timeout = 2 -- seconds
local registration_period = 0.2

-- shitty custom event loop because I can't figure out a better way
-- works pretty well though
function mp_event_loop()
    local start_time = mp.get_time()
    local sleep_time = registration_period
    local last_broadcast_time = -registration_period
    local broadcast_func
    broadcast_func = function()
        local now = mp.get_time()
        if now >= start_time + registration_timeout then
            mp.commandv("script-message", "duration-generator-broadcast", mp.get_script_name())
            sleep_time = 1e20
            broadcast_func = function() end
        elseif now >= last_broadcast_time + registration_period then
            mp.commandv("script-message", "duration-generator-broadcast", mp.get_script_name())
            last_broadcast_time = now
        end
    end

    while true do
        if not handle_events(sleep_time) then return end
        broadcast_func()
        while #jobs_queue > 0 do
            local durations_job = jobs_queue[#jobs_queue]
            if not failed[durations_job.output_path] then
                if generate_duration(durations_job) then
                    mp.commandv("script-message-to", durations_job.requester, "metadata-generated", durations_job.generator_output)
                else
                    failed[durations_job.output_path] = true
                end
            end
            jobs_queue[#jobs_queue] = nil
            if not handle_events(0) then return end
            broadcast_func()
        end
    end
end
