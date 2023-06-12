local helper = require("../helper")

-- main class
local new_Eim
new_Eim = function()
    --## plivate
    --# def member variables
    local self = {
        helper = helper,
        winids = {
            main = nil,
            info = nil,
        },
        bufnrs = {
            main = nil,
            info = nil,
        },
        ls = {
            files = {},
            dirs = {},
        },
        cwd = '',
    }

    --# def methods
    local init
    local create_ui
    local create_win
    local delete_win
    local delete_win_all
    local write_lines
    local create_keymap
    local scan_ls
    local update_info
    local get_cwd

    -- initialize
    init = function(config_main, config_info)
        -- create ui
        self.winids.main = vim.g.eim_main_winid
        self.bufnrs.main = vim.g.eim_main_bufnr
        self.winids.info = vim.g.eim_info_winid
        self.bufnrs.info = vim.g.eim_info_bufnr
        create_ui(config_main, config_info)

        -- set keymap
        create_keymap()
    end

    -- ui related
    create_ui = function(config_main, config_info)
        -- create eim window
        local is_shown = (#vim.fn.win_findbuf(self.bufnrs.main) > 0) and (#vim.fn.win_findbuf(self.bufnrs.info) > 0)
        local current_bufnr = vim.fn.bufnr()
        local is_current = (current_bufnr == self.bufnrs.main) or (current_bufnr == self.bufnrs.info)
        if is_shown and is_current then
            delete_win_all()
            return
        elseif is_shown then
            vim.fn.win_gotoid(self.winids.main)
        else
            local win_main = create_win(config_main.window, self.bufnrs.main, self.winids.main)
            self.bufnrs.main = win_main.bufnr
            self.winids.main = win_main.winid
            vim.g.eim_main_bufnr = win_main.bufnr
            vim.g.eim_main_winid = win_main.winid

            local win_info = create_win(config_info.window, self.bufnrs.info, self.winids.info)
            self.bufnrs.info = win_info.bufnr
            self.winids.info = win_info.winid
            vim.g.eim_info_bufnr = win_info.bufnr
            vim.g.eim_info_winid = win_info.winid
        end

        -- set colors
        vim.api.nvim_win_set_option(self.winids.main, 'winhl', 'Normal:' .. config_main.color)
        vim.api.nvim_win_set_option(self.winids.info, 'winhl', 'Normal:' .. config_info.color)
        vim.cmd("hi! def link EimDirectory Title")
        vim.fn.clearmatches(self.winids.main)
        vim.fn.matchadd("EimDirectory", '\\v.+/$', 10, 5, { window = self.winids.main })

        -- write information
        self.cwd = get_cwd()
        update_info()
        --update_info()

        --show list segments
        self.dir_list = scan_ls(self.cwd)
    end

    delete_win_all = function()
        delete_win(self.winids.main, self.bufnrs.main)
        delete_win(self.winids.info, self.bufnrs.info)
    end

    delete_win = function(winid, bufnr)
        if (winid ~= nil) and (#vim.fn.win_findbuf(bufnr) > 0) then
            vim.api.nvim_win_close(winid, true)
        end
    end

    create_win = function(win_config, g_bufnr, g_winid)
        local bufnr
        local winid
        if g_bufnr == nil then
            -- target buffer has not been opend since vim launched
            bufnr = vim.api.nvim_create_buf(false, true)
        else
            bufnr = g_bufnr
        end

        if (g_winid == nil) or (#vim.fn.win_findbuf(bufnr) < 1) then
            -- target window has not been opend since vim launched
            -- or not found target buffer on current window
            winid = vim.api.nvim_open_win(bufnr, win_config.focusable, win_config)
            return { bufnr = bufnr, winid = winid }
        else
            return { bufnr = bufnr, winid = g_winid }
        end
    end

    create_keymap = function()
        --normal
        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", '<Enter>', '', {
            noremap = true,
            callback = function()
                local current_line = vim.fn.line(".")
                local lines = vim.api.nvim_buf_get_lines(self.bufnrs.main, current_line - 1, current_line, false)
                local line = lines[1]
                if string.match(line, ".+/") then
                    print(line)
                    if line == "../" then
                        self.cwd = string.gsub(self.cwd, "/[^/]+$", "")
                        if self.cwd == "C:" then
                            self.cwd = "C:/"
                        end
                    else
                        if self.cwd == "C:/" then
                            self.cwd = "C:"
                        end
                        self.cwd = self.cwd .. "/" .. string.gsub(line, "/", "")
                    end
                    update_info()
                    scan_ls(self.cwd)
                else
                    delete_win_all()
                    vim.cmd("e " .. self.cwd .. "/" .. line)
                end
            end,
        })
    end

    get_cwd = function()
        return string.gsub(vim.fn.getcwd(), '\\', '/')
    end

    update_info = function()
        write_lines("info", 0, -1, { "cwd: " .. self.cwd })
        vim.fn.win_gotoid(self.winids.main)
    end

    scan_ls = function(cwd)
        self.ls.files = {}
        self.ls.dirs = { "../" }
        write_lines("main", 0, -1, self.ls.dirs)
        local luv = vim.loop
        local cb = vim.schedule_wrap(function(err, fs)
            if err ~= nil then
                --print(err)
                return
            end
            while true do
                local name, type = luv.fs_scandir_next(fs)
                if name == nil then
                    break
                else
                    print(name .. "------------------------------")
                    for k, v in pairs(luv.fs_lstat(self.cwd .. "/" .. name)) do
                        print(k, v)
                    end
                    if type == 'directory' then
                        self.ls.dirs[#self.ls.dirs + 1] = name
                        write_lines("main",
                            #self.ls.dirs - 1,
                            #self.ls.dirs - 1,
                            { name .. "/" }
                        )
                    elseif type == 'file' then
                        self.ls.files[#self.ls.files + 1] = name
                        write_lines(
                            "main",
                            #self.ls.dirs + #self.ls.files - 1,
                            #self.ls.dirs + #self.ls.files - 1,
                            { name }
                        )
                    --elseif type == 'link' then
                    -- synbolic links
                    end
                end
            end
            vim.cmd('echo "' .. #self.ls.dirs .. '"')
        end)

        -- async scan
        vim.fn.win_gotoid(self.winids.main)
        luv.fs_scandir(cwd, cb)
    end

    write_lines = function(target, startl, endl, lines)
        vim.fn.win_gotoid(self.winids[target])
        vim.api.nvim_buf_set_option(self.bufnrs[target], 'modifiable', true)
        vim.api.nvim_buf_set_option(self.bufnrs[target], 'readonly', false)
        vim.api.nvim_buf_set_lines(self.bufnrs[target], startl, endl, false, lines)
        vim.api.nvim_buf_set_option(self.bufnrs[target], 'modifiable', false)
        vim.api.nvim_buf_set_option(self.bufnrs[target], 'readonly', true)
    end

    -- ##public
    return {
        init = init,
    }
end

--実際の値を入れていく。
local init_eim
init_eim = function()
    --## new eim
    local eim               = new_Eim()

    --## ui config
    local lines             = vim.opt.lines:get()
    local columns           = vim.opt.columns:get()
    local eim_height        = math.floor(lines / 2)
    local eim_width         = math.floor(columns / 2)

    -- offset
    local offset_border     = 1
    local offset_statusline = 2
    local offset_col        = 1
    local offset_row        = 0

    --# main window config
    local main_height       = eim_height
    local main_width        = eim_width
    local main_row          = lines - main_height - offset_border * 2 - offset_statusline - offset_row
    local main_col          = columns - main_width - offset_border * 2 - offset_col
    local border_chars_main = {
        "|", "-", "|", "|",
        "'", "-", "`", "|",
    }
    local win_config_main   = {
        width     = main_width,
        height    = main_height,
        col       = main_col,
        row       = main_row,
        border    = border_chars_main,
        focusable = true,
        style     = 'minimal',
        relative  = 'editor',
    }
    local config_main       = {
        window = win_config_main,
        color = "CursorLineNr",
    }

    --# information window config
    local info_height       = 1
    local info_width        = eim_width
    local info_row          = main_row - info_height - offset_border
    local info_col          = main_col
    local border_chars_info = {
        ".", "-", ".", "|",
        "", "", "", "|",
    }
    local win_config_info   = {
        width     = info_width,
        height    = info_height,
        col       = info_col,
        row       = info_row,
        border    = border_chars_info,
        focusable = false,
        style     = 'minimal',
        relative  = 'editor',
    }

    local config_info       = {
        window = win_config_info,
        color = "TabLineSel",
    }
    eim.init(config_main, config_info)
end

--# create Fim command
vim.api.nvim_create_user_command("Eim", init_eim, { bang = true })

--# create keymap that launch Fim
vim.api.nvim_set_keymap("n", '<leader>e', '', {
    noremap = true,
    callback = init_eim,
})
