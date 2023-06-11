local load_animation =
{ {
    "--           .:-::-:",
    "--        .--:.    .-",
    "--      :--:-",
    "--   :==:.-",
}, {
    "--       .:-::-:.-",
    "--    .--:.    .---.-",
    "--  :--:          :=-",
    "-- =:.-",
}, {
    "--   .:-::-:.-",
    "-- --:.    .---.-",
    "-- :          :==:-",
    "--              .-=+-",
}, {
    "-- -::-:.          .-",
    "--     .---.-",
    "--        :==:-",
    "--          .-=+--",
}, {
    "-- :.          .-",
    "-- .---.-",
    "--    :==:-",
    "--      .-=+-    :==-",
}, {
    "--         .-",
    "-- .              .--",
    "-- ==:          :--:-",
    "--  .-=+-    :==:.-",
}, {
    "--     .         .:--",
    "--            .--:.-",
    "--          :--:-",
    "-- +-    :==:.-",
},
}
local uv = vim.loop

local timer = uv.new_timer()
local cnt = 1
local index = 1
vim.api.nvim_buf_set_lines(0, vim.fn.line('$'), -1, true, { '--' })
local lastline = vim.fn.line('$')
local timercb = vim.schedule_wrap(function()
    if index < #load_animation then
        vim.api.nvim_buf_set_lines(0, lastline, -1, true, load_animation[index])
        index = index + 1
    else
        vim.api.nvim_buf_set_lines(0, lastline, -1, true, load_animation[#load_animation])
        index = 1
    end
    if cnt > 5 * 4 then
        timer:close()
    end
    cnt = cnt + 1
end)

uv.timer_start(timer, 0, 250, timercb)
--
--     .         .:--
--            .--:.-
--          :--:-
-- +-    :==:.-
