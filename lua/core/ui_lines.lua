vim.cmd [[
"{{{ Sign

"{{{Init SignID
sign define sign1 text=◆ texthl=Sign
"get bigest sigh id to be id as id
function! InitSignID() abort
    let l:m_placed_sign_list = sign_getplaced("")[0].signs
    if (len(l:m_placed_sign_list) == 0)
        let g:sign_id = 0
        return
    endif
    let l:max_sign_id = 0
    for sign_dict in l:m_placed_sign_list
        if (sign_dict.id > l:max_sign_id)
            execute "let l:max_sign_id = " . str2nr(sign_dict.id)
        endif
    endfor
    let g:sign_id = l:max_sign_id
endfunction
call InitSignID()
"}}}
"{{{ Is sign iHexist On Current Line
"confirm is existing sign at current line
"exist: id, not exist: 0
function! IsSignExistOnCurrentLine() abort
    let l:m_placed_sign_list = sign_getplaced("")[0].signs
    "sign was not placed at entire current buffer, return 0
    if (len(l:m_placed_sign_list) == 0)
        return 0
    endif

    let l:current_line = line(".")
    "sign was placed at current line, return sigh_dict.id
    for sign_dict in l:m_placed_sign_list
        if (sign_dict.lnum == l:current_line)
            return sign_dict.id
        endif
    endfor

    return 0
endfunction
"}}}
"{{{Toggle Sign
function! ToggleSign() abort
    let l:current_line_sign_id = IsSignExistOnCurrentLine()
    if (l:current_line_sign_id == 0)
        "sign was not placed, place sigh
        let g:sign_id += 1
        let l:current_line = line(".")
        execute "sign place " . g:sign_id . " name=sign1 line=" . l:current_line
    else
        "sign was placed, delete the sigh
        execute "sign unplace " . l:current_line_sign_id
    endif

endfunction
"}}}
"{{{ Jump Line placed Sign
function! SignJump(jump_flg) abort
    "sign was not placed at entire current buffer, return 0
    let l:m_placed_sign_list = sign_getplaced("")[0].signs
    if (len(l:m_placed_sign_list) == 0)
        return
    endif

    "init with large int
    let l:learge_int = v:numbermax "9223372036854775807
    let l:next_sign_distance_p = l:learge_int
    "distance to the furthest sign in the opposite direction(negative number -> n)
    let l:next_sign_distance_n = 0

    "行き先のsignのID
    let l:sign_id_p = 0
    let l:sign_id_n = 0

    for sign_dict in l:m_placed_sign_list
        "Change then positive or negative of the distance used for calculation depending on whether you go up or down
        "the value of direction you want to go is an positive
        if (a:jump_flg == 1)
            let l:next_sign_distance = sign_dict.lnum - line(".")
        elseif (a:jump_flg == -1)
            let l:next_sign_distance = line(".") - sign_dict.lnum
        endif

        "seek the closest sign
        "diverge variable to evaluate depending on whether positive or negative
        if (l:next_sign_distance > 0)
            "positive
            if (l:next_sign_distance_p > l:next_sign_distance)
                let l:next_sign_distance_p = l:next_sign_distance
                let l:sign_id_p = sign_dict.id
            endif
        elseif (l:next_sign_distance < 0)
            "negative
            if (l:next_sign_distance_n > l:next_sign_distance)
                let l:next_sign_distance_n = l:next_sign_distance
                let l:sign_id_n = sign_dict.id
            endif
        endif
    endfor

    if (l:next_sign_distance_p==0 && l:next_sign_distance_n==0)
        return
    elseif (l:next_sign_distance_p != l:learge_int)
        execute "sign jump " . l:sign_id_p
    elseif (l:next_sign_distance_n != 0)
        execute "sign jump " . l:sign_id_n
    endif
endfunction
"}}}
"{{{ DeleteAllSign
function! DeleteAllSign() abort
    let l:m_placed_sign_list = sign_getplaced("")[0].signs
    for sign_dict in l:m_placed_sign_list
        execute "sign unplace " . sign_dict.id
    endfor
endfunction

"}}}

nnoremap <silent> <Leader>st :call ToggleSign()<CR>
nnoremap <silent> <Leader>sj :call SignJump(1)<CR>
nnoremap <silent> <Leader>sk :call SignJump(-1)<CR>
nnoremap <silent> <Leader>sd :call DeleteAllSign()<CR>

"}}}
"{{{ HiTest (highlight test tool)

"{{{Main
function! HiTest () abort
    "open temporary file
    botright split
    enew
    resize 14
    set buftype=nofile
    set nobuflisted
    setlocal nonu nornu
    let g:u_hitestbufnr = bufnr()
    augroup PreQuitDeleteBuffer
        au!
        au WinClosed <buffer> :execute "bd! " . g:u_hitestbufnr
    augroup END

    "initial rgb"
    let g:u_hitest_r = 0xf3
    let g:u_hitest_g = 0xc2
    let g:u_hitest_b = 0x9b

    "define mappings to adjust colors"
    nnoremap <buffer> <silent> k :<c-u>call ChangeColorHiTest("u", v:count1)<CR>
    nnoremap <buffer> <silent> j :<c-u>call ChangeColorHiTest("d", v:count1)<CR>

    "write"
    noautocmd normal! Gdgg
    let l:colorstr = "R:". g:u_hitest_r . " G:". g:u_hitest_g . " B:". g:u_hitest_b . "#" . printf("%02x", g:u_hitest_r) . printf("%02x", g:u_hitest_g) . printf("%02x", g:u_hitest_b)
    call append(line("$"), "RGB@%")
    call append(line("$"), "^^^^^")
    call append(line("$"), l:colorstr)
    call append(line("$"), "")
    call append(line("$"), "HT_bg_test__test__test__test__test__test__test__test_bg_HT")
    call append(line("$"), "")
    call append(line("$"), "HT_fg_test__test__test__test__test__test__test__test_fg_HT")
    call append(line("$"), "")
    call append(line("$"), "\"=== Highlight Test Tool =================================")
    call append(line("$"), "\"= Usage:                                                =")
    call append(line("$"), "\"=    press <count><up or down> key on 'RGB'             =")
    call append(line("$"), "\"=                                                       =")
    call append(line("$"), "\"=========================================================")
    noautocmd normal! dd

    call InitHiTest()
endfunc
"}}}

"{{{ ChangeColorValue
function! ChangeColorHiTest(operation, offset) abort
    let l:cursorChar = getline('.')[col('.')-1]
    if a:operation == "u"
        let l:offset = a:offset
    elseif a:operation == "d"
        let l:offset = a:offset * -1
    else
        return
    endif

    if l:cursorChar == "R"
        let g:u_hitest_r = g:u_hitest_r + l:offset
        let g:u_hitest_r = g:u_hitest_r < 1   ? 0 : g:u_hitest_r
        let g:u_hitest_r = g:u_hitest_r > 255 ? 255 : g:u_hitest_r
    elseif l:cursorChar == "G"
        let g:u_hitest_g = g:u_hitest_g + l:offset
        let g:u_hitest_g = g:u_hitest_g < 1   ? 0 : g:u_hitest_g
        let g:u_hitest_g = g:u_hitest_g > 255 ? 255 : g:u_hitest_g
    elseif l:cursorChar == "B"
        let g:u_hitest_b = g:u_hitest_b + l:offset
        let g:u_hitest_b = g:u_hitest_b < 1   ? 0 : g:u_hitest_b
        let g:u_hitest_b = g:u_hitest_b > 255 ? 255 : g:u_hitest_b
    elseif l:cursorChar == "@"
        let g:u_hitest_r = g:u_hitest_r + l:offset
        let g:u_hitest_r = g:u_hitest_r < 1   ? 0 : g:u_hitest_r
        let g:u_hitest_r = g:u_hitest_r > 255 ? 255 : g:u_hitest_r
        let g:u_hitest_g = g:u_hitest_g + l:offset
        let g:u_hitest_g = g:u_hitest_g < 1   ? 0 : g:u_hitest_g
        let g:u_hitest_g = g:u_hitest_g > 255 ? 255 : g:u_hitest_g
        let g:u_hitest_b = g:u_hitest_b + l:offset
        let g:u_hitest_b = g:u_hitest_b < 1   ? 0 : g:u_hitest_b
        let g:u_hitest_b = g:u_hitest_b > 255 ? 255 : g:u_hitest_b
    else
        resize 14
        noautocmd normal! gg
        return
    endif

    call InitHiTest()

endfunction
"}}}

"{{{ InitColor
function! InitHiTest() abort
    setlocal modifiable
    setlocal noreadonly
    "noautocmd normal! Gddgg
    let l:colorstr = "#" . printf("%02x", g:u_hitest_r) . printf("%02x", g:u_hitest_g) . printf("%02x", g:u_hitest_b) . ", R:". g:u_hitest_r . ", G:". g:u_hitest_g . ", B:". g:u_hitest_b
    call append(2, l:colorstr)
    noautocmd normal! mmgg3jddgg`m

    "call matchadd('HiTestbg',"^HT_bg.\+HT$")
    "call matchadd('HiTestfg',"^HT_fg.\+HT$")
    syntax match HiTestbg /\v^HT_bg.+HT$/
    syntax match HiTestfg /\v^HT_fg.+HT$/
    exec "highlight! HiTestbg gui=none cterm=none guifg=#FFFFFF guibg=#" . printf("%02x", g:u_hitest_r) . printf("%02x", g:u_hitest_g) . printf("%02x", g:u_hitest_b)
    exec "highlight! HiTestfg gui=none cterm=none guibg=#181818 guifg=#" . printf("%02x", g:u_hitest_r) . printf("%02x", g:u_hitest_g) . printf("%02x", g:u_hitest_b)
    setlocal nomodifiable
    setlocal readonly
    setlocal buftype=nofile
    setlocal nobuflisted
endfunction
"}}}

command! -nargs=? HT :call HiTest(<f-args>)

"}}}
]]

-- foldtext{{{
MyFoldtext = function()
    local line = vim.fn.substitute(vim.fn.getline(vim.v.foldstart), '{', "", "g")
    return vim.fn.printf("[%4d lines ] %s", vim.v.foldend - vim.v.foldstart + 1, line)
end

vim.opt.foldtext = "v:lua.MyFoldtext()"
-- }}}
-- tabline{{{
MyTabLine = function()
    local tabstring = ''
    local t = vim.fn.tabpagenr()
    local i = 1
    while i <= vim.fn.tabpagenr('$') do
        local buflist = vim.fn.tabpagebuflist(i)
        local winnr = vim.fn.tabpagewinnr(i)
        -- print(vim.inspect(buflist), winnr)

        tabstring = tabstring .. '%*'
        if (i == t) then
            tabstring = tabstring .. [[%#TabLineSel#]]
        else
            tabstring = tabstring .. [[%#TabLine#]]
        end

        tabstring = tabstring .. '['

        local bufnr = buflist[winnr - 1 + 1]
        local file = vim.fn.bufname(bufnr)
        local buftype = vim.fn.getbufvar(bufnr, 'buftype')

        if buftype == 'nofile' then
            if file == '\\/.' then
                file = vim.fn.substitute(file, '.*\\/\ze.', '', '')
            end
        else
            file = vim.fn.fnamemodify(file, ':p:t')
        end

        if (i == t) and (vim.opt.filetype:get() == "netrw") then
            file = "NETRW"
        elseif file == '' then
            file = 'No Name'
        end

        tabstring = tabstring .. file

        tabstring = tabstring .. ']'

        i = i + 1
    end

    tabstring = tabstring .. [[%T%#TabLineFill#%=]]

    local cwd = vim.fn.getcwd()
    tabstring = tabstring .. [[%#TabLineSel# cwd: ]] .. cwd .. ' '
    tabstring = tabstring .. [[%#TabLineFill#]]

    return tabstring
end
vim.opt.showtabline = 2
vim.opt.tabline = "%!v:lua.MyTabLine()"
-- }}}

local stl_colors = {
    blue = {
        "7cf4cf",
        "6ce4bf",
        "5cd4af",
        "4cb49f",
        "3ca48f",
        "2c947f",
        "1c846f",
        "0c745f",
    },
    mono = {
        "81829h",
        "717284",
        "616274",
        "515264",
        "414254",
        "313244",
        "212234",
        "111224",
    },
}
---@param type "r"|"l"
local make_separator = function(type, N, is_end)
    local sep_list = {
        ['r'] = "◣",
        ['l'] = "◢",
    }
    local hi = ""
    if is_end then
        vim.cmd("hi uStlSepEnd" .. type .. " gui=none guifg=#" .. stl_colors.blue[N] .. "")
        hi = "%#uStlSepEnd" .. type .. "#"
    else
        hi = "%#uStlSep" .. N .. "#"
    end
    local sep = hi .. sep_list[type] .. "%*"
    return sep
end

local stat_mode = function()
    local current_mode_str = vim.fn.mode()
    local mode_list = {
        { mode_str = "n", disp_str = "NORMAL",   color = "mModeNormal", },
        { mode_str = "i", disp_str = "INSERT",   color = "mModeInsert", },
        { mode_str = "R", disp_str = "REPLACE",  color = "mModeInsert", },
        { mode_str = "c", disp_str = "COMMAND",  color = "mModeCommand", },
        { mode_str = "v", disp_str = "VISUAL",   color = "mModeVisual", },
        { mode_str = "V", disp_str = "V-LINE",   color = "mModeVisual", },
        { mode_str = "", disp_str = "V-BLOCK",  color = "mModeVisual", },
        { mode_str = "t", disp_str = "TERM-JOB", color = "mModeVisual", },
    }
    -- "%1*%#mmodeterm# TERMINAL-NORMAL %*"
    local status_line_mode = ""
    local is_match = false
    for i = 1, #mode_list do
        if mode_list[i].mode_str == current_mode_str then
            status_line_mode = status_line_mode .. "%#" .. mode_list[i].color .. "#"
            status_line_mode = status_line_mode .. " " .. mode_list[i].disp_str .. " "
            is_match = true
            break
        end
    end
    if is_match == false then
        status_line_mode = current_mode_str
    end
    status_line_mode = status_line_mode .. "%*"
    return status_line_mode
end

StatusLine = function()
    -- define colors
    vim.cmd("hi uStlSep1 gui=none guifg=#" .. stl_colors.blue[1] .. " guibg=#" .. stl_colors.blue[2] .. "")
    vim.cmd("hi uStlSep2 gui=none guifg=#" .. stl_colors.blue[2] .. " guibg=#" .. stl_colors.blue[3] .. "")
    vim.cmd("hi uStlSep3 gui=none guifg=#" .. stl_colors.blue[3] .. " guibg=#" .. stl_colors.blue[4] .. "")
    vim.cmd("hi uStlSep4 gui=none guifg=#" .. stl_colors.blue[4] .. " guibg=#" .. stl_colors.blue[5] .. "")
    vim.cmd("hi uStlSep5 gui=none guifg=#" .. stl_colors.blue[5] .. " guibg=#" .. stl_colors.blue[6] .. "")
    vim.cmd("hi uStlSep6 gui=none guifg=#" .. stl_colors.blue[6] .. " guibg=#" .. stl_colors.blue[7] .. "")
    vim.cmd("hi uStlSep7 gui=none guifg=#" .. stl_colors.blue[7] .. " guibg=#" .. stl_colors.blue[8] .. "")

    vim.cmd("hi uStlStat1 gui=none guifg=#" .. stl_colors.mono[8] .. " guibg=#" .. stl_colors.blue[2] .. "")
    vim.cmd("hi uStlStat2 gui=none guifg=#" .. stl_colors.mono[8] .. " guibg=#" .. stl_colors.blue[3] .. "")
    vim.cmd("hi uStlStat3 gui=none guifg=#" .. stl_colors.mono[8] .. " guibg=#" .. stl_colors.blue[4] .. "")
    vim.cmd("hi uStlStat4 gui=none guifg=#" .. stl_colors.mono[8] .. " guibg=#" .. stl_colors.blue[5] .. "")
    vim.cmd("hi uStlSepEndr gui=none")
    vim.cmd("hi uStlSepEndl gui=none")

    local stl = ""
    -- left of stl
    stl = stl .. stat_mode()
    stl = stl .. "%#uStlStat1#" .. " %n%M " .. make_separator('r', 2)
    stl = stl .. "%#uStlStat2#" .. " %F " .. make_separator('r', 3, true)

    --center of stl
    stl = stl .. "%<%="

    --right of stl
    stl = stl .. make_separator('l', 5, true) .. "%#uStlStat4#" .. " %c,%l/%L "
    stl = stl .. make_separator('l', 4) .. "%#uStlStat3#" .. " %{&buftype!=''?&buftype:&filetype} "
    stl = stl .. make_separator('l', 3) .. "%#uStlStat2#" .. " %{&fileencoding!=''?&fileencoding:&encoding} "
    stl = stl .. make_separator('l', 2) .. "%#uStlStat1#" .. " %{&fileformat} "
    return stl
end

vim.opt.statusline = "%!v:lua.StatusLine()"
