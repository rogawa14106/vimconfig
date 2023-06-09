vim.cmd[[
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
        "call HighlightEcho("info", "load fold view")
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
    if &buftype == 'help'
        bw
        return
    endif
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
"{{{ ime off at insertmode leave TODO
if has('windows')
    augroup cancellIME
        let myvimrc_path = substitute($MYVIMRC, '\\', '/', 'g')
        let chime_path = substitute(myvimrc_path, '\v[^/]+$', '', '') . "bin/chime.exe"
        let chime_cmd = "call system('" . chime_path . " 0')"
        autocmd!
        autocmd InsertLeave  * : execute chime_cmd
        autocmd CmdlineLeave * : execute chime_cmd
    augroup END
endif
"}}}
]]

vim.api.nvim_create_augroup( "detectft", {} )
vim.api.nvim_create_autocmd('bufwinenter', {
    group = 'detectft',
    callback = function() 
        vim.cmd('filetype detect')
    end,
})
