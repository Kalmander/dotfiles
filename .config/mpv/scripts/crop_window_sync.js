pipes = []
os_clock_delta = null
// ATH bæta líka við að nýju gluggarnir keyra engin scripts STJARNA STJARNA keyra örfá svo starta með engum og velja ´serstaklega úr td þetta




// Pipe funcs ------------------------------------------------------------------------------
function add_pipe(pipe_name) {
    pipes.push(pipe_name)
}

function to_pipes(mpv_command) {
    for (i = 0; i < pipes.length; i++) {
        mp.command('run "cmd" "/c" "echo ' + mpv_command + ' > ' + pipes[i] + '"');
    }
}






// Called in main window --------------------------------------------------------------------
function sync_all_pipes_to_delta() {
    os_clock_delta = Date.now() - mp.get_property_number('time-pos')*1000
    to_pipes('script-message set-time-delta-to ' + os_clock_delta)
    to_pipes('script-message seek-to-delta')
}





// CALLED BY SCRIPT MESSAGE IN PIPES ----------------------------------------------------
function set_delta_to(this_value) {
    os_clock_delta = this_value
}

function seek_to_delta() {
    mp.command('no-osd seek ' + ((Date.now() - os_clock_delta)*0.001 + 0.001) + ' absolute exact')
}






// Key bindings and script messages ----------------------------------------------------
mp.add_key_binding(null, 'sync-all-pipes-to-delta', sync_all_pipes_to_delta)

mp.register_script_message('add-named-pipe', add_pipe)
mp.register_script_message('set-time-delta-to', set_delta_to)
mp.register_script_message('seek-to-delta', seek_to_delta)
