--TODO
--除外するディレクトリ名、文字列をオプションで渡せるようにする。
--オブジェクト指向風に書き換える
local helper = require("../helper")
local Path_table = {}
--################################## functions ############################################
--# get env independent pwd{{{
local get_pwd = function()
    return vim.fs.normalize(vim.fn.getcwd())
end
-- }}}
--# scandir recurcive{{{
local scandirRecursive
scandirRecursive = function(path, pwd)
    local uv = vim.loop
    local cb = function(err, fs)
        if err ~= nil then
            --print(err)
            return
        end
        local luv = vim.loop
        while true do
            local name, type = luv.fs_scandir_next(fs)
            if name == nil then
                break
            else
                local filename = path .. "/" .. name
                if type == 'directory' then
                    scandirRecursive(filename, pwd)
                else
                    Path_table[#Path_table + 1] = string.gsub(filename, pwd, '')
                end
            end
        end
        --print("[Fim] path_table length: " .. #Path_table)
    end

    -- async scan
    local fs = uv.fs_scandir(path, cb)
end
-- }}}
--
--# An algorithm that scores string matching{{{
local function get_score(str, findstr, weight)
    local find_index = 1
    --local score_layer = 0
    local total_score = 0
    local score_continue = 0
    local is_continue = 0
    local layerflg = 0
    for i = 1, string.len(str) do
        local findchar = string.sub(findstr, find_index, find_index)
        local targetfile = string.sub(str, i, i)
        -- increment layer score
        --if string.match(targetfile, '[/%\\]') ~= nil then
        --score_layer = score_layer + 2 * weight
        --end
        -- is match
        if (findchar == targetfile) then
            -- add match waight
            total_score = total_score + 1 * weight
            -- add continue score
            if is_continue == 1 then
                score_continue = score_continue + 2 * weight
                total_score = total_score + score_continue
                if layerflg == 1 then
                    total_score = total_score + 2 * weight
                end
            end

            -- is last match
            if find_index == string.len(findstr) then
                -- add last match score
                if find_index == string.len(str) then
                    total_score = total_score + 1 * weight
                end
                break
            end
            -- change cnt, flg
            if string.match(findchar, '[/%\\]') ~= nil then
                layerflg = 1
            else
                layerflg = 0
            end

            find_index = find_index + 1
            is_continue = 1
        else
            -- change flg
            is_continue = 0
        end
    end
    return total_score
end
-- }}}
--# An algorithm that scores the degree of matching between file paths and search string {{{
local function fuzzyFindAlgo(filepath, findstr)
    local filepath_score = get_score(filepath, findstr, 4)

    local filename = string.match(filepath, "[^\\/]+$")
    local filename_score = get_score(filename, findstr, 5)

    local score = filepath_score + filename_score

    return { name = filepath, score = score }
end
-- }}}
--# Fuzzy Finder main{{{
local function fuzzyFind(findstr, path_table)
    if path_table == nil then
        return
    end
    local pwd = get_pwd()

    local ffResults = {}

    local index = 1
    for i = 1, #path_table do
        local filepath = string.gsub(path_table[i], pwd, "")
        filepath = filepath:sub(2, #filepath)
        local ffResult = fuzzyFindAlgo(filepath, findstr)
        if ffResult.score > 0 then
            ffResults[index] = ffResult
            index = index + 1
        end
    end

    table.sort(ffResults, (function(a, b)
        return a.score < b.score
    end))

    return ffResults
end
-- }}}

--################################### ui #############################################
--# write lines to nomodifiable buffer{{{
local function writeLine(bufnr, startl, endl, msg)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_option(bufnr, 'readonly', false)
    vim.api.nvim_buf_set_lines(bufnr, startl, endl, false, msg)
    vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
    vim.api.nvim_buf_set_option(bufnr, 'readonly', true)
end
-- }}}
--# write the result of search to the file selector{{{
local function showFoundFiles()
    local inputstrs = vim.api.nvim_buf_get_lines(vim.g.fim_input_bufnr, 0, 1, false)
    local inputstr = inputstrs[1]
    local fnames = {}
    local ffresult = fuzzyFind(inputstr, Path_table)

    if ffresult ~= nil then
        for i = 1, #ffresult do
            fnames[i] = ffresult[i].name
        end
    end

    vim.fn.win_gotoid(vim.g.fim_selector_winid)
    if #fnames == 0 then
        local notfound_msg = '< file not found ... >'
        writeLine(vim.g.fim_selector_bufnr, 0, -1, { notfound_msg })
        vim.fn.clearmatches(vim.g.fim_selector_winid)
        vim.fn.matchadd("FimMsg", '<\\s.\\+\\s>')
    else
        writeLine(vim.g.fim_selector_bufnr, 0, -1, fnames)
        vim.fn.clearmatches(vim.g.fim_selector_winid)
        local inputstr_sub = string.gsub(inputstr, "([%.%\\%[%]%(%)%*])", "%1")
        vim.fn.matchadd("FimMatch", '[' .. inputstr_sub .. ']')
        vim.fn.matchadd("FimMatchAll", inputstr)
        vim.fn.execute(vim.fn.line('$'))
    end

    vim.fn.win_gotoid(vim.g.fim_input_winid)
end
-- }}}
--# close all windows{{{
local function close_Fim()
    vim.api.nvim_win_close(vim.g.fim_info_winid, true)
    vim.api.nvim_win_close(vim.g.fim_selector_winid, true)
    vim.api.nvim_win_close(vim.g.fim_input_winid, true)
    vim.api.nvim_win_close(vim.g.fim_prompt_winid, true)
end
-- }}}
--# common keymappings{{{
local function create_keymap_quitfim(bufnr)
    vim.api.nvim_buf_set_keymap(bufnr, "n", '<leader>ff', '', {
        noremap = true,
        callback = function()
            close_Fim()
        end,
    })
end
-- }}}
--# common autocmd {{{
--local function au_win_leave(bufnr, prewinid)
    --vim.api.nvim_create_augroup('fimCommon', {})
    --vim.api.nvim_create_autocmd('BufWinLeave', {
        --group = 'fimCommon',
        --callback = function(e)
            --vim.fn.win_gotoid(prewinid)
            --vim.api.nvim_win_close(vim.g.fim_info_winid, true)
            --vim.api.nvim_win_close(vim.g.fim_selector_winid, true)
            --vim.api.nvim_win_close(vim.g.fim_input_winid, true)
            --vim.api.nvim_win_close(vim.g.fim_prompt_winid, true)
            ----vim.cmd("b " .. vim.g.fim_input_bufnr)
        --end,
        --buffer = bufnr,
    --})
--end
-- }}}
--
--# create infomation box (info) {{{
local function create_infobox(config, information)
    if (vim.fn.exists('fim_info_bufnr') ~= 1) or (vim.fn.bufnr(vim.g.fim_info_bufnr) == -1) then
        vim.g.fim_info_bufnr = vim.api.nvim_create_buf(false, true)
    end
    vim.g.fim_info_winid = vim.api.nvim_open_win(vim.g.fim_info_bufnr, true, config)
    writeLine(vim.g.fim_info_bufnr, 0, -1, information)
    vim.fn.matchadd("FimMsg", '<\\s.\\+\\s>')

    -- set options
    vim.api.nvim_win_set_option(vim.g.fim_info_winid, 'winhl', 'Normal:LineNr')
    vim.api.nvim_win_set_option(vim.g.fim_info_winid, 'signcolumn', 'no')
    vim.api.nvim_buf_set_option(0, 'modifiable', false)
    vim.api.nvim_buf_set_option(0, 'readonly', true)
end
-- }}}
--# create file select window (selector) {{{
local function create_selector(config, pre_winid)
    if (vim.fn.exists('fim_selector_bufnr') ~= 1) or (vim.fn.bufnr(vim.g.fim_selector_bufnr) == -1) then
        vim.g.fim_selector_bufnr = vim.api.nvim_create_buf(false, true)
    end

    vim.g.fim_selector_winid = vim.api.nvim_open_win(vim.g.fim_selector_bufnr, true, config)
    --end
    vim.b.fimMsg = vim.fn.matchadd("FimMsg", '<\\s.\\+\\s>')

    -- create keymaps
    create_keymap_quitfim(vim.g.fim_selector_bufnr)

    vim.api.nvim_buf_set_keymap(0, "n", '<Enter>', '', {
        noremap = true,
        callback = function()
            local selected_line = vim.fn.getline(vim.fn.line("."))
            if string.match(selected_line, "^<") ~= nil then
                helper.highlightEcho("warning", "no such file or directory")
                return
            end
            local selected_file = vim.fs.normalize(vim.fn.getcwd()) .. "/" .. selected_line
            close_Fim()
            vim.fn.win_gotoid(pre_winid)
            vim.cmd(':e ' .. selected_file)
            helper.highlightEcho("info", 'open file >>> ' .. selected_file)
        end,
    })

    vim.api.nvim_buf_set_keymap(0, "n", '/', '', {
        noremap = true,
        callback = function()
            vim.fn.win_gotoid(vim.g.fim_input_winid)
            if vim.opt.lines:get() > 1 then
                vim.cmd("noautocmd normal! ggjdG")
            end
            vim.fn.setpos('.', { 0, 0, vim.fn.col('$'), 0 })
        end,
    })
    vim.api.nvim_create_augroup('fimSelector', {})
    vim.api.nvim_create_autocmd('DirChanged', {
        group = 'fimSelector',
        callback = function()
            local pwd = get_pwd()
            vim.api.nvim_buf_call(
                vim.g.fim_input_bufnr,
                function()
                    vim.cmd("cd " .. vim.fs.normalize(vim.fn.getcwd()))
                end)
            Path_table = {}
            writeLine(vim.g.fim_info_bufnr, 0, 1, { "< pwd - " .. pwd .. " >" })
            vim.fn.win_gotoid(vim.g.fim_selector_winid)
            writeLine(vim.g.fim_selector_bufnr, 0, -1, { "< Fim Reloaded >" })
            vim.fn.clearmatches(vim.g.fim_selector_winid)
            vim.fn.matchadd("FimMsg", '<\\s.\\+\\s>')
            vim.fn.win_gotoid(vim.g.fim_input_winid)
            scandirRecursive(pwd, pwd)
        end,
        buffer = vim.g.fim_selector_bufnr,
    })

    writeLine(vim.g.fim_selector_bufnr, 0, -1, {
        "< Welcome to Fim! >",
        "< Find your files by typing in the search box >"
    })

    -- set options
    vim.api.nvim_win_set_option(vim.g.fim_selector_winid, 'winhl', 'Normal:LineNr')
    vim.api.nvim_win_set_option(vim.g.fim_selector_winid, 'signcolumn', 'no')
    vim.api.nvim_buf_set_option(0, 'modifiable', false)
    vim.api.nvim_buf_set_option(0, 'readonly', true)
end
-- }}}
--# create inputbox (input) {{{
local function create_inputbox(config)
    if (vim.fn.exists('fim_input_bufnr') ~= 1) or (vim.fn.bufnr(vim.g.fim_input_bufnr) == -1) then
        vim.g.fim_input_bufnr = vim.api.nvim_create_buf(false, true)
    end
    --vim.g.fim_input_bufnr = vim.api.nvim_create_buf(false, true)
    vim.g.fim_input_winid = vim.api.nvim_open_win(vim.g.fim_input_bufnr, true, config)
    writeLine(vim.g.fim_input_bufnr, 0, -1, { '' })

    -- move to selector
    vim.api.nvim_buf_set_keymap(0, "i", '<Enter>', '', {
        noremap = true,
        callback = function()
            local key = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
            vim.api.nvim_feedkeys(key, 'n', false)
            if #Path_table <= 8982 then
                showFoundFiles()
                vim.fn.win_gotoid(vim.g.fim_selector_winid)
            end
        end,
    })
    vim.api.nvim_buf_set_keymap(0, "n", '<Enter>', '', {
        noremap = true,
        callback = function()
            showFoundFiles()
            vim.fn.win_gotoid(vim.g.fim_selector_winid)
        end,
    })

    -- quit Fim
    create_keymap_quitfim(vim.g.fim_input_bufnr)

    -- autocmd
    --au_win_leave(vim.g.fim_input_bufnr, pre_winid)
    vim.api.nvim_create_augroup('fimInput', {})
    vim.api.nvim_create_autocmd('CursorMovedI', {
        group = 'fimInput',
        callback = function()
            if #Path_table < 8982 then
                showFoundFiles()
            else
                vim.fn.win_gotoid(vim.g.fim_selector_winid)
                writeLine(vim.g.fim_selector_bufnr, 0, -1, {
                    '< The file list length is larger than 8982 >',
                    '< So, no file search on input >',
                    '< if you want to search files, press <Enter> on normal mode >',
                })
                vim.fn.clearmatches(vim.g.fim_selector_winid)
                vim.fn.matchadd("FimMsg", '<\\s.\\+\\s>')
                vim.fn.win_gotoid(vim.g.fim_input_winid)
            end
        end,
        buffer = vim.g.fim_input_bufnr,
    })
    vim.api.nvim_create_autocmd('DirChanged', {
        group = 'fimInput',
        callback = function()
            local pwd = get_pwd()
            vim.api.nvim_buf_call(
                vim.g.fim_selector_bufnr,
                function()
                    vim.cmd("cd " .. vim.fs.normalize(vim.fn.getcwd()))
                end)
            Path_table = {}
            writeLine(vim.g.fim_info_bufnr, 0, 1, { "< pwd - " .. pwd .. " >" })
            writeLine(vim.g.fim_selector_bufnr, 0, -1, { "< Fim Reloaded >" })
            scandirRecursive(pwd, pwd)
        end,
        buffer = vim.g.fim_input_bufnr,
    })

    -- set options
    vim.api.nvim_win_set_option(vim.g.fim_input_winid, 'winhl', 'Normal:Visual')
    vim.api.nvim_win_set_option(vim.g.fim_input_winid, 'signcolumn', 'no')
    vim.api.nvim_buf_set_option(0, 'modifiable', true)
    vim.api.nvim_buf_set_option(0, 'readonly', false)
end
-- }}}
--# create inputbox prompt (prompt){{{
local function create_prompt(config, prompt)
    vim.g.fim_prompt_bufnr = vim.api.nvim_create_buf(false, true)
    vim.g.fim_prompt_winid = vim.api.nvim_open_win(vim.g.fim_prompt_bufnr, false, config)
    writeLine(vim.g.fim_prompt_bufnr, 0, -1, { prompt })

    vim.api.nvim_win_set_option(vim.g.fim_prompt_winid, 'winhl', 'Normal:Visual')
    vim.api.nvim_buf_set_option(vim.g.fim_prompt_bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_option(vim.g.fim_prompt_bufnr, 'readonly', false)
end
-- }}}
--
--# create all windows {{{
local function create_ffwin(pre_winid)
    local lines             = vim.opt.lines:get()
    local columns           = vim.opt.columns:get()
    local flame_height      = 2

    -- fim window size
    local fim_height        = math.floor(lines / 2)
    local fim_width         = math.floor(columns / 2)

    -- input
    local input_height      = 1

    -- prompt
    local prompt            = [[>> ]]
    local prompt_width      = string.len(prompt)

    -- info
    local pwd               = get_pwd()
    local information       = {
        "< pwd - " .. pwd .. " >",
        "=== mapping =========================================================================",
        "toggle Fim : <leader>ff",
        "searchbox  : move to file selector  - <Enter>",
        "selector   : open file under cursor - <Enter>",
        "             move to search box     - /",
    }
    local info_height       = #information

    -- offset
    local statusline_height = 1
    local offset_col        = 0
    local offset_row        = 0

    local config_selector   = {
        width     = math.floor(columns / 2),
        col       = columns - fim_width - offset_col - 2,
        height    = fim_height - info_height - input_height,
        row       = lines - fim_height - (flame_height * 3) - offset_row + statusline_height,
        border    = {
            ".", "-", ".", "|",
            "", "", "", "|",
        },
        focusable = true,
        style     = 'minimal',
        relative  = 'editor',
    }

    local config_inputbox   = {
        width     = math.floor(columns / 2) - prompt_width,
        col       = columns - fim_width - offset_col + prompt_width - 1,
        height    = input_height,
        row       = lines - info_height - input_height - (flame_height * 2) + statusline_height - offset_row - 1,
        border    = {
            "", "-", ".", "|",
            "'", "", "", "",
        },
        focusable = true,
        style     = 'minimal',
        relative  = 'editor',
    }
    local config_prompt     = {
        width     = prompt_width,
        col       = columns - fim_width - offset_col - 2,
        height    = input_height,
        row       = lines - info_height - input_height - (flame_height * 2) + statusline_height - offset_row - 1,
        border    = {
            ".", "-", "", "",
            "", "-", "`", "|",
        },
        focusable = false,
        style     = 'minimal',
        relative  = 'editor',
    }

    local config_infobox    = {
        width     = math.floor(columns / 2),
        col       = columns - fim_width - offset_col - 2,
        height    = info_height,
        row       = lines - info_height - flame_height - statusline_height - offset_row,
        border    = {
            "|", "", "|", "|",
            "'", "-", "`", "|",
        },
        focusable = false,
        style     = 'minimal',
        relative  = 'editor',
    }

    create_selector(config_selector, pre_winid)
    create_infobox(config_infobox, information)
    create_prompt(config_prompt, prompt)
    create_inputbox(config_inputbox)
    --vim.fn.win_gotoid(vim.g.fim_input_winid)
end
-- }}}

--################################ main ##########################################
--# main func{{{
local fim = function()
    -- if fim has opened, goto fim window.
    if vim.fn.exists('g:fim_input_bufnr') and (#vim.fn.win_findbuf(vim.g.fim_input_bufnr) > 0) then
        vim.fn.win_gotoid(vim.g.fim_input_winid)
        return
    end

    -- define highlight
    vim.cmd("hi! def link FimMatch CursorLineNr")
    vim.cmd("hi! def link FimMatchAll Title")
    vim.cmd("hi! def link FimMsg Statement")

    -- create ui (At this time, Mappings are not valid)
    local pre_winid = vim.fn.win_getid()
    create_ffwin(pre_winid)

    -- get file path list asynchronously
    Path_table = {}
    local pwd = vim.fn.getcwd()
    scandirRecursive(pwd, pwd)

    -- goto inputbox
    vim.fn.win_gotoid(vim.g.fim_input_winid)
end
-- }}}

--# create Fim command
vim.api.nvim_create_user_command("Fim", fim, { bang = true })

--# create keymap that launch Fim
vim.api.nvim_set_keymap("n", '<leader>ff', '', {
    noremap = true,
    callback = fim,
})
