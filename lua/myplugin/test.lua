local function split(str, d)
    local t = {}
    local i = 1
    for s in string.gmatch(str, "([^" .. d .. "]+)") do
        s = string.gsub(s, "[\\]", '/')
        t[i] = s
        i = i + 1
    end

    return t
end
local function get_dir_table()
    local cmd = "chcp 65001 | dir /s /b"
    local dir = vim.fn.system(cmd)
    local dir_table = split(dir, '\n')
    return dir_table
end

-- TODO display selector buffer
local uv = vim.loop
vim.g.stop_timer = false
vim.g.dir_t = {'test'}

local timer = uv.new_timer()
local i = 0
timer:start(1000, 250, vim.schedule_wrap(function()
    if i % 4 == 0 then
        vim.cmd("echo '-' ")
    elseif i % 4 == 1 then
        vim.cmd("echo '/' ")
    elseif i % 4 == 2 then
        vim.cmd("echo '|' ")
    else
        vim.cmd("echo '\\' ")
    end
    if i > 10 * 4 then
        timer:close()
    elseif vim.g.stop_timer == true then
        vim.cmd("echo 'task complete.' ")
        if vim.g.dir_t[1] ~= nil then
            print(vim.g.dir_t[1])
        else
            print("dir table is nil")
        end
        -- このタイミングでマップなどの機能をつける？
        timer:close()
    end
    i = i + 1
end))

--=== async ===--
local callback = uv.new_async(vim.schedule_wrap(function(dir_t)
    -- ここにファイル書き込み処理？タイマーストップ処理だけでもよさそう
    --vim.api.nvim_buf_set_lines(0, -1, -1, true, { '--test' })
    print(dir_t[1] == nil)
    vim.loop.sleep(100)
    vim.g.dir_table = dir_t
    for i = 1, #dir_t do
        vim.g.dir_table[i] = dir_t[i]
    end
    vim.g.stop_timer = true
end))

local function task(callback)
    local uv = vim.loop
    print('fetch start ...')
    -- ここにファイル取得処理を書く
    --uv.sleep(seconds * 1000)
    local cmd = "chcp 65001 | dir /s /b"
    local f = assert(io.popen(cmd, 'r'))
    local dir = assert(f:read('*a'))
    local dir_t = {}
    local i = 1
    for s in string.gmatch(dir, "([^" .. '\n' .. "]+)") do
        s = string.gsub(s, "[\\]", '/')
        dir_t[i] = s
        i = i + 1
    end
    -- ここにファイル取得処理を書く
    if dir_t[1] == nil then
        print('nil')
    else
        print('not nil' .. dir_t[1])
    end
    uv.async_send(callback, dir_t)
    return ""
end

uv.new_thread(task, callback)
