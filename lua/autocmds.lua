vim.cmd[[
"{{{ autocmd
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
"=================================================================================================================================================================}}}
]]

--vim.api.nvim_create_augroup('loadFold', {})
--vim.api.nvim_create_autocmd('insertleave', {
    --group = 'loadFold'
    --callback = (function()
       -- 
    --end)
--})

--vim.api.nvim_create_autocmd('insertleave', {
    --group = 'saveFold'
    --callback = (function()
       -- 
    --end)
--})

--local cmd_chime = Vimrcdir .. "/bin/chime.exe 0"
--
--vim.api.nvim_create_augroup( "cancellIME", {} )
--vim.api.nvim_create_autocmd( 'insertleave', {
    --group = 'cancellIME',
    --callback = (function()
        --os.execute(cmd_chime)
        --os.exit()
    --end)
--})

--vim.api.nvim_create_autocmd( 'cmdlineleave', {
    --group = 'cancellIME',
    --callback = function () vim.cmd(cmd_chime) end
--})

