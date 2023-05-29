vim.cmd[[
"{{{ autocmd
"{{{ ime off at insertmode leave TODO
if has('windows') || has('wsl')
    augroup cancellIME
        autocmd!
        autocmd InsertLeave  * : call system('chime 0')
        autocmd CmdlineLeave * : call system('chime 0')
    augroup END
endif
"}}}
"{{{ save and load fold state
function! SaveFold() abort
    try
        mkview
    catch
    endtry
endfunction

function! LoadFold() abort
    try
        loadview
        call HighlightEcho("info", "load fold view")
    catch
    endtry
endfunction

augroup AutoSaveFold
    autocmd!
    autocmd BufWinLeave * call SaveFold()
    autocmd BufReadPost * call LoadFold()
augroup END
"}}}
"{{{ don't close vim when execute :q, 
function! ForeverVim() abort
    let l:win_info = getwininfo()
    let l:win_cnt = len(l:win_info)
    let l:is_quit = 0
    if l:win_cnt == 1
        let l:is_quit = 1
    elseif (l:win_cnt == 2)
        for i in range(2)
            let l:win_bufnr = l:win_info[i].bufnr
            let l:win_bufinfo = getbufinfo(l:win_bufnr)[0]
            if !has_key(l:win_bufinfo.variables, "current_syntax")
                break
            endif
            let l:win_cur_syn = getbufinfo(l:win_bufnr)[0].variables.current_syntax
            if l:win_cur_syn == 'help'
                let l:is_quit = 1
                break
            endif
        endfor
        echo l:is_quit
    endif

    if l:is_quit
        let l:bufnr = bufadd("")
        vs
        execute "b " . l:bufnr
        call HighlightEcho("info", "if you want to quit vim, execute like :qa.")
        call HighlightEcho("info", "Otherwise, you will stay in vim FOREVER")
    endif
endfunction

augroup ForeverVim
    au!
    au QuitPre * call ForeverVim()
augroup END
"}}}
"=================================================================================================================================================================}}}
]]

