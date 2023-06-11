"let cmd = "chcp"
"let args = ["65001", "|", "dir", "/s", "/b"]
"let job_id = jobstart([cmd], {'on_stdout': 'MycallBack'})

let Shell = {}

function Shell.on_stdout(_job_id, data, event)
  call append(line('$'),
        \ printf('[%s] %s: %s', a:event, self.name, join(a:data[:-2])))
endfunction

let Shell.on_stderr = function(Shell.on_stdout)

function Shell.on_exit(job_id, _data, event)
  let msg = printf('job %d ("%s") finished', a:job_id, self.name)
  call append(line('$'), printf('[%s] BOOM!', a:event))
  call append(line('$'), printf('[%s] %s!', a:event, msg))
endfunction

function Shell.new(name, cmd)
  let object = extend(copy(g:Shell), {'name': a:name})
  let object.cmd = ['sh', '-c', a:cmd]
  let object.id = jobstart(object.cmd, object)
  $
  return object
endfunction

let instance = Shell.new('bomb',
      \ 'for i in $(seq 9 -1 1); do echo $i 1>&$((i % 2 + 1)); sleep 1; done')
