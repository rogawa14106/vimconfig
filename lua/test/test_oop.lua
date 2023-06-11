--local Dog = {
--size = 0,
--grow = function(self, n)
--self.size = self.size + n
--end,
--}
--
--function Dog.init (size)
--local dog = {
--size = size,
--grow = Dog.grow
--}
--return dog
--end
--
--local d1 = Dog.init(0)
--local d2 = Dog.init(5)
--
--print(d1.size, d2.size)
--
--d1.grow(d1,10)
--d2.grow(d2,15)
--
--print(d1.size, d2.size)

--local new_Dog = function(init_size)
---- init self
--local self = {
--size = init_size
--}
--
---- methods
--local grow = function(n)
--self.size = self.size + n
--end
--
---- getter
--local get_size = function()
--return self.size
--end
--
--return {
--grow = grow,
--get_size = get_size,
--}
--end
--
--local d1 = new_Dog(0)
--local d2 = new_Dog(5)
--print(d1.get_size(), d2.get_size())
--d1.grow(5)
--d2.grow(15)
--print(d1.get_size(), d2.get_size())

--local new_dirscaner = function()
    --local self = {
        --uv = vim.loop,
        --cnt = 1,
        --path_table = {},
    --}
    ---- Must be a global function for recursive calls?
    --ScandirRecursive = function(dir_path)
        --local fs, err = self.uv.fs_scandir(dir_path)
        --if err ~= nil then
            --print('catch error', err)
            --return
        --end
        --while true do
            --local name, type = self.uv.fs_scandir_next(fs)
            --if name == nil then
                --return
            --end
            --if type == 'file' then
                --self.path_table[self.cnt] = dir_path .. "/" .. name
                --self.cnt = self.cnt + 1
            --elseif type == 'directory' then
                --ScandirRecursive(dir_path .. '/' .. name)
            --end
        --end
    --end
--
    --local get_path_table = function() return self.path_table end
    --return {
        --scandirRecursive = ScandirRecursive,
        --get_path_table = get_path_table,
    --}
--end

--local is_stop = false
Path_table = {}
local uv = vim.loop
local timer = uv.new_timer()
local sec = 0
local is_stop = false
local timercb = function()
    if is_stop then
        print(sec, #Path_table)
        timer:close()
    end
    print(sec)
    sec = sec + 1
end

--local path_table = {}
local task = function(cb, root_path)
    local dir_table = {}
    ScandirRecursive = function(dir_path, cnt)
        local fs, err = vim.loop.fs_scandir(dir_path)
        if err ~= nil then
            return
        end
        while true do
            local name, type = vim.loop.fs_scandir_next(fs)
            if name == nil then
                return
            end
            if type == 'file' then
                local file_path = dir_path .. "/" .. name
                dir_table[cnt] = file_path
                cnt = cnt + 1
            elseif type == 'directory' then
                ScandirRecursive(dir_path .. '/' .. name, cnt)
            end
        end
    end
    ScandirRecursive(root_path, 1)
    vim.loop.async_send(cb, dir_table)
end

local taskend = uv.new_async(vim.schedule_wrap(function (dir_table)
    print(dir_table)
    is_stop = true
end))

local path = 'C:/Users/rogawa/AppData/Local'
uv.new_thread(task, taskend, path)
uv.timer_start(timer, 0, 1000, timercb)
