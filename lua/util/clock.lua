--# write current date time to clock buffer.{{{
local write_time = function()
    local datetime = os.date("*t")
    local lines = {
        datetime.year ..
        "/" ..
        string.format("%02d", datetime.month) ..
        "/" ..
        string.format("%02d", datetime.day) ..
        " " ..
        string.format("%02d", datetime.hour) ..
        ":" ..
        string.format("%02d", datetime.min),
    }
    vim.api.nvim_buf_set_option(vim.g.floatClock_bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_option(vim.g.floatClock_bufnr, 'readonly', false)
    vim.api.nvim_buf_set_lines(vim.g.floatClock_bufnr, 0, -1, false, lines)
    --vim.api.nvim_buf_call(vim.g.floatClock_bufnr, function() vim.cmd(1 .. "right " .. 16 ) end)
    vim.api.nvim_buf_set_option(vim.g.floatClock_bufnr, 'modifiable', false)
    vim.api.nvim_buf_set_option(vim.g.floatClock_bufnr, 'readonly', true)
end
-- }}}
--# start timer{{{
local timer
local clock_start = function(delay)
    local uv = vim.loop
    timer = uv.new_timer()
    local cb = vim.schedule_wrap(function()
        if #vim.fn.win_findbuf(vim.g.floatClock_bufnr) < 1 then
            timer:close()
        end
        write_time()
    end)
    uv.timer_start(timer, delay, 60000, cb)
end
-- }}}
--# create clock buffer & window{{{
local create_clock_win = function(win_config)
    if vim.fn.exists('floatClock_bufnr') == 0 then
        vim.g.floatClock_bufnr = vim.api.nvim_create_buf(false, true)
    end

    if #vim.fn.win_findbuf(vim.g.floatClock_bufnr) < 1 then
        vim.g.floatClock_winid = vim.api.nvim_open_win(vim.g.floatClock_bufnr, false, win_config)
    else
        --vim.api.nvim_win_close(vim.g.floatClock_winid, true)
        --vim.g.floatClock_winid = vim.api.nvim_open_win(vim.g.floatClock_bufnr, false, win_config)
        vim.api.nvim_win_set_config(vim.g.floatClock_winid, win_config)
        return
    end

    vim.api.nvim_win_set_option(vim.g.floatClock_winid, 'winhl', 'Normal:Title')

    -- autocmd
    vim.api.nvim_create_autocmd('bufwinleave', {
        callback = function()
            --print('timer auto closed!!')
            --timer:stop()
        end,
        buffer = vim.g.floatClock_bufnr,
    })

    -- timer
    write_time()
    local delay = (59 - os.date("*t").sec) * 1000 + 500
    clock_start(delay)
end
-- }}}
--# main{{{
local floatClock = function()
    local clock_sample = "1999/11/29 18:23"
    local win_width = #clock_sample
    local win_height = 1
    local row_offset = 2
    local col_offset = 0
    local bordar_offset = 0

    local win_config = {
        width     = win_width,
        col       = vim.opt.columns:get() - bordar_offset - win_width - col_offset,
        height    = win_height,
        row       = vim.opt.lines:get() - bordar_offset - win_height - row_offset,
        border    = 'none',
        focusable = false,
        style     = 'minimal',
        relative  = 'editor',
    }

    create_clock_win(win_config)
end
-- }}}
--# create command{{{
vim.api.nvim_create_user_command("Clock", floatClock, { bang = true })
-- }}}
--# create autocmd{{{
vim.api.nvim_create_augroup("placeClock", {})
vim.api.nvim_create_autocmd('vimResized', {
    group = 'placeClock',
    callback = function()
        vim.cmd('Clock')
    end,
})
-- }}}
--# display clock
vim.cmd("Clock")
