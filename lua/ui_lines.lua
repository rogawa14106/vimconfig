vim.cmd[[
"{{{ utility
"{{{ foldtext
function! MyFoldtext() abort
    return printf("[%4d lines ] %s", v:foldend - v:foldstart + 1, getline(v:foldstart))
endfunction

set foldtext=MyFoldtext()
"}}}
"{{{ statusline
function! MyStatusline() abort
    let l:mode_str = mode()
    let l:mode_status = ""
    if (&filetype == "netrw")
        "netrw"
        let l:mode_color  = "%1*%#mmodenormal#"
        let l:mode_status = "\ NETRW\ %*"
    elseif (l:mode_str == "n")
        let l:mode_color  = "%1*%#mmodenormal#"
        let l:mode_status = "\ NORMAL\ %*"
    elseif (l:mode_str == "i")
        let l:mode_color  = "%1*%#mmodeinsert#"
        let l:mode_status = "\ INSERT\ %*"
    elseif (l:mode_str == "R")
        let l:mode_color  = "%1*%#mmodeinsert#"
        let l:mode_status = "\ REPLACE\ %*"
    elseif (l:mode_str == "c")
        let l:mode_color  = "%1*%#mmodecommand#"
        let l:mode_status = "\ COMMAND\ %*"
    elseif (l:mode_str == "v")
        let l:mode_color  = "%1*%#mmodevisual#"
        let l:mode_status = "\ VISUAL\ %*"
    elseif (l:mode_str == "V")
        let l:mode_color  = "%1*%#mmodevisual#"
        let l:mode_status = "\ VLINE\ %*"
    elseif (l:mode_str == "")
        let l:mode_color  = "%1*%#mmodevisual#"
        let l:mode_status = "\ VBLOCK\ %*"
    else
        let l:mode_color  = "%1*%#mmodevisual#"
        let l:mode_status = "\ " . mode() . "\ %*"
    endif

    if (&buftype == "terminal")
        "terminal"
        if (l:mode_str == "n")
            let l:mode_color  = "%1*%#mmodeterm#"
            let l:mode_status = "\ TERMINAL-NORMAL\ %*"
        elseif (l:mode_str == "t")
            let l:mode_color  = "%1*%#mmodetjob#"
            let l:mode_status = "\ TERMINAL-JOB\ %*"
        endif
    endif

    "left :dig Bd"
    let l:mystatusline = l:mode_color . l:mode_status
    let l:mystatusline .= "[%n]%h%m%F"

    "center"
    let l:mystatusline .= "\ %#statuslinenc#%<"

    "right"
    let l:mystatusline .= "%="
    let l:mystatusline .= "%#statusline#"
    let l:mystatusline .= "[%l/%L]\ "
    let l:mystatusline .= l:mode_color
    let l:mystatusline .= "\ [%{&buftype!=''?&buftype:&filetype}]"
    let l:mystatusline .= "\ [%{&fileencoding!=''?&fileencoding:&encoding},"
    let l:mystatusline .= "%{&fileformat}]\ "
    return l:mystatusline
endfunction

set statusline=%!MyStatusline()
"}}}
"{{{ tabline
set showtabline=2

function! MyTabLine() abort
    let l:tabstring = ''
    let t = tabpagenr()
    let i = 1
    while i <= tabpagenr('$')
        let l:buflist = tabpagebuflist(i)
        let l:winnr = tabpagewinnr(i)

        let l:tabstring .= '%*'
        let l:tabstring .= (i == t ? '%#TabLineSel#' : '%#TabLine#')

        let l:tabstring .= '['

        let bufnr = l:buflist[l:winnr - 1]
        let file = bufname(bufnr)
        let buftype = getbufvar(bufnr, 'buftype')

        if buftype == 'nofile'
            if file =~ '\/.'
                let file = substitute(file, '.*\/\ze.', '', '')
            endif
        else
            let file = fnamemodify(file, ':p:t')
            "let file = expand('%:p:t')
        endif

        if (i == t) && (&filetype == "netrw")
            let file = "NETRW"
        elseif file == ''
            let file = 'No Name'
        endif

        let l:tabstring .= file

        let l:tabstring .= ']'

        let i = i + 1
    endwhile

    let l:tabstring .= '%T%#TabLineFill#%='

    let l:pwd = getcwd()
    let l:tabstring .= '%#TabLineSel# pwd: ' . l:pwd . ' '

    return l:tabstring 
endfunction
set tabline=%!MyTabLine()
"}}}
"{{{ Sign

"{{{Init SignID
sign define sign1 text=`m texthl=Sign
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
    let l:learge_int = 9223372036854775807
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

nnoremap <silent> <Leader>mm :call ToggleSign()<CR>
nnoremap <silent> <Leader>mj :call SignJump(1)<CR>
nnoremap <silent> <Leader>mk :call SignJump(-1)<CR>
nnoremap <silent> <Leader>md :call DeleteAllSign()<CR>

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
"=================================================================================================================================================================}}}
]]

