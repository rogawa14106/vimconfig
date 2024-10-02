--TODO{{{
-- }}}
-- helper{{{
local helper = require("util.helper")
-- }}}
-- main class{{{
local new_Eim
new_Eim = function()
    --## private
    --# def member variables{{{
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
        path_memory = {
            wd = "",
            lines = {},
        },
        is_help = false,
        help = {
            " == [Eim] HELP ===============================================================================================",
            " KEY  | MODE | DESCRIPTION",
            "--------------------------------------------------------------------------------------------------------------",
            " <CR> | n    | Open file or enter directory",
            " %    | n    | Create file ",
            " d    | n    | Create directory",
            " D    | n, v | Delete file or directory",
            " R    | n    | Rename file of directory",
            " y    | n, v | Store files to moving and copying",
            " m    | n    | Move files",
            " p    | n    | Copy files",
            " cd   | n    | Change vim cwd",
            " ?    | n    | show help",
            " =============================================================================================================",
        }
    }
    -- }}}
    --# def methods{{{
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
    local move
    local copy
    local chcwd
    local get_selectedlines
    local register_path
    -- }}}
    -- initialize{{{
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
    -- }}}
    -- ui related{{{
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
        vim.api.nvim_win_set_option(self.winids.main, 'signcolumn', 'no')
        vim.api.nvim_win_set_option(self.winids.info, 'signcolumn', 'no')
        vim.cmd("hi! def link EimDirectory Title")
        vim.fn.clearmatches(self.winids.main)
        vim.fn.matchadd("EimDirectory", '\\v.+/$', 10, 5, { window = self.winids.main })

        -- write information
        self.cwd = get_cwd()
        update_info()

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
    -- }}}
    -- keymap{{{
    create_keymap = function()
        -- n, <Enter>
        local on_enter = function()
            --local current_line = vim.fn.line(".")
            --local lines = vim.api.nvim_buf_get_lines(self.bufnrs.main, current_line - 1, current_line, false)
            local lines = get_selectedlines()
            local line = lines[1]
            if string.match(line, ".+/") then
                if line == "../" then
                    self.cwd = vim.fs.dirname(self.cwd)
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
            local filename = helper.highlightInput("info", "[Eim] Enter filename. " .. self.cwd .. " > ")
            if filename == "" then
                helper.highlightEcho("warning", "[Eim] mkfile was canceled")
                return
            end
            local is_extension = string.match(filename, "[^/].+%..+$")
            if is_extension == nil then
                local confirm_msg = '[Eim] filename has no extension. type "y" to continue > '
                local confirm = helper.highlightInput("warning", confirm_msg)
                if confirm ~= "y" then
                    helper.highlightEcho("warning", "[Eim] mkfile was canceled")
                    return
                end
            end

            local filepath = self.cwd .. "/" .. filename
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
            local dirpath = helper.highlightInput("info", "[Eim] Enter dirname. " .. self.cwd .. " > ")
            if dirpath == "" then
                helper.highlightEcho("warning", "[Eim] mkdir was canceled")
                return
            end
            vim.fn.mkdir(self.cwd .. "/" .. dirpath)

            scan_ls(self.cwd)
            helper.highlightEcho("info", "[Eim] mkdir success >> " .. dirpath)
        end

        -- n, D
        rm = function(line)
            --local current_line = vim.fn.line(".")
            --local lines = vim.api.nvim_buf_get_lines(self.bufnrs.main, current_line - 1, current_line, false)
            --local line = lines[1]
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
                if string.match(get_cwd(), path) ~= nil then
                    helper.highlightEcho("error", "[Eim] rmdir fail. specified directory is in use")
                else
                    local confirm_msg = '[Eim] Perform recursive deletion? type "y" to continue > '
                    local confirm = helper.highlightInput("warning", confirm_msg)
                    if confirm ~= "y" then
                        helper.highlightEcho("warning", "[Eim] rmdir was canceled")
                        return
                    end
                    rmdir_recurcive(path)
                    scan_ls(self.cwd)
                    helper.highlightEcho("info", "[Eim] recurcive rmdir success")
                end
            end
        end

        rmdir_recurcive = function(path)
            local luv = vim.loop
            local fs, fail = luv.fs_scandir(path)
            if fail ~= nil then
                print(fail)
                return
            end
            while true do
                local name, type = luv.fs_scandir_next(fs)
                if name == nil then
                    luv.fs_rmdir(path)
                    break
                else
                    if type == 'directory' then
                        rmdir_recurcive(path .. "/" .. name)
                    elseif type == 'file' then
                        vim.fn.delete(path .. "/" .. name)
                    end
                end
            end
        end

        rename = function()
            --local current_line = vim.fn.line(".")
            --local lines = vim.api.nvim_buf_get_lines(self.bufnrs.main, current_line - 1, current_line, false)
            local lines = get_selectedlines()
            local line = lines[1]
            local frompath = self.cwd .. "/" .. line

            if string.match(get_cwd(), frompath) ~= nil then
                helper.highlightEcho("error", "[Eim] rmdir fail. specified directory is in use")
                return
            end
            local topath = helper.highlightInput("info", "[Eim] Enter renamed path \n> ", frompath)
            local result = vim.fn.rename(frompath, topath)
            if result == -1 then
                helper.highlightEcho("error", "[Eim] rename fail")
            else
                scan_ls(self.cwd)
                helper.highlightEcho("info", "[Eim] rename success >> " .. frompath .. " >> " .. topath .. " ")
            end
        end

        chcwd = function()
            vim.cmd("cd " .. self.cwd)
            helper.highlightEcho("info", "[Eim] change current working directory to >> " .. self.cwd)
        end

        get_selectedlines = function()
            local linenr = { nil, nil }
            local botline = vim.fn.line(".")
            local topline = vim.fn.line("v")
            if topline > botline then
                linenr = { botline, topline }
            else
                linenr = { topline, botline }
            end
            local lines = vim.api.nvim_buf_get_lines(self.bufnrs.main, linenr[1] - 1, linenr[2], false)
            return lines
        end

        register_path = function()
            local lines = get_selectedlines()
            self.path_memory = {
                wd = self.cwd,
                lines = lines,
            }
            print(vim.inspect(self.path_memory))
        end

        move = function()
            local wd = self.path_memory.wd
            local lines = self.path_memory.lines
            for i = 1, #lines do
                local frompath = wd .. "/" .. lines[i]
                local topath = self.cwd .. "/" .. lines[i]
                local result = vim.fn.rename(frompath, topath)
                print(result)
            end
            scan_ls(self.cwd)
        end

        copy = function()
            local wd = self.path_memory.wd
            local lines = self.path_memory.lines
            for i = 1, #lines do
                local frompath = wd .. "/" .. lines[i]
                local topath = self.cwd .. "/" .. lines[i]
                local result = vim.loop.fs_copyfile(frompath, topath)
                print(result)
            end
            scan_ls(self.cwd)
        end

        -- enter
        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", '<Enter>', '', {
            noremap = true,
            callback = on_enter,
        })

        -- make
        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "%", '', {
            noremap = true,
            callback = mkfile,
        })

        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "d", '', {
            noremap = true,
            callback = mkdir,
        })

        -- remove
        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "D", '', {
            noremap = true,
            callback = function()
                local lines = get_selectedlines()
                rm(lines[1])
            end,
        })

        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "v", "D", '', {
            noremap = true,
            callback = function()
                local lines = get_selectedlines()
                for i = 1, #lines do
                    rm(lines[i])
                end
            end,
        })

        -- rename
        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "R", '', {
            noremap = true,
            callback = rename,
        })

        -- change cwd
        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "cd", '', {
            noremap = true,
            callback = chcwd,
        })

        -- registr path info to path_memory
        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "y", '', {
            noremap = true,
            callback = register_path,
        })
        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "v", "y", '', {
            noremap = true,
            callback = register_path,
        })
        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "m", '', {
            noremap = true,
            callback = move,
        })
        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "p", '', {
            noremap = true,
            callback = copy,
        })

        local show_help = function()
            if self.is_help then
                self.is_help = false
                local current_config = vim.api.nvim_win_get_config(self.winids.info)
                local width = current_config.width
                local row = current_config.row + #self.help - 1
                --                 local row = current_config.row[false] + #self.help - 1
                local col = current_config.col
                --                 local col = current_config.col[false]
                local win_conf = {
                    relative = "editor",
                    height = 1,
                    width = width,
                    row = row,
                    col = col,
                }
                vim.api.nvim_win_set_config(self.winids.info, win_conf)
                update_info()
                --vim.api.nvim_buf_set_option(self.bufnrs.info, 'height', true)
                return
            end
            self.is_help = true
            local current_config = vim.api.nvim_win_get_config(self.winids.info)
            local width = current_config.width
            print(vim.inspect(current_config))
            --             local row = current_config.row[false] - #self.help + 1
            local row = current_config.row - #self.help + 1
            --             local col = current_config.col[false]
            local col = current_config.col
            local win_conf = {
                relative = "editor",
                height = #self.help,
                width = width,
                row = row,
                col = col,
            }
            vim.api.nvim_win_set_config(self.winids.info, win_conf)
            write_lines("info", 0, -1, self.help)
            vim.cmd("redraw")
            vim.fn.win_gotoid(self.winids.main)
        end

        vim.api.nvim_buf_set_keymap(self.bufnrs.main, "n", "?", '', {
            noremap = true,
            callback = show_help,
        })
    end
    -- }}}
    -- functions{{{
    get_cwd = function()
        local cwd = vim.fs.normalize(vim.fn.getcwd())
        return cwd
    end

    update_info = function()
        if self.is_help then return end
        write_lines("info", 0, -1, { "[EIM] cwd: " .. self.cwd })
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
    -- }}}
    --# publish {{{
    return {
        init = init,
    }
    -- }}}
end
-- }}}
-- new eim {{{
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
    local main_border
    if (vim.opt.ambiwidth:get() == 'single') then
        main_border = {
            "├", "─", "┤", "│",
            "╯", "─", "╰", "│"
        }
    else
        main_border = 'rounded'
    end
    local win_config_main = {
        width     = main_width,
        height    = main_height,
        col       = main_col,
        row       = main_row,
        border    = main_border,
        focusable = true,
        style     = 'minimal',
        relative  = 'editor',
    }
    local config_main     = {
        window = win_config_main,
        color = "NormalFloat",
    }

    --# information window config
    local info_height     = 1
    local info_width      = eim_width
    local info_row        = main_row - info_height - offset_border
    local info_col        = main_col
    local info_border
    if (vim.opt.ambiwidth:get() == 'single') then
        info_border = {
            "╭", "─", "╮", "│",
            "", "", "", "│"
        }
    else
        info_border = 'rounded'
    end
    local win_config_info = {
        width     = info_width,
        height    = info_height,
        col       = info_col,
        row       = info_row,
        border    = info_border,
        focusable = false,
        style     = 'minimal',
        relative  = 'editor',
    }

    local config_info     = {
        window = win_config_info,
        color = "TabLineSel",
    }
    eim.init(config_main, config_info)
end
-- }}}
--# create command{{{
vim.api.nvim_create_user_command("Eim", init_eim, {
    bang = true
})
-- }}}
--# create keymap that launch Fim{{{
vim.api.nvim_set_keymap("n", '<leader>e', '', {
    noremap = true,
    callback = init_eim,
})
-- }}}
