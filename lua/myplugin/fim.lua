--TODO
--非同期処理でdir_tableを取得する。取得中はメッセージを表示する。
--Fimで使用したバッファが残っている場合はそれを使用するようにする(BuffCtlとおなじ方法でできるはず)
--除外するディレクトリ名、文字列をオプションで渡せるようにする。
--カレントディレクトリを変更できるようにする。
--################################## algo ############################################
--# Split string by delimiter and store in array{{{
local function split(str, d)
    local t = {}
    local i = 1
    for s in string.gmatch(str, "([^" .. d .. "]+)") do
        s = string.gsub(s, "[\\]", '/')
        t[i] = s
        i = i + 1
    end

    return t
end
-- }}}
--# Get dir_table{{{
local function get_dir_table()
    local cmd = "chcp 65001 | dir /s /b"
    local dir = vim.fn.system(cmd)
    local dir_table = split(dir, '\n')
    --vim.g.stop_timer = true
    return dir_table
end
-- }}}
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
local function fuzzyFind(findstr, dir_table)
    local pwd = string.gsub(vim.fn.getcwd(), '[\\]', '/')

    local ffResults = {}

    local index = 1
    for i = 1, #dir_table do
        local filepath = string.gsub(dir_table[i], pwd, "")
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
--# write the result of search to the file selector{{{
local function showFoundFiles(dir_table)
    local inputstr = vim.api.nvim_buf_get_lines(vim.g.fim_input_bufnr, 0, 1, false)
    local fnames = {}
    --local ffresult = fuzzyFind(string.sub(inputstr[1], 4, -1), dir_table)
    local ffresult = fuzzyFind(inputstr[1], dir_table)
    for i = 1, #ffresult do
        fnames[i] = ffresult[i].name
    end

    if #fnames == 0 then
        fnames[1] = '< file not found ... >'
    end
    vim.api.nvim_buf_set_option(vim.g.fim_selector_bufnr, 'modifiable', true)
    vim.api.nvim_buf_set_option(vim.g.fim_selector_bufnr, 'readonly', false)
    vim.api.nvim_buf_set_lines(vim.g.fim_selector_bufnr, 0, -1, true, fnames)
    vim.api.nvim_buf_set_option(vim.g.fim_selector_bufnr, 'modifiable', false)
    vim.api.nvim_buf_set_option(vim.g.fim_selector_bufnr, 'readonly', true)

    vim.fn.win_gotoid(vim.g.fim_selector_winid)
    vim.fn.execute(vim.fn.line('$'))
    if #inputstr[1] > 0 then
        local inputstr_sub = string.gsub(inputstr[1], "([%.%\\%[%]%(%)%*])", "%1")
        print('[' .. inputstr_sub .. ']')
        if vim.fn.exists('b:fimmatch') == 1 then
            vim.fn.matchdelete(vim.b.fimmatch)
            vim.fn.matchdelete(vim.b.fimmatchAll)
        end
        vim.b.fimmatch = vim.fn.matchadd("FimMatch", '[' .. inputstr_sub .. ']')
        vim.b.fimmatchAll = vim.fn.matchadd("FimMatchAll", inputstr[1])
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
--# create infomation box (info) {{{
local function create_infobox(config)
    vim.g.fim_info_bufnr = vim.api.nvim_create_buf(false, true)
    vim.g.fim_info_winid = vim.api.nvim_open_win(vim.g.fim_info_bufnr, true, config)
    local pwd = string.gsub(vim.fn.getcwd(), '[\\]', '/')
    vim.api.nvim_buf_set_lines(vim.g.fim_info_bufnr, 0, -1, true, {
        "< " .. pwd .. " >",
        "search box : move to file selector  - <Enter>",
        'selector   : open file under cursor - <Enter>',
        '             move to search box     - /',
    })
    vim.fn.matchadd("FimMsg", '<\\s.\\+\\s>')

    vim.api.nvim_win_set_option(vim.g.fim_info_winid, 'winhl', 'Normal:LineNr')
    vim.api.nvim_buf_set_option(0, 'modifiable', false)
    vim.api.nvim_buf_set_option(0, 'readonly', true)
end
-- }}}
--# create file select window (selector) {{{
local function create_selector(config, pre_winid)
    vim.g.fim_selector_bufnr = vim.api.nvim_create_buf(false, true)
    vim.g.fim_selector_winid = vim.api.nvim_open_win(vim.g.fim_selector_bufnr, true, config)
    vim.api.nvim_buf_set_lines(vim.g.fim_selector_bufnr, 0, -1, true, {
        "< Welcome to Fim >",
        "< Find your files by typing in the search box >"
    })
    if vim.fn.exists('b:fimMsg') == 1 then
        vim.fn.matchdelete(vim.b.fimMsg)
    end
    vim.b.fimMsg = vim.fn.matchadd("FimMsg", '<\\s.\\+\\s>')

    vim.api.nvim_buf_set_keymap(0, "n", '<leader>q', '', {
        noremap = true,
        callback = function()
            close_Fim()
        end,
    })

    vim.api.nvim_buf_set_keymap(0, "n", '<Enter>', '', {
        noremap = true,
        callback = function()
            local selected_file = vim.fn.getline(vim.fn.line("."))
            if string.match(selected_file, "^<") ~= nil then
                vim.cmd("echohl WarningMsg")
                vim.cmd("echo 'no such file or directory'")
                vim.cmd("echohl End")
                return
            end
            close_Fim()
            vim.fn.win_gotoid(pre_winid)
            print('e ' .. selected_file)
            vim.cmd(':e ' .. selected_file)
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

    vim.api.nvim_win_set_option(vim.g.fim_selector_winid, 'winhl', 'Normal:LineNr')
    vim.api.nvim_buf_set_option(0, 'modifiable', false)
    vim.api.nvim_buf_set_option(0, 'readonly', true)
end
-- }}}
--# create inputbox (input) {{{
local function create_inputbox(config)
    vim.g.fim_input_bufnr = vim.api.nvim_create_buf(false, true)
    vim.g.fim_input_winid = vim.api.nvim_open_win(vim.g.fim_input_bufnr, true, config)
    vim.fn.feedkeys('a')

    vim.api.nvim_buf_set_keymap(0, "i", '<Enter>', '<Esc><Cmd>call win_gotoid(g:fim_selector_winid)<CR>', {
        noremap = true,
    })
    vim.api.nvim_buf_set_keymap(0, "n", '<Enter>', '<Esc><Cmd>call win_gotoid(g:fim_selector_winid)<CR>', {
        noremap = true,
    })
    vim.api.nvim_buf_set_keymap(0, "n", '<C-[>', '<Esc><Cmd>call win_gotoid(g:fim_selector_winid)<CR>', {
        noremap = true,
    })

    vim.api.nvim_buf_set_keymap(0, "n", '<leader>q', '', {
        noremap = true,
        callback = function()
            close_Fim()
        end,
    })

    --local uv = vim.loop
    --local timer = uv.new_timer()
    --local i = 0
    --vim.g.stop_timer = false
    --timer:start(1000, 250, vim.schedule_wrap(function()
    --if i % 4 == 0 then
    --print('fetch filelist -')
    --elseif i % 4 == 1 then
    --print('fetch filelist /')
    --elseif i % 4 == 2 then
    --print('fetch filelist |')
    --else
    --print('fetch filelist \\')
    --end
    --if vim.g.stop_timer == true then
    ---- このタイミングでマップなどの機能をつける？
    --timer:close()
    --end
    --i = i + 1
    --end))
    print('[Fim] get file lists..')
    local dir_table = get_dir_table()
    print('[Fim] end')
    vim.api.nvim_create_augroup('fimInput', {})
    vim.api.nvim_create_autocmd('CursorMovedI', {
        group = 'fimInput',
        callback = function()
            showFoundFiles(dir_table)
        end,
        buffer = vim.g.fim_input_bufnr,
    })

    vim.api.nvim_win_set_option(vim.g.fim_input_winid, 'winhl', 'Normal:NormalFloat')
end
-- }}}
--# create inputbox prompt (prompt){{{
local function create_prompt(config, prompt)
    vim.g.fim_prompt_bufnr = vim.api.nvim_create_buf(false, true)
    vim.g.fim_prompt_winid = vim.api.nvim_open_win(vim.g.fim_prompt_bufnr, false, config)
    vim.api.nvim_buf_set_lines(vim.g.fim_prompt_bufnr, 0, -1, true, { prompt })

    vim.api.nvim_win_set_option(vim.g.fim_prompt_winid, 'winhl', 'Normal:NormalFloat')
    vim.fn.win_gotoid(vim.g.fim_input_winid)
end
-- }}}
--# create all windows {{{
local function create_ffwin(pre_winid)
    local lines             = vim.opt.lines:get()
    local columns           = vim.opt.columns:get()
    local fim_height        = math.floor(lines / 2)
    local info_height       = 4
    local input_height      = 1
    local flame_height      = 2
    local fim_width         = math.floor(columns / 2)
    local prompt            = [[>> ]]
    local prompt_width      = string.len(prompt)
    local statusline_height = 1
    local offset_col        = 0
    local offset_row        = 0

    local config_selector   = {
        width = math.floor(columns / 2),
        col = columns - fim_width - offset_col - 2,
        height = fim_height - info_height - input_height,
        row = lines - fim_height - (flame_height * 3) - offset_row + statusline_height,
        border = {
            ".", "-", ".", "|",
            "", "", "", "|",
        },
        focusable = true,
    }

    local config_inputbox   = {
        width = math.floor(columns / 2) - prompt_width,
        col = columns - fim_width - offset_col + prompt_width - 1,
        height = input_height,
        row = lines - info_height - input_height - (flame_height * 2) + statusline_height - offset_row - 1,
        border = {
            "", "-", ".", "|",
            "'", "", "", "",
        },
        focusable = true,
    }
    local config_prompt     = {
        width = prompt_width,
        col = columns - fim_width - offset_col - 2,
        height = input_height,
        row = lines - info_height - input_height - (flame_height * 2) + statusline_height - offset_row - 1,
        border = {
            ".", "-", "", "",
            "", "-", "`", "|",
        },
        focusable = false,
    }

    local config_infobox    = {
        width = math.floor(columns / 2),
        col = columns - fim_width - offset_col - 2,
        height = info_height,
        row = lines - info_height - flame_height - statusline_height - offset_row,
        border = {
            "|", "", "|", "|",
            "'", "-", "`", "|",
        },
        focusable = false,
    }
    local commonconfig      = {
        style    = 'minimal',
        relative = 'editor',
    }
    for k, v in pairs(commonconfig) do
        --TODO
        config_infobox[k] = v
        config_selector[k] = v
        config_inputbox[k] = v
        config_prompt[k] = v
    end

    create_selector(config_selector, pre_winid)
    create_infobox(config_infobox)
    create_prompt(config_prompt, prompt)
    create_inputbox(config_inputbox)
end
-- }}}

--################################ commands ##########################################
--# create Fim command{{{
vim.api.nvim_create_user_command("Fim",
    function()
        local pre_winid = vim.fn.win_getid()
        --vim.cmd("hi! def link FimMatch Function")
        vim.cmd("hi! def link FimMatch CursorLineNr")
        vim.cmd("hi! def link FimMatchAll Title")
        vim.cmd("hi! def link FimMsg Statement")
        create_ffwin(pre_winid)
    end,
    { bang = true }
) -- }}}
