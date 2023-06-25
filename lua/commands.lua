local helper = require("helper")

-- vimrc, init.vim {{{
vim.api.nvim_create_user_command("VIMRC", function()
    vim.cmd("e " .. vim.env.MYVIMRC)
end, {})

vim.api.nvim_create_user_command("SP", function()
    vim.cmd("luafile " .. vim.env.MYVIMRC)
end, {})

-- use backup
vim.api.nvim_create_user_command("INIVIM", function()
    vim.cmd("source C:/Users/rogawa/AppData/Local/nvim/bak_init.vim")
end, {})
-- }}}

-- toggle terguicolors {{{
vim.api.nvim_create_user_command("GUI", function()
    vim.cmd("set termguicolors!")
end, {})
-- }}}

-- toggle relative scrool {{{
vim.api.nvim_create_user_command("RS", function()
    if (vim.opt.scrolloff:get() == 0) then
        vim.opt.scrolloff = vim.api.nvim_eval("&lines") / 2
    else
        vim.opt.scrolloff = 0
    end
end, {})
-- }}}

-- open terminal {{{
vim.api.nvim_create_user_command("CMD", function(opts)
    --- change key that will send to terminal at first and resize terminal
    local lines = vim.api.nvim_eval("&lines")
    if vim.fn.has('nvim') == 1 then
        Termkey = "a"
        vim.cmd("horizontal belowright " .. lines / 3 .. " split")
    else
        Termkey = ""
        vim.cmd("set termwinsize=" .. lines / 3 .. "x0")
    end

    -- open terminal
    vim.cmd('terminal')
    if vim.fn.has('nvim') == 1 then
        vim.cmd("call nvim_win_set_option(win_getid(), 'winhl', 'Normal:mModeTJob,CursorLine:Folded')")
    end

    -- branch the commands to execute depending on the given arguments
    if opts.args == "" then
        vim.cmd('call feedkeys("' .. Termkey .. '")')
    elseif opts.args == "time" then
        vim.cmd('call feedkeys("' .. Termkey .. 'prompt $d$s$t$g")')
    elseif opts.args == "file" then
        vim.cmd('call feedkeys("' .. Termkey .. 'ssh file")')
    elseif opts.args == "196" then
        vim.cmd('call feedkeys("' .. Termkey .. 'ssh 196")')
    elseif opts.args == "177" then
        vim.cmd('call feedkeys("' .. Termkey .. 'ssh 177")')
    end
end, { nargs = '?' })
-- }}}

-- windows ui {{{ TODO create func that execute external command
if vim.fn.has('windows') == 1 then
    vim.api.nvim_create_user_command("HSB", function()
        local hidesb_cmd = "!" .. helper.vimrcdir .. "/bin/hidesb.exe -b"
        vim.cmd(hidesb_cmd)
        vim.fn.feedkeys('<CR>')
    end, {})

    vim.api.nvim_create_user_command("HTB", function()
        local hidetb_cmd = "!" .. helper.vimrcdir .. "/bin/hidetb.exe"
        vim.cmd(hidetb_cmd)
        vim.fn.feedkeys('<CR>')
    end, {})

    vim.api.nvim_create_user_command("FS", function()
        local hidetb_cmd = "!" .. helper.vimrcdir .. "/bin/hidetb.exe"
        local hidesb_cmd = "!" .. helper.vimrcdir .. "/bin/hidesb.exe -b"
        vim.cmd(hidesb_cmd)
        vim.fn.feedkeys('<CR>')
        vim.cmd(hidetb_cmd)
        vim.fn.feedkeys('<CR>')
    end, {})
end

-- }}}

-- git push vimconfigfiles {{{
vim.api.nvim_create_user_command("GPV", function(opts)
    if string.match(opts.args, "^'") then
        helper.highlightEcho("error", "single quote is invalid")
        return
    end
    vim.cmd("cd " .. helper.vimrcdir)
    vim.cmd("!git add .")
    vim.cmd("!git commit -m " .. opts.args)
    vim.cmd("!git push origin main")
end, { nargs = 1 })
--}}}

-- vimgrep and copen {{{
vim.api.nvim_create_user_command("Grep", function()
    local pwd = vim.fs.normalize(vim.fn.getcwd())
    helper.highlightEcho("info", "grep target >>> " .. pwd .. "/** <<< Type 'exit' to quit. ")
    local regex = vim.fn.input("RegEx> ")

    if (regex == 'exit') then
        print(' [command quit]')
        return
    end

    vim.cmd("vimgrep " .. regex .. " ./** | copen")
end, { force = true })
-- }}}

