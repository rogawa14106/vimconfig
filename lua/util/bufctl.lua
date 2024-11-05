local BufCtl = function()
    local self = {
        bufnr = nil,
        winid = nil,
        pre_winid = nil,
        buflines = {},
        bufinfos = {},
    }

    self.new = function()
        self.bufnr = vim.g.bufctl_bufnr
        self.winid = vim.g.bufctl_winid
        self.pre_winid = vim.fn.win_getid()
        self.update_bufinfo()

        -- winconfig
        local width = self.longest_line + 1
        local height = #self.buflines
        local border_offset = 2
        local config = {
            window = {
                width     = width,
                height    = height,
                -- col       = vim.opt.columns:get() - width - border_off - offset,
                col       = 0,
                row       = vim.opt.lines:get() - border_offset,
                border    = 'rounded',
                focusable = true,
                style     = 'minimal',
                relative  = 'editor',
                anchor    = 'SW',
            },
            color  = "NormalFloat"
        }
        self.init_ui(config)

        self.write_lines(0, -1, self.buflines)

        -- set keymap
        self.init_keymap()

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

    self.update_bufinfo = function()
        local buf_infos = vim.fn.getbufinfo({ buflisted = 1 })

        self.buflines = {}
        self.longest_line = 0
        self.bufinfos = {}

        for i = 1, #buf_infos do
            local bufinfo = buf_infos[i]

            -- Define bufnr
            local bufnr = bufinfo.bufnr
            -- local bufnr_str = string.format("%03d", bufnr)

            -- Define buffer name
            local bufname = vim.fs.basename(bufinfo.name)

            if bufname == "" then
                bufname = "No Name"
            end

            local is_term = string.match(bufinfo.name, '^term://') ~= nil
            if is_term then
                bufname = "Term: " .. bufname
            end

            -- Define buffer status
            local is_change = bufinfo.changed == 1
            local is_change_char = "-"
            if is_change then
                is_change_char = "+"
            end
            if is_term then
                is_change_char = "T"
            end

            local is_current = (bufinfo.windows ~= nil) and (bufinfo.windows[1] == self.pre_winid)
            local is_current_char = " "
            if is_current then
                is_current_char = "!"
            end

            -- Define a line of buffer infomation
            -- local bufline = " [" .. bufnr_str .. "][" .. is_change_char .. "][" .. is_current_char .. "] " .. bufname
            local bufline = " [" .. is_current_char .. "]" .. "[" .. is_change_char .. "] " .. bufname

            -- Update length of longest line.
            if self.longest_line < #bufline then
                self.longest_line = #bufline
            end

            local bufctlinfo = {
                bufnr = bufnr,
                bufname = bufname,
                is_current = is_current,
                is_change = is_change,
                is_term = is_term,
            }

            self.buflines[#self.buflines + 1] = bufline
            self.bufinfos[#self.bufinfos + 1] = bufctlinfo
        end
    end

    self.redraw_bufline = function()
        self.write_lines(0, -1, self.buflines)
        local winconfig = {
            height = #self.buflines,
            width = self.longest_line + 1,
        }
        vim.api.nvim_win_set_config(self.winid, winconfig)
        vim.api.nvim_set_option_value('signcolumn', 'no', { win = self.winid })
    end

    self.init_ui = function(config)
        -- create bufctl window
        local is_shown = (#vim.fn.win_findbuf(self.bufnr) > 0)
        local current_bufnr = vim.fn.bufnr()
        local is_current = (current_bufnr == self.bufnr)
        if is_shown and is_current then
            self.close_all_window()
            return
        elseif is_shown then
            vim.fn.win_gotoid(self.winid)
        else
            local win_main = self.init_window(config.window, self.bufnr, self.winid)
            self.bufnr = win_main.bufnr
            self.winid = win_main.winid
            vim.g.bufctl_bufnr = win_main.bufnr
            vim.g.bufctl_winid = win_main.winid
        end
        -- initialize buffer highlight
        self.init_highlight()
    end

    self.init_highlight = function()
        -- Highlight the parts that match the regular expression.
        vim.fn.clearmatches(self.winid)
        vim.fn.matchadd('BufCtlNoFile', '\\v(No Name|Term: .+)$', 11, 5)
        vim.fn.matchadd("BufCtlFile", '\\v[^\\]/]+$', 10, 6)
        vim.fn.matchadd('BufCtlCautionMark', '\\v\\[[T!]\\]', 10, 7)
        vim.fn.matchadd('BufCtlWarningMark', '\\v\\[[+]\\]', 10, 8)
        vim.cmd("hi! def link BufCtlFile Title")
        vim.cmd("hi! def link BufCtlNoFile Statement")
        vim.cmd("hi! def link BufCtlCautionMark ErrorMsg")
        vim.cmd("hi! def link BufCtlWarningMark WarningMsg")
    end

    self.init_window = function(win_config, g_bufnr, g_winid)
        local bufnr
        local winid
        if g_bufnr == nil then
            -- target buffer has not been opend since vim launched
            bufnr = vim.api.nvim_create_buf(false, true)
        else
            bufnr = g_bufnr
        end

        if (g_winid == nil) or (#vim.fn.win_findbuf(bufnr) < 1) then
            -- if target window has not been opend since vim launched
            -- or if not found target buffer on current window
            winid = vim.api.nvim_open_win(bufnr, win_config.focusable, win_config)
            return { bufnr = bufnr, winid = winid }
        else
            return { bufnr = bufnr, winid = g_winid }
        end
    end

    self.close_all_window = function()
        self.close_window(self.winid, self.bufnr)
    end

    self.close_window = function(winid, bufnr)
        if (winid ~= nil) and (#vim.fn.win_findbuf(bufnr) > 0) then
            vim.api.nvim_win_close(winid, true)
        end
    end

    self.write_lines = function(startl, endl, lines)
        vim.api.nvim_set_option_value('modifiable', true, { buf = self.bufnr })
        vim.api.nvim_set_option_value('readonly', false, { buf = self.bufnr })
        vim.api.nvim_buf_set_lines(self.bufnr, startl, endl, false, lines)
        vim.api.nvim_set_option_value('modifiable', false, { buf = self.bufnr })
        vim.api.nvim_set_option_value('readonly', true, { buf = self.bufnr })
        vim.cmd("redraw")
    end

    self.init_keymap = function()
        -- enter buffer
        vim.api.nvim_buf_set_keymap(self.bufnr, "n", "<Enter>", "", {
            noremap = true,
            callback = self.enter_buffer,
        })
        -- delete buffer
        vim.api.nvim_buf_set_keymap(self.bufnr, "n", "D", "", {
            noremap = true,
            callback = self.delete_buf,
        })
        -- close window
        vim.api.nvim_buf_set_keymap(self.bufnr, 'n', 'q', '', {
            callback = function()
                self.close_all_window()
            end,
        })
    end

    -- enter buffer
    self.enter_buffer = function()
        local linenr = vim.fn.line(".")
        local selected_bufinfo = self.bufinfos[linenr]
        -- close BufCtl and go to previous window
        self.close_all_window()
        vim.fn.win_gotoid(self.pre_winid)
        -- enter selected buffer
        vim.cmd("b " .. selected_bufinfo.bufnr)
        vim.notify("[BufCtl] enter buffer >> " .. selected_bufinfo.bufname, vim.log.levels.INFO)
    end

    self.delete_buf = function()
        local linenr = vim.fn.line(".")
        local bufinfo = self.bufinfos[linenr]
        if bufinfo.is_current == true then
            vim.notify("Current buffer can't be deleted", vim.log.levels.ERROR)
            return
        end
        if bufinfo.is_term == true then
            vim.notify("Terminal buffer can't be deleted", vim.log.levels.ERROR)
            return
        end
        if bufinfo.is_change == true then
            if self.is_confirmed("Buffer is modified.") == false then
                vim.notify("Canceled buffer deletion", vim.log.levels.INFO)
                return
            end
        end
        vim.cmd("bd! " .. bufinfo.bufnr)
        self.update_bufinfo()
        self.redraw_bufline()
    end

    self.is_confirmed = function(msg)
        -- local inputstr = vim.notify("[BufCtl] " .. msg .. " type y to continue > ", vim.log.levels.WARN)
        local inputstr = require('util.helper').highlightInput(
            vim.log.levels.WARN,
            "[BufCtl] " .. msg .. " type y to continue > ",
            ""
        )
        local result = false
        if inputstr == 'y' then
            result = true
        end
        return result
    end

    return {
        new = self.new
    }
end

vim.api.nvim_set_keymap("n", '<leader>b', '', {
    noremap = true,
    callback = function()
        local bufctl = BufCtl()
        bufctl.new()
    end,
    desc = 'Lauch BufCtl',
})
