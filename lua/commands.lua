
-- {{{ vimrc, init.vim
vim.api.nvim_create_user_command("VIMRC", function(opts)
    vim.cmd("e " .. vim.env.MYVIMRC)
end, {})

vim.api.nvim_create_user_command("SP", function(opts)
    vim.cmd("luafile " .. vim.env.MYVIMRC)
end, {})

vim.api.nvim_create_user_command("INIVIM", function(opts)
    vim.cmd("source C:/Users/rogawa/AppData/Local/nvim/bak_init.vim")
end, {})
-- }}}

-- {{{ toggle terguicolors
vim.api.nvim_create_user_command("HSB", function(opts)
    vim.cmd("set termguicolors!")
end, {})
-- }}}

-- {{{ toggle relative scrool
vim.api.nvim_create_user_command("RS", function(opts)
    if (vim.opt.scrolloff:get() == 0) then
        vim.opt.scrolloff = vim.api.nvim_eval("&lines") / 2
    else
        vim.opt.scrolloff = 0
    end
end, {})
-- }}}

-- {{{ open terminal
vim.api.nvim_create_user_command("CMD", function(opts)
    --- change key that will send to terminal at first and resize terminal
    local lines = vim.api.nvim_eval("&lines")
    if vim.fn.has('nvim') == 1 then
        termkey = "a"
        vim.cmd("horizontal belowright " .. lines/3 .. " split")
    else
        termkey = ""
        vim.cmd("set termwinsize=" .. lines/3 .. "x0")
    end

    -- open terminal
    vim.cmd('terminal')
    if vim.fn.has('nvim') == 1 then
        vim.cmd("call nvim_win_set_option(win_getid(), 'winhl', 'Normal:mModeTJob,CursorLine:Folded')")
    end
    
    -- branch the commands to execute depending on the given arguments
    if opts.args == "" then
        vim.cmd('call feedkeys("' .. termkey .. '")')
    elseif opts.args == "time" then
        vim.cmd('call feedkeys("' .. termkey .. 'prompt $d$s$t$g")')
    elseif opts.args == "file" then
        vim.cmd('call feedkeys("' .. termkey .. 'ssh file")')
    elseif opts.args == "196" then
        vim.cmd('call feedkeys("' .. termkey .. 'ssh 196")')
    elseif opts.args == "177" then
        vim.cmd('call feedkeys("' .. termkey .. 'ssh 177")')
    end
end, { nargs='?' })
-- }}}

-- {{{ windows ui
-- TODO create func that execute external command
vim.api.nvim_create_user_command("HSB", function(opts)
    vim.cmd("!hidesb -b")
end, {})

vim.api.nvim_create_user_command("HTB", function(opts)
    vim.cmd("!hidetb")
end, {})
-- }}}

--{{{ git push vimconfigfiles
vim.api.nvim_create_user_command("GPV", function(opts)
    local vimrcdir = string.gsub(vim.env.MYVIMRC, '[^\\/]+$', '')
    vim.cmd("cd " .. vimrcdir)
    vim.cmd("!git add .")
    vim.cmd("!git commit -m " .. opts.args)
    vim.cmd("!git push origin main")
end, { nargs=1 })

