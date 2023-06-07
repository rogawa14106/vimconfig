let cmd = "chcp 65001 | dir /s /b"
let job_id = jobstart([cmd], {'on_stdout': 'MycallBack'})

function! MycallBack(channel, data, name) abort
    echo a:channel . ", " .  a:data . ", " . a:name
endfunction


"call jobchannel
