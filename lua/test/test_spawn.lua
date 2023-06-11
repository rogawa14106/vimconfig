--local uv = vim.loop
--
--uv.disable_stdio_inheritance()
--
--local stdin = uv.new_pipe()
--local stdout = uv.new_pipe()
--local stderr = uv.new_pipe()
--
--print("stdin", stdin)
--print("stdout", stdout)
--print("stderr", stderr)
--
--local options = {
    --stdio = { stdin, stdout, stderr }
--}
--
--local on_exit = function(code, signal)
    --print("exit code", code)
    --print("exit signal", signal)
--end
--
--local handle, pid = uv.spawn("dir", options, on_exit)
--
--if handle == nil then
    --print('handle is nil')
    --print("process opened", handle, pid)
    --return
--end
--
--print("process opened", handle, pid)
--
--uv.read_start(stdout, function(err, data)
    --assert(not err, err)
    --if data then
        --print("stdout chunk", stdout, data)
    --else
        --print("stdout end", stdout)
    --end
--end)
--
----uv.write(stdin, "Hello World")
--
--uv.shutdown(stdin, function()
    --print("stdin shutdown", stdin)
    --uv.close(handle, function()
        --print("process colosed", handle, pid)
    --end)
--end)



os.execute('cmd /c " dir"')








