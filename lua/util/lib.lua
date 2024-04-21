local split
function split(str, ts)
    if ts == nil then return {} end

    local t = {}
    for s in string.gmatch(str, "([^" .. ts .. "]+)") do
        table.insert(t, s..ts)
    end

--     local matches = string.gmatch(str, "([^" .. ts .. "]+)")
--     for i = 1, #matches do
--         t[i] = matches[i]
--         i = i + 1
--     end

    return t
end

local test = split("aiu。eo。ie", "。")
print(vim.inspect(test))

return {
    split = split,
}
