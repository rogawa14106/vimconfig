--TODO
--cp
--mv
--visual operation

local helper = require("../helper")

-- main class
local new_Eim
new_Eim = function()
    --## private
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

    local mkfile
    local mkdir
    local rm
    local rmfile
    local rmdir
    local rmdir_recurcive
    local rename
    local cp
    local mv
    local chcwd

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
        -- n, <Enter>
        local on_enter = function()
            local current_line = vim.fn.line(".")
            local lines = vim.api.nvim_buf_get_lines(self.bufnrs.main, current_line - 1, current_line, false)
            local line = lines[1]
            if string.match(line, ".+/") then
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
        end

        -- n, %
        mkfile = function()
            local filepath = helper.highlightInput("info", "[Eim] Enter filename > ", self.cwd .. "/")
            local is_extension = string.match(filepath, "[^/].+%..+$")
            if is_extension == nil then
                local confirm_msg = '[Eim] filename has no extension. type "y" to continue > '
                local confirm = helper.highlightInput("warning", confirm_msg)
                if confirm ~= "y" then
                    helper.highlightEcho("info", "[Eim] mkfile was canceled")
                    return
                end
            end

            local fd = vim.loop.fs_open(filepath, "w", 438)
            if fd == nil then
                helper.highlightEcho("error", "[Eim] mkfile fail. can't open specified file")
                return
            else
                vim.loop.fs_write(fd, "")
                vim.loop.fs_close(fd)
                scan_ls(self.cwd)
                helper.highlightEcho("info", "[Eim] mkfile success >> " .. filepath)
            end
        end

        mkdir = function()
            local dirpath = helper.highlightInput("info", "[Eim] Enter dirname > ", self.cwd .. "/")
            vim.fn.mkdir(dirpath)

            scan_ls(self.cwd)
            helper.highlightEcho("info", "[Eim] mkdir success >> " .. dirpath)
        end

        -- n, D
        rm = function()
            local current_line = vim.fn.line(".")
            local lines = vim.api.nvim_buf_get_lines(self.bufnrs.main, current_line - 1, current_line, false)
            local line = lines[1]
            -- branch type
            local type
            if string.match(line, "/$") == nil then
                type = 'file'
            elseif string.match(line, "^%.%./$") == nil then
                type = 'directory'
            else
                helper.highlightEcho("warning", "[Eim] no such file or directory")
                return
            end

            -- filepath
            local path = self.cwd .. "/" .. line

            -- delete confirmation
            local confirm_msg = '[Eim] delete "' .. line .. '". type "y" to continue > '
            local confirm = helper.highlightInput("info", confirm_msg)
            if confirm ~= "y" then
                helper.highlightEcho("warning", "[Eim] rmfile was canceled")
                return
            end

            if type == 'file' then
                rmfile(path)
            elseif type == 'directory' then
                rmdir(path)
            end
        end

        rmfile = function(path)
            local result = vim.fn.delete(path)
            if result == 0 then
                helper.highlightEcho("info", "[Eim] rmfile success")
            else
                helper.highlightEcho("info", "[Eim] rmfile fail")
            end
            scan_ls(self.cwd)
        end

        rmdir = function(path)
            local luv = vim.loop
            local result = luv.fs_rmdir(path)
            if result == true then
                scan_ls(self.cwd)
            else
                if get_cwd() .. "/" == path then
                    helper.highlightEcho("error", "[Eim] rmdir fail. specified directory is cwd")
                else
                    helper.highlightEcho("error", "[Eim] rmdir fail. specified directory is in use or not empty")
                end
            end
        end

        rmdir_recurcive = function(path)
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
                        if type == 'directory' then
                            self.ls.dirs[#self.ls.dirs + 1] = name
                        elseif type == 'file' then
                            self.ls.files[#self.ls.files + 1] = name
                        end
                    end
                end
            end)

            -- async scan
            vim.fn.win_gotoid(self.winids.main)
            luv.fs_scandir(path, cb)
        end

        rename = function()
            local current_line = vim.fn.line(".")
            local lines = vim.api.nvim_buf_get_lines(self.bufnrs.main, current_line - 1, current_line, false)
            local line = lines[1]
            local frompath = self.cwd .. "/" .. line
            local topath = helper.highlightInput("info", "[Eim] Enter renamed path > ", frompath)
            local result = vim.fn.rename(frompath, topath)
            if result == -1 then
                helper.highlightEcho("error", "[Eim] rename fail")
            else
                scan_ls(self.cwd)
                helper.highlightEcho("info", "[Eim] rename success")
            end
        end

        chcwd = function()
            vim.cmd("cd " .. self.cwd)
            helper.highlightEcho("info", "[Eim] change current working directory to " .. '"' .. self.cwd .. '"')
        end

        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", '<Enter>', '', {
            noremap = true,
            callback = on_enter,
        })

        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "%", '', {
            noremap = true,
            callback = mkfile,
        })

        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "d", '', {
            noremap = true,
            callback = mkdir,
        })

        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "D", '', {
            noremap = true,
            callback = rm,
        })

        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "R", '', {
            noremap = true,
            callback = rename,
        })

        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "cd", '', {
            noremap = true,
            callback = chcwd,
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
                    end
                end
            end
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
vim.api.nvim_create_user_command("Eim", init_eim, {
    bang = true
})

--# create keymap that launch Fim
vim.api.nvim_set_keymap("n", '<leader>e', '', {
    noremap = true,
    callback = init_eim,
})
