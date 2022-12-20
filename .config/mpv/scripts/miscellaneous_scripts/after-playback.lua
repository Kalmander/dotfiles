--[[
    Console notkun:
        script-message after-playback [command] {flag}
    Valid commands are:
        nothing     -   do nothing, the default, and is used to disable prior ap_commands
        sleep       -   puts the computer to sleep
        logoff      -   logs the current user off
        shutdown    -   shuts down computer after 60 seconds
        reboot      -   reboots the computer after 60 seconds
    Valid flags are:
        osd         -   displays osd message (when setting the command, not when it is executed) (default)
        no_osd      -   does not display osd message (when setting the command, not when it is executed)
]]--

msg = require 'mp.msg'
utils = require 'mp.utils'
opt = require 'mp.options'

--OPTIONS--
local ap_opts = {
    --default action
    default = "nothing",

    --set whether to output status messages to the OSD
    osd_output = true
}

local nircmd_path = '~~/nircmd.exe'
local ap_commands = {}
local current_action = "nothing"
local active = false
local timer = nil
local timer_expires_at = nil
local ON_WINDOWS = (package.config:sub(1,1) ~= '/')

function ap_osd_message(message)
    if ap_opts.osd_output then
        mp.osd_message(message, 2)
    end
end

function ap_set_action(action, flag)
    msg.debug('flag = "' .. tostring(flag) .. '"')
    
    --disables or enables the osd for the duration of the function if the flags are set
    local osd = ap_opts.osd_output
    if flag == 'osd' then
        ap_opts.osd_output = true
    elseif flag == 'no_osd' then
        ap_opts.osd_output = false
    end

    if active or action ~= "nothing" then
        msg.info('after playback: ' .. action)
        ap_osd_message('after playback: ' .. action)
    end

    if ON_WINDOWS then 
        ap_commands = {nircmd_path}
        active = true

        if action == 'sleep' then
            ap_commands[2] = "standby"

        elseif action == "logoff" then
            ap_commands[2] = "exitwin"
            ap_commands[3] = "logoff"

        elseif action == "shutdown" then
            ap_commands[2] = "initshutdown"
            --ap_commands[3] = "60 seconds before system shuts down"
            --ap_commands[4] = "60"

        elseif action == "reboot" then
            ap_commands[2] = "initshutdown"
            ap_commands[3] = "60 seconds before system reboots"
            ap_commands[4] = "60"
            ap_commands[5] = "reboot"

        elseif action == "nothing" then
            active = false

        else
            msg.warn('unknown action "' .. action .. '"')
            ap_osd_message('after-playback: unknown action')
            action = current_action
        end
    else
        active = true

        if action == 'sleep' then
            -- ap_commands[2] = "standby"
            ap_commands = {'systemctl', 'suspend'}
    
        elseif action == "logoff" then
            -- ap_commands[2] = "exitwin"
            -- ap_commands[3] = "logoff"
            ap_commands = {'halt'}
    
        elseif action == "shutdown" then
            -- ap_commands[2] = "initshutdown"
            --ap_commands[3] = "60 seconds before system shuts down"
            --ap_commands[4] = "60"
            ap_commands = {'shutdown', 'now'}
    
        elseif action == "reboot" then
            -- ap_commands[2] = "initshutdown"
            -- ap_commands[3] = "60 seconds before system reboots"
            -- ap_commands[4] = "60"
            -- ap_commands[5] = "reboot"
            ap_commands = {'reboot'}
    
        elseif action == "nothing" then
            active = false
    
        else
            msg.warn('unknown action "' .. action .. '"')
            ap_osd_message('after-playback: unknown action')
            action = current_action
        end
    end    

    ap_opts.osd_output = osd
    current_action = action
end


function ap_run_action()
    if not active then return end;

    msg.info('executing command "' .. current_action .. '"')

    mp.command_native({
        name = 'subprocess',
        playback_only = false,
        args = ap_commands
    })
end


local function toggle_shutdown_after_playback()
    if active == false then 
        ap_set_action('shutdown')
    else
        ap_set_action('nothing')
    end
end


local function shutdown_now()
    local cmds = {
        nircmd_path, 
        'initshutdown'
    }
    mp.command_native({
        name = 'subprocess',
        playback_only = false,
        args = cmds
    })
end

local function secsToMins(secs) 
	    return math.floor(secs / 60) .. " minutes and " .. (secs % 60) .. " seconds"
end

local function timer_add_5_mins()
    if timer_expires_at == nil then
        timer_expires_at = os.time() + 5*60
    else
        timer:kill()
        timer_expires_at = timer_expires_at + 5*60
    end
    local msg = 'Shutdown timer set for ' .. os.date('%H:%M', math.floor(timer_expires_at)) .. ' (' .. secsToMins(timer_expires_at - os.time()) .. ' from now)'

    timer = mp.add_timeout(timer_expires_at - os.time(), shutdown_now)
    print(msg)
    mp.osd_message(msg, 5)
end


local function disable_timer()
    local msg
    if timer ~= nil then
        timer:kill()
        timer = nil
        timer_expires_at = nil
        msg = 'Shutdown timer was disabled'
    else 
        msg = 'No shutdown timer to disable'
    end

    print(msg)
    mp.osd_message(msg)
end

local function print_time_left()
    local msg
    if timer_expires_at == nil then 
        msg = 'The shutdown timer is not active'
    else 
        msg = 'The shutdown timer is set for ' .. os.date('%H:%M', math.floor(timer_expires_at)) .. ' (' .. secsToMins(timer_expires_at - os.time()) .. ' from now)'
    end

    print(msg)
    mp.osd_message(msg, 5)
end

mp.add_key_binding(nil, 'shutdowntimer-add-5mins', timer_add_5_mins)
mp.add_key_binding(nil, 'disable-shutdowntimer', disable_timer)
mp.add_key_binding(nil, 'print-shutdowntimer-left', print_time_left)

mp.register_event('end-file', ap_run_action)
mp.register_script_message('after-playback', ap_set_action)
mp.add_key_binding(nil, 'toggle-shutdown-after-playback', toggle_shutdown_after_playback)
