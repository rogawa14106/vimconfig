local helper = require('../helper')
-- fw: floatwindow
-- buf: buffer

local floatwindow = function()
    print("########## new floatwindow ##########")
    -- published members
    local self = {
        init_opt = {},
        opt = {},
        -- member variables
        bufnr = nil,
        winid = nil, -- 'winid' can be derived from 'bufnr', but retain 'winid' in variable because processing steps is reduced.
        --         pre_winid = nil,
        --         buflines = {},
        --         bufinfos = {},
        -- member methods
        init = function() end,
        create_buf = function() end,
        open_win = function() end,
        change_opt = function()end,
        write_lines = function() end,
        close_win = function() end,
        send_cmd = function() end,
    }

    -- private members
    local _self = {
        -- member variables
        --         debug_flg = true,
        debug_flg = true,
        bufnr_key = nil,
        -- member methods
        debug_print = function() end,
        set_keymap = function() end,
        set_autocmd = function() end,
        set_bufopt = function() end,
        set_winopt = function() end,
        set_highlight = function() end,
    }

    self.init = function(opt)
        _self.debug_print(0, "init")
        self.init_opt = opt
        self.opt = opt
        _self.bufnr_key = self.opt.name .. "_bufnr"

        print(vim.inspect(self.opt))

        self.create_buf()
        self.open_win()
        _self.set_keymap()
        _self.set_autocmd()
        _self.set_bufopt()
        _self.set_winopt()
    end

    self.create_buf = function()
        _self.debug_print(0, "create_buf")
        local bufnr = vim.g[_self.bufnr_key]
        -- if global val <winname>_bufnr is nil
        if (bufnr == nil) or (vim.fn.bufexists(bufnr) == 0) then
            bufnr = vim.api.nvim_create_buf(false, true)
            vim.g[_self.bufnr_key] = bufnr
            _self.debug_print(1, "buf created!")
        end
        _self.debug_print(1, "bufnr: " .. bufnr)
        self.bufnr = bufnr
        return bufnr
    end

    self.open_win = function()
        _self.debug_print(0, "open_win")
        local opt_win = self.opt.window
        if self.bufnr == nil then
            helper.highlightEcho("error", "buffer that used to open floating window is not initialized")
            return
        end

        local winid_table = vim.fn.win_findbuf(self.bufnr)
        local winid = winid_table[1]
        if winid == nil then
            winid = vim.api.nvim_open_win(self.bufnr, opt_win.focusable, opt_win)
        else
            if opt_win.focusable == true then
                vim.fn.win_gotoid(winid)
            end
        end
        _self.debug_print(1, "winid: " .. winid)
        self.winid = winid
        return winid
    end

    self.write_lines = function(startl, endl, lines)
        vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', true)
        vim.api.nvim_buf_set_option(self.bufnr, 'readonly', false)
        vim.api.nvim_buf_set_lines(self.bufnr, startl, endl, false, lines)
        vim.api.nvim_buf_set_option(self.bufnr, 'modifiable', false)
        vim.api.nvim_buf_set_option(self.bufnr, 'readonly', true)
        vim.cmd("redraw")
    end

--     self.redraw_win = function(opt_win)
--         if self.winid == nil then
--             helper.highlightEcho("error", "floating window has not opened")
--             return
--         end
--         vim.api.nvim_win_set_config(self.winid, opt_win)
--         vim.api.nvim_win_set_option(self.winid, 'signcolumn', 'no')
--     end

    self.close_win = function()
        _self.debug_print(0, "close_win")
        if (self.winid ~= nil) and (#vim.fn.win_findbuf(self.bufnr) > 0) then
            vim.api.nvim_win_close(self.winid, true)
        end
        local augroup_id = vim.api.nvim_create_augroup(self.opt.name, { clear = true })
        if augroup_id ~= nil then
            _self.debug_print(1, "delete all autocmd")
            vim.api.nvim_del_augroup_by_id(augroup_id)
        end
    end

    self.change_opt = function()
        _self.debug_print(0, "close_win")
    end

    self.send_cmd = function(cmd)
        _self.debug_print(0, "close_win")
        vim.cmd(cmd)
    end

    _self.set_keymap = function()
        _self.debug_print(0, "set_keymap")
        local keymap_table = self.opt.keymap
        if keymap_table == nil then
            _self.debug_print(1, "keymap option does not defined")
            return
        end

        if #keymap_table == 0 then
            _self.debug_print(1, "no keymap options")
            return
        end

        -- TODO too nested
        for i = 1, #keymap_table do
            local keymap = keymap_table[i]
            if keymap == {} then
                _self.debug_print(1, "no keymap options in index " .. i)
            else
                if keymap.is_buf == true then
                    vim.api.nvim_buf_set_keymap(self.bufnr, keymap.mode, keymap.lhs, keymap.rhs, {
                        noremap = keymap.noremap,
                        callback = keymap.callback,
                    })
                else
                    vim.api.nvim_set_keymap(keymap.mode, keymap.lhs, keymap.rhs, {
                        noremap = keymap.noremap,
                        callback = keymap.callback,
                    })
                end
            end
        end
    end

    _self.set_autocmd = function()
        _self.debug_print(0, "set_autocmd")
        local autocmd_table = self.opt.autocmd
        if autocmd_table == nil then
            _self.debug_print(1, "autocmd option does not defined")
            return
        end

        if #autocmd_table == 0 then
            _self.debug_print(1, "no autocmd options")
            return
        end

        -- clear & create autocmd group
        vim.api.nvim_create_augroup(self.opt.name, { clear = true })

        -- create autocmd
        -- TODO too nested
        for i = 1, #autocmd_table do
            local autocmd = autocmd_table[i]
            if autocmd == {} then
                _self.debug_print(1, "no autocmd options in index " .. i)
            else
                if autocmd.is_buf == true then
                    _self.debug_print(1, "set buf autocmd option " .. i)
                    vim.api.nvim_create_autocmd(autocmd.events, {
                        buffer = self.bufnr,
                        group = self.opt.name,
                        callback = autocmd.callback,
                        --                     once = autocmd.once,
                    })
                else
                    _self.debug_print(1, "set autocmd option " .. i)
                    vim.api.nvim_create_autocmd(autocmd.events, {
                        group = self.opt.name,
                        callback = autocmd.callback,
                        --                     once = autocmd.once,
                    })
                end
            end
        end
    end

    _self.set_bufopt = function()
        _self.debug_print(0, "set_bufopt")
        local bufopt_table = self.opt.bufopt
        if bufopt_table == nil then
            _self.debug_print(1, "bufopt option does not defined")
            return
        end

        if #bufopt_table == 0 then
            _self.debug_print(1, "no bufopt options")
            return
        end

        for i = 1, #bufopt_table do
            local bufopt = bufopt_table[i]
            if bufopt == {} then
                _self.debug_print(1, "no bufopt options in index " .. i)
            else
                vim.api.nvim_buf_set_option(self.bufnr, bufopt.name, bufopt.value)
            end
        end
    end

    _self.set_winopt = function()
        _self.debug_print(0, "set_winopt")
        local winopt_table = self.opt.winopt
        if winopt_table == nil then
            _self.debug_print(1, "winopt option does not defined")
            return
        end

        if #winopt_table == 0 then
            _self.debug_print(1, "no winopt options")
            return
        end

        for i = 1, #winopt_table do
            local winopt = winopt_table[i]
            if winopt == {} then
                _self.debug_print(1, "no winopt options in index " .. i)
            else
                vim.api.nvim_win_set_option(self.winid, winopt.name, winopt.value)
            end
        end
    end

    _self.set_highlight = function()
        _self.debug_print(0, "set_highlight")
    end


    -- DEBUG FUNCTIONS
    _self.debug_print = function(indent_level, msg)
        if _self.debug_flg == false then
            return
        end
        local header = "#DEBUG# "
        local indent_str = "  "
        print(header .. string.rep(indent_str, indent_level) .. msg)
    end

    return self
end

return {
    floatwindow = floatwindow,
}
