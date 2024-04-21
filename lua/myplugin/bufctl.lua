local helper = require('../helper')

local new_BufCtl = function()
    local self = {
        bufnr = nil,
        winid = nil,
        pre_winid = nil,
        buflines = {},
        -- bufnrs = {},
        bufinfos = {},
    }

    local init
    local create_win
    local create_ui
    local delete_win_all
    local delete_win
    local update_bufinfo
    local redraw_bufline
    local write_lines

    local create_keymap
    local select_buf
    local delete_buf
    local is_confirmed

    init = function()
        self.bufnr = vim.g.bufctl_bufnr
        self.winid = vim.g.bufctl_winid
        self.pre_winid = vim.fn.win_getid()
        update_bufinfo()

        -- winconfig
        local width = self.longest_line + 1
        local height = #self.buflines
        local border_off = 2
        local offset = 1
        local border = {
            ".", "-", ".", "|",
            "'", "-", "`", "|",
        }
        local config = {
            window = {
                width     = width,
                height    = height,
                col       = vim.opt.columns:get() - width - border_off - offset,
                row       = vim.opt.lines:get() - height - border_off - offset - 1,
                border    = border,
                focusable = true,
                style     = 'minimal',
                relative  = 'editor',
            },
            color  = "NormalFloat"
        }
        create_ui(config)

        write_lines(0, -1, self.buflines)

        -- set keymap
        create_keymap()

        -- disable left and right move
        vim.api.nvim_create_augroup('bufctl', {})
        vim.api.nvim_create_autocmd('CursorMoved', {
            group = 'bufctl',
            callback = function()
                vim.cmd("noautocmd normal! 0")
            end,
            buffer = vim.g.bufctl_bufnr,
        })
    end

    update_bufinfo = function()
        local buf_infos = vim.fn.getbufinfo({ buflisted = 1 })
        local cwd = vim.fs.normalize(vim.fn.getcwd())

        self.buflines = {}
        self.longest_line = 0
        -- self.bufnrs = {}
        self.bufinfos = {}

        for i = 1, #buf_infos do
            local bufinfo = buf_infos[i]

            local bufnr = bufinfo.bufnr
            local bufnr_str = string.format("%02d", bufnr)

            local bufname = vim.fs.normalize(bufinfo.name)
            -- replace cwd
            bufname = string.gsub(bufname, cwd, ".")
            -- get userprofile
            local userprofile
            if vim.fn.has('win32') == 1 then
                userprofile = vim.fs.normalize(vim.env.USERPROFILE)
            else
                userprofile = vim.fs.normalize(vim.env.HOME)
            end
            bufname = string.gsub(bufname, userprofile, "~")
            if bufinfo.variables.term_title ~= nil then
                bufname = 'Terminal'
            end
            if bufname == "" then
                bufname = "No Name"
            end

            local is_change = bufinfo.changed
            local is_change_str = "-"
            if is_change == 1 then
                is_change_str = "+"
            end

            local is_current = (bufinfo.windows ~= nil) and (bufinfo.windows[1] == self.pre_winid)
            local is_current_str = " "
            if is_current then
                is_current_str = "!"
            end

            local bufline = " [" .. bufnr_str .. "][" .. is_change_str .. "][" .. is_current_str .. "] " .. bufname

            if self.longest_line < #bufline then
                self.longest_line = #bufline
            end

            local bufctlinfo = {
                bufnr = bufnr,
                bufname = bufname,
                is_current = is_current,
                is_change = is_change,
            }

            self.buflines[#self.buflines + 1] = bufline
            self.bufinfos[#self.bufinfos + 1] = bufctlinfo
        end
    end

    redraw_bufline = function()
        write_lines(0, -1, self.buflines)
        local winconfig = {
            height = #self.buflines,
            width = self.longest_line + 1,
        }
        vim.api.nvim_win_set_config(self.winid, winconfig)
        vim.api.nvim_win_set_option(self.winid, 'signcolumn', 'no')
    end

    create_ui = function(config)
        -- create bufctl window
        local is_shown = (#vim.fn.win_findbuf(self.bufnr) > 0)
        local current_bufnr = vim.fn.bufnr()
        local is_current = (current_bufnr == self.bufnr)
        if is_shown and is_current then
            delete_win_all()
            return
        elseif is_shown then
            vim.fn.win_gotoid(self.winid)
        else
            local win_main = create_win(config.window, self.bufnr, self.winid)
            self.bufnr = win_main.bufnr
            self.winid = win_main.winid
            vim.g.bufctl_bufnr = win_main.bufnr
            vim.g.bufctl_winid = win_main.winid
        end

        -- set colors
        vim.api.nvim_win_set_option(self.winid, 'winhl', 'Normal:' .. config.color)
        vim.api.nvim_win_set_option(self.winid, 'signcolumn', 'no')
        vim.fn.clearmatches(self.winid)

        vim.fn.matchadd(
        -- 'BufCtlNoFile', '\\v[^\\]]+$',
        -- 10, 5, { window = self.winid })
            'BufCtlNoFile', '\\v(No Name|Terminal)$',
            11, 5, { window = self.winid })
        vim.fn.matchadd(
            "BufCtlFile", '\\v[^\\]/]+$',
            10, 6, { window = self.winid })
        vim.fn.matchadd(
            'BufCtlCautionMark', '\\v\\[!\\]',
            10, 7, { window = self.winid })
        vim.fn.matchadd(
            'BufCtlWarningMark', '\\v\\[[t+]\\]',
            10, 8, { window = self.winid })

        vim.cmd("hi! def link BufCtlFile Title")
        vim.cmd("hi! def link BufCtlNoFile Statement")
        vim.cmd("hi! def link BufCtlCautionMark ErrorMsg")
        vim.cmd("hi! def link BufCtlWarningMark WarningMsg")
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

    delete_win_all = function()
        delete_win(self.winid, self.bufnr)
    end

    delete_win = function(winid, bufnr)
        if (winid ~= nil) and (#vim.fn.win_findbuf(bufnr) > 0) then
            vim.api.nvim_win_close(winid, true)
        end
    end

    write_lines = function(startl, endl, lines)
        vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
        vim.api.nvim_buf_set_option(self.bufnr, 'readonly', false)
        vim.api.nvim_buf_set_lines(self.bufnr, startl, endl, false, lines)
        vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
        vim.api.nvim_buf_set_option(self.bufnr, 'readonly', true)
        vim.cmd("redraw")
    end

    create_keymap = function()
        vim.api.nvim_buf_set_keymap(self.bufnr, "n", "<Enter>", "", {
            noremap = true,
            callback = select_buf,
        })
        vim.api.nvim_buf_set_keymap(self.bufnr, "n", "D", "", {
            noremap = true,
            callback = delete_buf,
        })
    end

    select_buf = function()
        local linenr = vim.fn.line(".")
        local selected_buf = self.bufinfos[linenr].bufnr
        delete_win_all()
        vim.fn.win_gotoid(self.pre_winid)
        vim.cmd("b " .. selected_buf)
        helper.highlightEcho("", "[BufCtl] enter buffer >> " .. self.bufinfos[linenr].bufname .. " ")
    end

    delete_buf = function()
        local linenr = vim.fn.line(".")
        local selected_bufnr = self.bufinfos[linenr].bufnr
        local is_current = self.bufinfos[linenr].is_current
        local is_change = self.bufinfos[linenr].is_change
        if is_current == true then
            helper.highlightEcho("error", "current buffer can't be deleted")
            return
        end
        if is_change == 1 then
            if is_confirmed("buffer is modified.") == false then
                helper.highlightEcho("info", "canceled buffer deletion")
                return
            end
        end
        vim.cmd("bd! " .. selected_bufnr)
        update_bufinfo()
        redraw_bufline()
    end

    is_confirmed = function(msg)
        local inputstr = helper.highlightInput("warning", "[BufCtl] " .. msg .. " type y to continue > ")
        local result = false
        if inputstr == 'y' then
            result = true
        end
        return result
    end

    return {
        init = init
    }
end


local init_bufctl
init_bufctl = function()
    local bufctl = new_BufCtl()
    bufctl.init()
end

vim.api.nvim_set_keymap("n", '<leader>b', '', {
    noremap = true,
    callback = init_bufctl,
})
