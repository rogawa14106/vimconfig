-- requires
local helper = require("util.helper")

-- set leader
vim.g.mapleader = " "

-- override default keymap
-- vim.keymap.set("n", "K", "k", { noremap = true })

-- normal
-- toggle comment{{{
local load_visual_text = function()
    local zreg_bf = vim.fn.getreg("z")
    vim.cmd('noautocmd normal! "zy')
    local selected_text = vim.fn.getreg("z")
    vim.fn.setreg("z", zreg_bf)

    local lines = vim.split(selected_text, '\n')
    if lines == nil then
        return
    end
    lines[#lines] = nil -- delete element that line break only
    return lines
end

local comment_out = function(comment_str, linenr)
    vim.fn.setpos(".", { 0, linenr, 0, 0 })
    vim.cmd("noautocmd normal! ^i" .. comment_str .. " ")
end

local comment_in = function(comment_str, lines, top, bot)
    comment_str = string.gsub(comment_str, '%-', '%%-')
    for i = 1, #lines do
        lines[i] = string.gsub(lines[i], "^(%s*)" .. comment_str .. " ?(.+)", "%1%2")
        print(comment_str, lines[i])
    end
    vim.cmd("noautocmd normal! '<")
    vim.api.nvim_buf_set_lines(vim.fn.bufnr(), top - 1, bot, true, lines)
end

local tgl_comment = function()
    -- only visual line mode
    if vim.fn.mode() ~= "V" then return end

    -- load lines selected
    local lines = load_visual_text()

    -- get selected domain
    local topline = vim.fn.line("'<")
    local botline = vim.fn.line("'>")
    local pos = { 0, 0 }
    if topline > botline then
        pos = { botline, topline }
    else
        pos = { topline, botline }
    end

    -- toggle comments
    local topline_str = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)
    local comment_str = string.gsub(vim.bo.commentstring, " %%s", "")
    local is_commented = string.find(topline_str[1], comment_str, 1, true)

    if is_commented == nil then
        for i = pos[1], pos[2] do
            comment_out(comment_str, i)
        end
    else
        comment_in(comment_str, lines, pos[1], pos[2])
    end
end

vim.keymap.set("v", "<leader>/", "", {
    noremap = true,
    callback = tgl_comment,
    desc = "Toggle comments",
})
-- }}}
-- change current working directory{{{
vim.keymap.set("n", "<leader>cd", "", {
    noremap = true,
    callback = function()
        local dir = vim.fs.normalize(vim.fn.expand("%:p:h"))
        local stat = vim.fn.finddir(dir)
        if stat == "" then
            helper.highlightEcho("error", "can't find path")
            return
        end
        vim.cmd("cd " .. dir)
        local cwd = vim.fs.normalize(vim.fn.getcwd())
        helper.highlightEcho("info", "change cwd >> " .. cwd)
    end,
    desc = "Change working directory to current file path",
})
-- }}}
-- switch buffer{{{
local switchBuff = function(switching_key)
    -- define buffer switching cmds
    local buf_switching_cmds = {
        next = "bnext",
        prev = "bprev"
    }
    -- validate switching key
    local is_valid = false
    for key, value in pairs(buf_switching_cmds) do
        if key == switching_key then
            is_valid = true
            break
        end
    end
    if is_valid == false then
        helper.highlightEcho("error", "invalid argument. switching key must be next or prev")
        return
    end

    -- block buffer switching on specified buffer
    local block_table = {
        "bufctl_bufnr",
        "fim_input_bufnr",
        "fim_selector_bufnr",
        "eim_main_bufnr",
    }
    for i = 1, #block_table do
        local block_bufnr = block_table[i]
        if vim.fn.exists("g:" .. block_bufnr) and (vim.fn.bufnr() == vim.g[block_bufnr]) then
            helper.highlightEcho("warning", "operation is blocked")
            return
        end
    end

    -- switch buffer
    local buf_switching_cmd = buf_switching_cmds[switching_key]
    while true do
        vim.cmd(buf_switching_cmd)
        -- skip "nolisted" or "terminal"
        if (vim.opt.buflisted:get() ~= 0) and (vim.opt.buftype:get() ~= "terminal") then
            helper.highlightEcho("info", "buffer switched to >> " .. vim.fn.escape(vim.fn.bufname(vim.fn.bufnr()), "\\"))
            break
        end
    end
end
vim.keymap.set("n", "<Leader>n", "", {
    noremap = true,
    callback = function()
        switchBuff("next")
    end,
    desc = "Switch buffer to next",
})
vim.keymap.set("n", "<Leader>p", "", {
    noremap = true,
    callback = function()
        switchBuff("prev")
    end,
    desc = "Switch buffer to previous"
})
-- }}}
-- cnext, cNext{{{
vim.keymap.set("n", "<leader>cn", "<Cmd>cnext<CR>", { noremap = true, desc = "Go to next ctag" })
vim.keymap.set("n", "<leader>cp", "<Cmd>cNext<CR>", { noremap = true, desc = "Go to previous ctag" })
-- }}}
-- open web browser{{{
-- https://test.com
vim.keymap.set("n", "<C-b>", "", {
    noremap = true,
    callback = function()
        -- get url on cursor line
        local line = vim.fn.getline(".")
        local url = string.match(line, "https://.+")
        print(url)

        if vim.fn.has('linux') == 1 then
            -- launch firefox
            -- vim.cmd('!/usr/bin/firefox "' .. url .. '" 2> /dev/null')
            vim.cmd("!$(whereis firefox | awk -F \" \" '{print $2}') " .. '"' .. url .. '"')
        else
            -- launch chrome
            vim.cmd('!chcp 65001 | "C:/Program Files/Google/Chrome/Application/chrome.exe" --incognito ' ..
                '"' .. url .. '"')
        end
        local key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
        vim.api.nvim_feedkeys(key, 'n', false)
    end,
    desc = "Launch web browser",
})
-- }}}
-- convert hiragana to katakana{{{
local hiraTokata = function(str)
    local chars = vim.fn.split(str, '\\zs')
    local newstr = ""
    for i = 1, #chars do
        local digchar = tonumber(vim.fn.printf("%d", vim.fn.char2nr(chars[i])))
        local newdigchar
        if 12352 < digchar and digchar < 12439 then
            newdigchar = digchar + 96
        else
            newdigchar = digchar
        end
        newstr = newstr .. vim.fn.nr2char(newdigchar)
    end
    return newstr
end

vim.keymap.set("v", "<F7>", "", {
    noremap = true,
    callback = function()
        local pre_zreg = vim.fn.getreg("z")
        vim.cmd('noautocmd normal! "zy')
        local str = vim.fn.getreg("z")
        local katastr = hiraTokata(str)
        vim.fn.setreg("z", katastr)
        vim.cmd('noautocmd normal! gv"zP')
        vim.fn.setreg("z", pre_zreg)
    end,
})
-- }}}
-- enable fmotion on "kana"{{{
-- vim.keymap.set("n", "<C-c>", ":nohl<CR>")
-- vim.keymap.set("n", "<leader>k", "f<C-k>", { noremap = true })
-- vim.keymap.set("n", "<leader>k", "F<C-k>", { noremap = true })
-- }}}
-- highlight color code{{{
local hl_color_code = function()
    local hlns = vim.api.nvim_get_namespaces()['hl_color_code']
    if hlns ~= nil then
        vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_get_namespaces()['hl_color_code'], 0, vim.fn.line("$"))
    end
    local zreg = vim.fn.getreg("z")

    vim.cmd('noautocmd normal! viw"zy')
    local cc = vim.fn.getreg("z")
    if string.match(cc, '%x%x%x%x%x%x') == nil then
        return
    end

    vim.cmd("hi! ColorCodeF guifg=#" .. cc)
    vim.cmd("hi! ColorCodeB guibg=#" .. cc)
    local ns = vim.api.nvim_create_namespace('hl_color_code')
    vim.api.nvim_buf_add_highlight(
        0, ns, "ColorCodeF", vim.fn.line(".") - 1,
        math.floor(vim.fn.col("$") / 2), vim.fn.col("$"))
    vim.api.nvim_buf_add_highlight(
        0, ns, "ColorCodeB", vim.fn.line(".") - 1,
        0, math.floor(vim.fn.col("$") / 2) - 1)

    vim.cmd('noautocmd normal! viw"zy')
    vim.fn.setreg("z", zreg)
end

--vim.api.nvim_set_keymap('n', '<leader>cc', '', { noremap = true, callback = hl_color_code })
-- }}}

-- visual
-- move lines{{{
-- vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv", { noremap = true, desc = "Move selected lines up" })
-- vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv", { noremap = true, desc = "Move selected lines up" })
-- }}}
-- surround_str{{{
local surround_str = function(lchar, rchar)
    -- leave visual mode
    local zreg = vim.fn.getreg("z")
    vim.cmd('noautocmd normal! "zy')
    vim.fn.setreg("z", zreg)

    local pos = {
        left = { 0, vim.fn.line("'<"), vim.fn.col("'<"), 0 },
        right = { 0, vim.fn.line("'>"), vim.fn.col("'>") + 1, 0 },
    }
    vim.fn.setpos(".", pos.left)
    vim.cmd("noautocmd normal! i" .. lchar)
    vim.fn.setpos(".", pos.right)
    vim.cmd("noautocmd normal! a" .. rchar)
end

local create_keymap_surround_str = function(lchar, rchar)
    vim.keymap.set("v", "<leader>" .. lchar, "", {
        noremap = true,
        callback = function()
            surround_str(lchar, rchar)
        end,
        desc = "Surround selected characters in " .. lchar .. rchar,
    })
end

create_keymap_surround_str('"', '"')
create_keymap_surround_str("'", "'")
create_keymap_surround_str("<", ">")
create_keymap_surround_str("(", ")")
create_keymap_surround_str("[", "]")
create_keymap_surround_str("{", "}")
create_keymap_surround_str("%", "%")
-- }}}

-- insert
--vim.keymap.set("i", "<C-c>", "<Esc>", { noremap = true }){{{
-- }}}

-- insert & command
-- move to inside{{{
vim.keymap.set({ "i", "c" }, '""', '""<Left>', { noremap = true })
vim.keymap.set({ "i", "c" }, "''", "''<Left>", { noremap = true })
vim.keymap.set({ "i", "c" }, "()", "()<Left>", { noremap = true })
vim.keymap.set({ "i", "c" }, "[]", "[]<Left>", { noremap = true })
vim.keymap.set({ "i", "c" }, "{}", "{}<Left>", { noremap = true })
vim.keymap.set({ "i", "c" }, "<>", "<><Left>", { noremap = true })
vim.keymap.set({ "i", "c" }, "%%", "%%<Left>", { noremap = true })
-- }}}

-- terminal
-- exit job mode{{{
vim.keymap.set("t", "<C-[>", "<C-\\><C-N>", { noremap = true, desc = "Exit job mode on terminal" })
-- }}}
