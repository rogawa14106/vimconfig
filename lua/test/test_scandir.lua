Path_table = {}
ScandirRecursive = function(path)
    local uv = vim.loop
    local cb = function(err, fs)
        if err ~= nil then
            print(err)
            return
        end
        local luv = vim.loop
        while true do
            local name, type = luv.fs_scandir_next(fs)
            if name == nil then
                break
            else
                local filename = path .. "/" .. name
                if type == 'directory' then
                    --print('directory! ' .. name)
                    ScandirRecursive(filename)
                else
                    Path_table[#Path_table + 1] = filename
                    --print(#Path_table, filename)
                    --print(path .. "/" .. name)
                end
            end
        end
    end

    local fs = uv.fs_scandir(path, cb)
end

print('--------- start -----------')
local path = vim.fn.getcwd()
ScandirRecursive(path)
--Path_tableが完成してからではなく、今のパステーブルの状態を参照できるようにする。
