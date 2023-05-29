vim.cmd[[
"{{{ mapping
"{{{ override default key bind
map K k
function! RemapQ()abort
    try
        noautocmd normal! @@
        call HighlightEcho("info", "@@")
    catch
        call HighlightEcho("error", "repatable macro is not exist")
    endtry
endfunction

map Q :call RemapQ()<CR>
"}}}"
"{{{ leader key
let mapleader = "\<Space>"
"}}}
"{{{ normal mode
"{{{ hide search highlighting
nnoremap <silent> <C-c> :nohl<CR>
"}}}
"{{{ open netrw window
function! WinExLeft() abort
    "open directory as root that current file exist
    "if failed to execute, then open Documents as root dir
    try
        if expand('%h') == ""
            execute "cd ~/Documents"
            execute "Lexplore ~/Documents/"
        else
            cd %:p:h
            Lexplore %:p:h
        endif
    catch
        execute "cd ~/Documents"
        execute "Lexplore ~/Documents/"
        call HighlightEcho("info",  "open ~/Documents as root")
    endtry
endfunction

nnoremap <Leader>e :call WinExLeft()<CR>
"}}}
"{{{ change pwd to current file directory
function! ChangePWD() abort
    "if(&filetype != "netrw")
        "return
    "endif
    try
        cd %:p:h
        call HighlightEcho("info", "change pwd to >> " . escape(getcwd(), "\\"))
    catch
        call HighlightEcho("error", "failed to change pwd")
    endtry
endfunction

nnoremap <silent> <Leader>cd :call ChangePWD()<CR>
"}}}
"{{{ switch buffer
function! SwitchBuff(key) abort
    "abort switchng at netrw
    if (&filetype == "netrw")
        call HighlightEcho("warning", "operation is invalid at netrw")
        return
    endif

    "abort switching at BuffCtl
    if exists("s:bufctl_bufnr") && (bufnr() == s:bufctl_bufnr)
        call HighlightEcho("warning", "operation is invalid at BuffCtl")
        return
    endif

    if a:key == 1
        let l:cmd = "bnext"
    else
        let l:cmd = "bprev"
    endif

    while 1
        exec l:cmd
        if &buflisted == 0
            continue
        else
            call HighlightEcho("info", "buffer switched to >> " . escape(bufname(bufnr()), "\\"))
            break
        endif
    endwhile
endfunction

function! SkipBuff() abort
endfunction

nnoremap <silent> <Leader>h :call SwitchBuff(-1)<CR>
nnoremap <silent> <Leader>l :call SwitchBuff(1)<CR>
"}}}
"{{{ hiragana jump
"ひらがなにたいしてえふもーしょんでいどうすることができる.りーだー,えふ,ろーまじをにゅうりょくでたいしょうのひらがなにとべる.:h digraph-table
nnoremap <leader>f f<C-k>
nnoremap <leader>F F<C-k>

"}}}
"}}}
"{{{ visual mode
"{{{ sorround ---"    
vnoremap <silent> <Leader>" :call SurroundStr('"', '"')<CR>
vnoremap <silent> <Leader>' :call SurroundStr("'", "'")<CR>
vnoremap <silent> <Leader>( :call SurroundStr('(', ')')<CR>
vnoremap <silent> <Leader>[ :call SurroundStr('[', ']')<CR>
vnoremap <silent> <Leader>{ :call SurroundStr('{', '}')<CR>
vnoremap <silent> <Leader>< :call SurroundStr('<', '>')<CR>
vnoremap <silent> <Leader>% :call SurroundStr('%', '%')<CR>

function! SurroundStr(surround_char1, surround_char2) abort
    exec "noautocmd normal! `<i" . a:surround_char1
    exec "noautocmd normal! `>la" . a:surround_char2
endfunction
"}}}    
"{{{ comment ---"
let s:comment_char_dict = {
    \ "vim" : '"',
    \ "c"   : '//',
    \ "cs"  : '//',
    \ "py"  : '#',
    \ "ttl" : ';',
    \ }

function! CommentSelectedLine() abort
    let l:extension = expand("%:e")
    if expand("%:t") == '.vimrc'
        execute "noautocmd normal! ^i" . '"'
    elseif has_key(s:comment_char_dict, l:extension)
        execute "noautocmd normal! ^i" . s:comment_char_dict[l:extension]
    endif
endfunction

vnoremap <silent> <Leader>/ :call CommentSelectedLine()<CR>
"}}}
"}}}
"{{{ insert mode
imap <C-c> <Esc>
"}}}
"{{{ insert and command mode
"{{{ move into brackets when insert enclosing character ---"
noremap! "" ""<Left>
noremap! '' ''<Left>
noremap! () ()<Left>
noremap! [] []<Left>
noremap! {} {}<Left>
noremap! <> <><Left>
noremap! %% %%<Left>
"}}}
"}}}
"{{{ terminal mode
"{{{ change mode to normal ---"
tnoremap <C-\> <C-\><C-N>
"}}}
"}}}
"=================================================================================================================================================================}}}
]]
