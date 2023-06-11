if vim.fn.has('nvim') then
vim.cmd [[
"{{{ FloatingBuffCtl (buffer operation window)
"{{{ Main(Floating Window)
function! BuffCtlFloat() abort
    "noautocmd normal! mz
    let g:winid = win_getid()

    let l:buflineinfo =  MakeBuffCtlLineInfo()
    let l:buflines =  l:buflineinfo.buflines
    let l:longest_line =  l:buflineinfo.longest_line
    let l:welcomemsg = "< Welcome to BuffCtl! Scroll down for help >"

    if exists("g:bufctl_bufnr")
        if (bufnr() == g:bufctl_bufnr)
            :bd
            call win_gotoid(g:winid)
            return
        endif
    else
        let g:bufctl_bufnr = nvim_create_buf(v:false, v:true)
    endif

    let l:bufheight = len(l:buflines) + 2
    let l:bufwidth  = len(l:welcomemsg)
    if l:longest_line > l:bufwidth - 1
        let l:bufwidth  = l:longest_line + 1
    endif
    let l:bufrow    = &lines - l:bufheight - 5
    let l:bufcol    = &columns - l:bufwidth - 4
    let l:enter = v:true
    let l:border_tr = "."
    let l:border_tl = "."
    let l:border_v  = "|"
    let l:border_h  = "-"
    let l:border_br = "'"
    let l:border_bl = "`"
    let l:bufborder = [l:border_tl, l:border_h, l:border_tr, l:border_v, l:border_br, l:border_h, l:border_bl, l:border_v]
    let l:winconf = {
        \ 'style': 'minimal',
        \ 'relative': 'editor',
        \ 'width': l:bufwidth,
        \ 'height': l:bufheight,
        \ 'row': l:bufrow,
        \ 'col': l:bufcol,
        \ 'focusable': v:true,
        \ 'border': l:bufborder,
        \ }
    "when bufctl aleady active, goto bufctl window
    if len(win_findbuf(g:bufctl_bufnr)) > 0
        call win_gotoid(g:bufctl_winid)
    else
        "open new window
        let g:bufctl_winid = nvim_open_win(g:bufctl_bufnr, l:enter, l:winconf)
        "set option
        call nvim_win_set_option(g:bufctl_winid, 'winhl', 'Normal:CursorLineNr')
        call matchadd('BufCtlLineTail', '\v[^/]+\.[^\. ]+$')
        highlight! def link BufCtlLineTail Title
        call matchadd('BufCtlCautionMark', '\v\[!\]')
        highlight! def link BufCtlCautionMark ErrorMsg
        call matchadd('BufCtlWarningMark', '\v\[[t+]\]')
        highlight! def link BufCtlWarningMark WarningMsg
        call matchadd('BufCtlMsg', '\v\<\s.+\s\>')
        highlight! def link BufCtlMsg Statement
        setlocal matchpairs=
        "add mapping
        nnoremap <buffer> <silent> <Enter> :call SelectBuffFloat("F") <CR>
        nnoremap <buffer> <silent> S :call SelectBuffFloat("S") <CR>
        nnoremap <buffer> <silent> V :call SelectBuffFloat("V") <CR>
        nnoremap <buffer> <silent> d :call DeleteBuffFloat()<CR>
    endif

    setlocal modifiable
    setlocal noreadonly

    "delete all line
    noautocmd normal! ggdG
    "write bufline
    call appendbufline(g:bufctl_bufnr, 0, l:buflines)

    call appendbufline(g:bufctl_bufnr, line("$"), l:welcomemsg)
    call appendbufline(g:bufctl_bufnr, line("$"), "<Enter> - open buffer*")
    call appendbufline(g:bufctl_bufnr, line("$"), "<S> - open buffer in horizontal split win*")
    call appendbufline(g:bufctl_bufnr, line("$"), "<V> - open buffer in vertical split win*")
    call appendbufline(g:bufctl_bufnr, line("$"), "<d> - delete buffer*")
    execute ":" . (len(l:buflines) + 2) . "," . (len(l:buflines) + 6) . " center " . l:bufwidth

    "return configs
    setlocal nomodifiable
    setlocal readonly
    setlocal buftype=nofile

    "move to top
    noautocmd normal! gg

endfunction

function! MakeBuffCtlLineInfo() abort
    let l:buflines = []
    let l:longest_line = 0
    let l:buf_infos = getbufinfo({"buflisted": 1})

    for l:bufinfo in l:buf_infos
        let l:bufnr   = l:bufinfo.bufnr
        let l:bufmod  = l:bufinfo.changed
        let l:bufstat = " "
        let l:bufname = l:bufinfo.name
        let l:bufwin  = l:bufinfo.windows
        let l:bufhidden  = l:bufinfo.hidden

        "buf status
        if(len(l:bufwin) > 0) && (g:winid == l:bufwin[0])
            let l:bufstat = "!"
        endif

        let l:buf_win = l:bufinfo.windows
        if(len(l:buf_win) > 0) && (g:winid == l:buf_win[0])
            let l:bufstat = "!"
        elseif  l:bufhidden == 0
            let l:bufstat = "a"
        endif

        "if buffer named don't assigned, set buffer name 'No Name'
        if l:bufname == ""
            let l:bufname = "No Name"
        endif

        "if buffertype is terminal
        if has_key(l:bufinfo.variables, "term_title")
            let l:bufname = l:bufinfo.variables.term_title
            let l:bufstat = "t"
        endif

        "substitute backslash and homepath
        if has('windows')
            let l:bufname = substitute(l:bufname, "\\", "/", "g")
            let l:bufname = substitute(l:bufname, 'C:/Users/[^/]\+/', "~/", "g")
        endif

        "is modified
        let l:bufmod = l:bufmod == 1 ? "+" : "-"

        "definge buff line
        let l:bufline = printf('[%02d][%s][%s] %s', l:bufnr, l:bufmod, l:bufstat, l:bufname)

        let l:line_length = len(l:bufline)
        if l:line_length > l:longest_line
            let l:longest_line = l:line_length
        endif
        "add line to buflines
        call add(l:buflines, l:bufline)
    endfor
    return {"buflines": l:buflines, "longest_line": l:longest_line}
endfunction

function! GetBufNrFromBufLine()
    "get selected buffer nr
    let l:bufdata = getline(line("."))
    let l:selected_bufnrs = matchlist(l:bufdata, '\v[0-9]+')
    if len(l:selected_bufnrs) == 0
        return 0
    else
        return l:selected_bufnrs[0]
    endif
endfunction
"}}}
"{{{SelectBuff
function! SelectBuffFloat(splittype) abort
    "getbufnr
    let l:selected_bufnr = GetBufNrFromBufLine()
    if l:selected_bufnr == 0
        call HighlightEcho("warning", "specified buffer does not exist")
        return
    endif
    "delete mapping
    nunmap <buffer> <Enter>
    nunmap <buffer> d
    "close
    call nvim_win_close(g:bufctl_winid, v:true)
    "move to the window that was open at the beginning
    call win_gotoid(g:winid)
    "noautocmd normal! `z
    "open buffer
    if a:splittype == "H"
        botright split
    elseif a:splittype == "V"
        botright vsplit
    endif
    execute "buffer " . str2nr(l:selected_bufnr)
    call HighlightEcho("info", "enter buffer " . l:selected_bufnr)
endfunction
"}}}"
"{{{DeleteBUff
function! DeleteBuffFloat() abort
    let l:selected_bufnr = GetBufNrFromBufLine()
    if l:selected_bufnr == 0
        call HighlightEcho("warning", "specified buffer does not exist")
        return
    endif

    "info gathering
    let l:bufinfo = getbufinfo(str2nr(l:selected_bufnr))[0]
    let l:is_buff_changed = l:bufinfo.changed
    let l:is_buff_current = 0
    let l:buf_win = l:bufinfo.windows
    if(len(l:buf_win) > 0) && (g:winid == l:buf_win[0])
        let l:is_buff_current = 1
    endif

    let l:is_exec_bd = 1

    if l:is_buff_current == 1
        call HighlightEcho("error", "current buffer can't be deleted.")
        return
        "let is_exec_bd = ConfirmDeleteBuff("this buffer is current buffer.", l:selected_bufnr)
    elseif l:is_buff_changed == 1
        let is_exec_bd = ConfirmDeleteBuff("no write since last change.", l:selected_bufnr)
    else
        try
            execute "bd " . l:selected_bufnr
        catch
            let l:confirm_msg = "force delete?"
            let l:is_exec_bd = ConfirmDeleteBuff(l:confirm_msg, l:selected_bufnr)
        endtry
    endif

    if l:is_exec_bd && !buflisted(l:selected_bufnr)
        "delete specific buffer line
        setlocal modifiable
        setlocal noreadonly
        noautocmd normal! dd
        setlocal nomodifiable
        setlocal readonly
        setlocal buftype=nofile

        "show msg
        call HighlightEcho("info", "delete buffer " . l:selected_bufnr)
    endif
endfunction

function! ConfirmDeleteBuff(confirm_msg, selected_bufnr) abort
    call HighlightEcho("info", a:confirm_msg . " -delete:y -cancel:n")
    let l:input_txt = input(":")
    echo " "

    echo l:input_txt
    if l:input_txt == "y"
        execute "bd! " . a:selected_bufnr
        return 1
    else
        call HighlightEcho("info", "delete was canceled")
        return 0
    endif
endfunction
"}}}
nnoremap <silent> <Leader>bb :call BuffCtlFloat()<CR>
"}}}
]]
end
