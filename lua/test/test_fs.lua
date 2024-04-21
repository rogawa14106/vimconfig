local uv = vim.loop

local path = 'C:/Users/rogawa/AppData/Local/nvim/lua/test/test.lua'
--local fd = assert(uv.fs_open(path, 'r', 438))
--print(fd)
--local stat = assert(uv.fs_fstat(fd))
--local data = assert(uv.fs_read(fd, stat.size, 0))
--assert(uv.fs_close(fd))
--print(data)

local new_dirscaner = function()
    local self = {
        cnt = 1,
        path_table = {},
    }
    local cb = function()
        print(#self.path_table)
    end
    ScandirRecursive = function(dir_path)
        local fs, err = uv.fs_scandir(dir_path)
        if err ~= nil then
            print(err)
            return
        end
        for i = 1, 100 do
            local name, type = uv.fs_scandir_next(fs)
            if name == nil then
                return
            end
            if type == 'file' then
                self.path_table[self.cnt] = dir_path .. "/" .. name
                self.cnt = self.cnt + 1
            elseif type == 'directory' then
                ScandirRecursive(dir_path .. '/' .. name)
            end
        end
    end

    local get_path_table = function() return self.path_table end
    return {
        scandirRecursive = ScandirRecursive,
        get_path_table = get_path_table,
    }
end

print('--------------- start --------------------')
local root_path = 'C:/Users'
local dirscaner = new_dirscaner()
dirscaner.scandirRecursive(root_path)
local path_table = dirscaner.get_path_table()
print('---------------  end  --------------------')

print('length:', #path_table)
for i = 1, #path_table do
    print(path_table[i])
end

