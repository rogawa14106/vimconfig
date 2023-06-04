"============                                                              ======"
"=========                     888X                                           ==="
"======         8888  888o          .888: x888  x888.                          =="
"===           888X  888X   @88X    8888~'888X`8888f                            ="
"==           888X  888X   888X    888X  888X  888X   R8bd88g  .d888g          =="
"=           888X  888X   888X    888X  888X  888X    88X'  ' d8r'  '         ==="
"==          888,.888P   888X    888X  888X  888X    88X     88i           ======"
"===          ^8V*""    888I    888X  X88X  X88M    88X      `?88Cx     ========="
"======                                                              ============"

"!!! NOTE !!!"
"{{{ must be done in unix env
"run the following command.
":set ff=unix | w
"}}}
"{{{ about commands
"To use the commands below, you need to be in your path.
"chime, hidesb
"To get executable file of the above command, run the following command.
"> git clone https://github.com/rogawa14106/vimconfig
"}}}
"{{{ defined Ex commands (Press <S-*>, jump to script)"
" VIMRC
" SP
" GUIColerToggle
" FS
" RS
" HSB
" HTB
" CPV
" GPV <commit msg: str>
" CMD <type: str>
" RF <fontsize :int>
"}}}

" common "
"{{{ base
"{{{ basic
if exists("g:vscode")
    finish
endif
set number
set autoindent smartindent
set cursorline
set noshowmode
set nowrap
set tabstop=4 shiftwidth=4 expandtab
set foldcolumn=0
"set foldmethod=manual
set foldmethod=marker
set noswf nobk noudf
set clipboard+=unnamed
set mouse=
set hidden
set matchpairs+=<:>
set nocompatible
set path+=**
"CG∾, 02⊚, 
set fillchars=fold:\ 
"}}}
"{{{ char
if (0 == match($USERNAME, 'rogawa'))
    set guifont=MyricaM\ M:h12
elseif (-1 < match($USERNAME, '152440'))
    set guifont=Myrica\ M:h12
else
    set guifont=ＭＳ\ ゴシック:h12
endif

set ambiwidth=double
set encoding=utf-8
set fileencodings=utf-8,sjis
set fileformats=dos,unix,mac
set list
if strgetchar("･", 0) == 65381
    set listchars+=tab:^\ ,eol:$,space:･
else
    set listchars+=tab:^\ ,eol:$
endif
"}}}
"=================================================================================================================================================================}}}
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

nnoremap <silent> <Leader>h :call SwitchBuff(-1)<CR>
nnoremap <silent> <Leader>l :call SwitchBuff(1)<CR>
"}}}
"{{{ hiragana jump
"ひらがなにたいしてえふもーしょんでいどうすることができる.りーだー,えふ,ろーまじをにゅうりょくでたいしょうのひらがなにとべる.:h digraph-table
""
"call digraph_setlist([['aa', 'あ'], ['ii', 'い'], ['uu', 'う'], ['ee', 'え'], ['oo', 'お'], ['xn', 'ん'], ['ji', 'じ']])
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
    \ "lua" : '--',
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
"{{{ command
"{{{ vimrc related
command! VIMRC :e $MYVIMRC
command! SP :source $MYVIMRC
"}}}
"{{{ Hide windows scroolbar
if has('windows')
    command! HSB :call system("hidesb -b")
    command! HTB :call system("hidetb")
endif
"}}}
"{{{ open terminal
function! OpenTerminal(...) abort
    "change key that will send to terminal at first and resize terminal
    if has("nvim")
        let l:termkey = "a"
        execute "horizontal belowright" . &lines/3 . "split"
    else
        let l:termkey = ""
        execute "set termwinsize=" . &lines/3 . "x0"
    endif

    "open terminal
    terminal
    if a:0 != 0
        echo winnr()
        execute winnr() . "windo :let b:term_title = 'terminal - " . a:1 "'"
        "let b:term_title = 'terminal - ' . a:1
    else
        execute winnr() . "windo :let b:term_title = 'terminal - '"
        let b:term_title = 'terminal - '
    endif
    
    "branch the commands to execute depending on the given arguments
    if a:0 == 0
        call feedkeys(l:termkey . "")
        let b:term_title = 'terminal'
    elseif a:1 == "time"
        call feedkeys(l:termkey . "prompt $d$s$t$g")
        let b:term_title = 'terminal - time'
    elseif a:1 == "file"
        call feedkeys(l:termkey . "ssh file")
        let b:term_title = 'terminal - file'
    elseif a:1 == "196"
        call feedkeys(l:termkey . "ssh 196")
        let b:term_title = 'terminal - 196'
    elseif a:1 == "177"
        call feedkeys(l:termkey . "ssh 177")
        let b:term_title = 'terminal - 177'
    endif

    if has('nvim')
        call nvim_win_set_option(win_getid(), 'winhl', 'Normal:mModeTJob,CursorLine:Folded')
    endif

endfunction

command! -nargs=? CMD  :call OpenTerminal(<f-args>)
"}}}
"{{{ toggle termguicolors
command! GUIColerToggle : set termguicolors!
"}}}
"{{{ toggle scroolling method
function! ToggleRelativeScroll() abort
    if &scrolloff == 0
        execute "set so=" . &lines / 2
        call HighlightEcho("info",  "relative scroll on")
    else
        set scrolloff=0
        call HighlightEcho("info",  "relative scroll off")
    endif
endfunction
command! RS : call ToggleRelativeScroll()
"}}}
"{{{ git push vimconfigfiles
function! GitPushVimrc(commit_msg) abort
    let l:vimrcdir =  substitute(expand("$MYVIMRC"), '\v[/\\](init\.vim)|(.vimrc)', "", "")
    echo l:vimrcdir
    execute "cd " . l:vimrcdir
    execute "!git add ."
    execute '!git commit -m ' . a:commit_msg
    execute "!git push origin main"
endfunction

command! -nargs=1 GPV :call GitPushVimrc(<f-args>)
"}}}
"=================================================================================================================================================================}}}
"{{{ highlighting
"{{{ highlight config function
function! SetHi(group, ctermfg, ctermbg, guifg, guibg, attr) abort
    "cterm"
    if a:ctermfg != ""
        exec "hi! " . a:group . " ctermfg=" . a:ctermfg
    endif
    if a:ctermbg != ""
        exec "hi! " . a:group . " ctermbg=" . a:ctermbg
    endif
 
    "gui"
    if a:guifg != ""
        exec "hi! " . a:group . " guifg=#" . a:guifg
    endif
    if a:guibg != ""
        exec "hi! " . a:group . " guibg=#" . a:guibg
    endif

    "attribute"
    if a:attr != ""
        exec "hi! " . a:group . " gui=" . a:attr . " cterm=" . a:attr
    endif
endfunction
"}}}
"{{{ color palet
let s:ugui_mono0 = "000000"
let s:ugui_mono1 = "18181c"
let s:ugui_mono2 = "1e1e26"
let s:ugui_mono3 = "282830"
let s:ugui_mono4 = "3d3d40"
let s:ugui_mono5 = "404040"
let s:ugui_mono6 = "606060"
let s:ugui_mono7 = "808080"
let s:ugui_mono8 = "d0d0d1"
let s:ugui_mono9 = "e0e0e0"
let s:ugui_monoA = "ffffff"

let s:ugui_erro0 = "602828"
let s:ugui_erro1 = "d04848"
let s:ugui_warn0 = "606028"
let s:ugui_safe0 = "286028"

let s:ugui_emph0 = "45a080" "search
let s:ugui_emph1 = "397874" "incsearch, cursorsearch, 
let s:ugui_emph2 = "296864" "match paren
let s:ugui_emph3 = "253c3c" "visual
let s:ugui_emph4 = "95f0d0" "sign

let s:ugui_mnorm = "304070"
let s:ugui_mcomm = "583058"
let s:ugui_minse = "803030"
let s:ugui_mvisu = "307040"
let s:ugui_mterm = "304070"
let s:ugui_mtjob = "080810"

let s:ugui_separator = "282830"

let s:ucterm_mono0 = "0"
let s:ucterm_mono1 = "231"
let s:ucterm_mono2 = "255"
let s:ucterm_mono3 = "242"
let s:ucterm_mono4 = "237"
let s:ucterm_mono5 = "242"
let s:ucterm_mono6 = "242"
let s:ucterm_mono7 = "248"
let s:ucterm_mono8 = "254"
let s:ucterm_mono9 = "252"
let s:ucterm_monoA = "237"

let s:ucterm_emph0 = "7474eb"
let s:ucterm_emph1 = "2a2058"
let s:ucterm_emph2 = "3a20c8"
let s:ucterm_emph3 = "384360"
"}}}
"{{{ highlight configuration
"--- init highlight ---"
set termguicolors
hi clear
"syntax reset
syntax enable

"--- highlight ---"
call SetHi("Comment",        "103", "",    s:ugui_mono6, "",           "none")
call SetHi("Constant",       "73",  "",    "f3c29b",     "",           "none")
"{{{highlight! String term=none cterm=none ctermbg=none ctermfg=166
"highlight! Character term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Number term=none cterm=none ctermbg=none ctermfg=73 guibg=none guifg=#9bf39f
"highlight! Boolean term=none cterm=none ctermbg=none ctermfg=37
"highlight! Float term=none cterm=none ctermbg=none ctermfg=73}}}

call SetHi("Identifier",     "26",  "",    "95d0f0",     "",           "none")
call SetHi("Function",       "26",  "",    "f3f09b",     "",           "none")

call SetHi("Statement",      "125", "",    "9ba2f3",     "",           "none")
call SetHi("Conditional",    "125", "",    "f39bbc",     "",           "none")
call SetHi("Repeat",         "125", "",    "f39bbc",     "",           "none")
call SetHi("Label",          "125", "",    "f39bbc",     "",           "none")
call SetHi("Exception",      "125", "",    "f39bbc",     "",           "none")
"{{{highlight! Operator term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Keyword  term=bold cterm=bold ctermbg=none ctermfg=125 guibg=none guifg=#ff337c}}}

call SetHi("PreProc",        "",    "",    "e69bf3",     "",           "none")
"{{{highlight! Include term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Define term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Macro term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! PreCondit term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff}}}

call SetHi("Type",           "63",  "",    "95f0d0",     "",           "none")
"{{{highlight! StorageClass term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Structure term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Typedef term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff}}}

call SetHi("Special",        "142", "",    "fff9b3",     "",           "none")
"{{{highlight! SpecialChar term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Tag term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Delimiter term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! SpecialComment term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Debug term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff}}}

call SetHi("Underlined",     "27",  "",    s:ugui_mono9, "",           "none")

call SetHi("Ignore",         "",    "",    s:ugui_mono9, s:ugui_mono0, "none")

call SetHi("Error",          "237",  "217", s:ugui_mono9, s:ugui_erro1, "none")

call SetHi("Todo",           "0",   "11",  s:ugui_mono9, s:ugui_warn0, "none")

"--- highlight-group ------"
call SetHi("Normal",         "237", "231", s:ugui_mono9, s:ugui_mono1, "none")
call SetHi("NormalFloat",    "237", "254", s:ugui_mono9, s:ugui_mono4, "none")
call SetHi("NormalNC",       "237", "231", s:ugui_mono9, s:ugui_mono1, "none")

call SetHi("NonText",        "189", "",    s:ugui_mono3, "",           "none")

call SetHi("Whitespace",     "189", "",    s:ugui_mono3, "",           "none")

call SetHi("EndOfBuffer",    "189", "",    s:ugui_mono3, "",           "none")

call SetHi("Conceal",        "230", "0",   s:ugui_mono9, s:ugui_mono0, "none")

call SetHi("Cursor",         "",    "",    "", "", "reverse")
"{{{highlight! lCursor        term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#000000
"highlight! CursorIM       term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#000000
"highlight! TermCursor     term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#000000
"highlight! TermCursorNC   term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#00000}}}

call SetHi("ColorColumn",    "", "255", "", s:ugui_mono2, "none")

call SetHi("Directory",      "63",  "",    "9ba2f3",     "",           "none")

call SetHi("DiffAdd",        "237", "157", "", s:ugui_safe0, "none")
call SetHi("DiffDelete",     "217", "217", s:ugui_erro0, s:ugui_erro0, "none")
call SetHi("DiffChange",     "237", "186", "", s:ugui_warn0, "none")
call SetHi("DiffText",       "237", "229", "", s:ugui_mono6, "none")

call SetHi("ErrorMsg",       "237",  "217", s:ugui_mono9, s:ugui_erro0,     "none")
call SetHi("WarningMsg",     "237", "227", s:ugui_mono9, s:ugui_warn0,     "none")

call SetHi("WinSeparator",   "0",   "0",   s:ugui_separator, s:ugui_separator, "none")
call SetHi("FloatBorder",    "237", "231", s:ugui_mono7, s:ugui_mono1, "none")
call SetHi("VertSplit",      "252", "242", s:ugui_separator, s:ugui_separator, "none")

call SetHi("Folded",         "237", "188", s:ugui_mono7, "102038",     "none")

call SetHi("Search",         "",    "224", s:ugui_mono9, s:ugui_emph1, "none")
call SetHi("CurSearch",      "",    "217", s:ugui_mono9, s:ugui_emph0, "none")
call SetHi("IncSearch",      "",    "217", s:ugui_mono9, s:ugui_emph0, "none")

call SetHi("Substitute",     "",    "224", "",           s:ugui_emph1, "none")

call SetHi("CursorLine",     "",    "255", "",           s:ugui_mono2, "none")
call SetHi("CursorColumn",   "247", "255", s:ugui_mono8, s:ugui_mono2, "none")
call SetHi("CursorLineNr",   "231", "237", s:ugui_mono8, s:ugui_mono2, "none")
call SetHi("CursorLineFold", "247", "237", s:ugui_mono8, s:ugui_mono2, "none")
call SetHi("CursorLineSign", "",    "237", "",           s:ugui_mono2, "none")

call SetHi("LineNr",         "252", "242", s:ugui_mono6, s:ugui_mono2, "none")
call SetHi("LineNrAbove",    "252", "242", s:ugui_mono6, s:ugui_mono2, "none")
call SetHi("LineNrBelow",    "252", "242", s:ugui_mono6, s:ugui_mono2, "none")

call SetHi("FoldColumn",     "252", "242", s:ugui_mono6, s:ugui_mono2, "none")

call SetHi("SignColumn",     "",    "237", "",           s:ugui_mono2, "none")
call SetHi("Sign",           "104", "237", s:ugui_emph4, s:ugui_mono2, "none")

call SetHi("MatchParen",     "237", "229", s:ugui_mono9, s:ugui_emph1, "none")

call SetHi("ModeMsg",        "231", "139", s:ugui_mono9, s:ugui_emph1, "none")
call SetHi("MsgArea",        "237", "231", s:ugui_mono9, s:ugui_mono1, "none")
call SetHi("MsgSeparator",   "231", "237", s:ugui_mono9, s:ugui_mono4, "none")

call SetHi("MoreMsg",        "73",  "",    "c29bf3",     "",           "none")
call SetHi("Question",       "73",  "",    "c29bf3",     "",           "none")

call SetHi("Pmenu",      "248", "242", s:ugui_mono9, s:ugui_mono4, "none")
call SetHi("PmenuSel",   "231", "237", s:ugui_mono9, s:ugui_emph0, "none")
call SetHi("PmenuSbar",  "231", "0",   s:ugui_mono9, s:ugui_mono3, "none")
call SetHi("PmenuThumb", "231", "242", s:ugui_mono9, s:ugui_emph0, "none")

call SetHi("QuickFixLine", "231", "237", s:ugui_mono9, s:ugui_mono4, "none")

call SetHi("SpecialKey", "81",  "", s:ugui_mono6, "", "none")

call SetHi("SpellBad",   "15",  "217", s:ugui_mono9, s:ugui_erro1, "none")
call SetHi("SpellCap",   "231", "0",   s:ugui_mono9, s:ugui_mono0, "none")
call SetHi("SpellLocal", "231", "0",   s:ugui_mono9, s:ugui_mono0, "none")
call SetHi("SpellRare",  "231", "0",   s:ugui_mono9, s:ugui_mono0, "none")

call SetHi("StatusLine",   "231", "242", s:ugui_mono9,     s:ugui_separator, "none")
call SetHi("StatusLineNC", "242", "242", s:ugui_separator, s:ugui_separator, "none")

call SetHi("TabLine",     "252", "242", s:ugui_mono9, s:ugui_mono5, "none")
call SetHi("TabLineFill", "231", "242", s:ugui_mono2, s:ugui_separator, "none")
call SetHi("TabLineSel",  "231", "104", s:ugui_mono9, s:ugui_mnorm, "none")

call SetHi("Title",          "213", "",    s:ugui_emph0, "",           "bold")

call SetHi("Visual",         "",    "224", "",           s:ugui_emph3, "none")

call SetHi("WildMenu",       "248", "242", s:ugui_mono7, s:ugui_mono9, "none")

call SetHi("WinBar",         "231", "0",   s:ugui_mono9, s:ugui_mono0, "none")
call SetHi("WinBarNC",       "231", "0",   s:ugui_mono9, s:ugui_mono0, "none")

call SetHi("StatusLineTerm", "231", "0",   s:ugui_mono9, s:ugui_separator, "none")
call SetHi("StatusLineTermNC", "231", "0", s:ugui_mono9, s:ugui_separator, "none")

"}}}
"{{{ user defined highlight
"each mode"
call SetHi("mModeNormal",    "231", "104", s:ugui_mono8, s:ugui_mnorm, "none")
call SetHi("mModeInsert",    "231", "203", s:ugui_mono8, s:ugui_minse, "none")
call SetHi("mModeCommand",   "231", "178", s:ugui_mono8, s:ugui_mcomm, "none")
call SetHi("mModeVisual",    "231", "36",  s:ugui_mono8, s:ugui_mvisu, "none")
call SetHi("mModeTerm",      "231", "0",   s:ugui_mono8, s:ugui_mterm, "none")
call SetHi("mModeTJob",      "231", "0",   s:ugui_mono8, s:ugui_mtjob, "none")
"floating window scroll bar"
"call SetHi("mScrollBase",    "231", "255", s:ugui_mono3, s:ugui_mono3, "none")
"call SetHi("mScrollGrip",    "231", "250", s:ugui_mono5, "9494eb", "none")

function! ApplyUserSyntax() abort
    "network addrs"
    syntax match uIPAddr /\v\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
    highlight! default	 link uIPAddr Type

    syntax match uMacAddr /\v[0-9A-Fa-f]{2}([:-][0-9A-Fa-f]{2}){5}/
    highlight! default	 link uMacAddr Identifier

    "header highlight"
    syntax match uHeader1 '^\s*[=■]'
    highlight! def link uHeader1 Type

    syntax match uHeader2 '^\s*=='
    highlight! uHeader2 guifg=#45a080

    syntax match uHeader3 '^\s*==='
    highlight! uHeader3 guifg=#397874

    syntax match uMultiSpace '　'
    highlight! def link uMultiSpace WarningMsg

    "vimrc header"
    if expand("%:p") == $MYVIMRC
        "AA highlight
        syntax match uAA '^\"=.\+=\"'
        "highlight! uAA cterm=none gui=none ctermfg=104 ctermbg=255 guifg=#95f0d0 guibg=#181818
        "highlight! uAA cterm=none gui=none ctermfg=104 ctermbg=255 guifg=#f5f0cd guibg=#181818
        highlight! uAA cterm=none gui=none ctermfg=104 ctermbg=255 guifg=#95d8e8 guibg=#181818
    endif
endfunction

augroup Attachsyntax
    autocmd!
    autocmd BufEnter * call ApplyUserSyntax()
augroup END

"}}}
"{{{ delete function and variables that used in highlighting
delfunction SetHi
unlet s:ugui_mono0 s:ugui_mono1 s:ugui_mono2 s:ugui_mono3 s:ugui_mono4 s:ugui_mono5 s:ugui_mono6 s:ugui_mono7 s:ugui_mono8 s:ugui_mono9 s:ugui_monoA
unlet s:ugui_emph0 s:ugui_emph1 s:ugui_emph2 s:ugui_emph3
"}}}
"=================================================================================================================================================================}}}
"{{{ std plagin
"{{{ netrw
" hide lines matcing regular expression 
let g:netrw_list_hide='\v(^\./)|(^\s\s\./)'
" hide netrw header
let g:netrw_banner=0
" Change window size when display netrw on Lexplore command
let g:netrw_winsize=10
" keep pwd
let g:netrw_keepdir=1
" change browse style to tree
"let g:netrw_liststyle=3
"}}}
"=================================================================================================================================================================}}}
"{{{ utility
"{{{ foldtext
function! MyFoldtext() abort
    return printf("[%4d lines ] %s", v:foldend - v:foldstart + 1, getline(v:foldstart))
endfunction

set foldtext=MyFoldtext()
"}}}
"{{{ statusline
set laststatus=2

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
        let s:sign_id = 0
        return
    endif
    let l:max_sign_id = 0
    for sign_dict in l:m_placed_sign_list
        if (sign_dict.id > l:max_sign_id)
            execute "let l:max_sign_id = " . str2nr(sign_dict.id)
        endif
    endfor
    let s:sign_id = l:max_sign_id
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
        let s:sign_id += 1
        let l:current_line = line(".")
        execute "sign place " . s:sign_id . " name=sign1 line=" . l:current_line
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
    let s:u_hitestbufnr = bufnr()
    augroup PreQuitDeleteBuffer
        au!
        au WinClosed <buffer> :execute "bd! " . s:u_hitestbufnr
    augroup END

    "initial rgb"
    let s:u_hitest_r = 0xf3
    let s:u_hitest_g = 0xc2
    let s:u_hitest_b = 0x9b

    "define mappings to adjust colors"
    nnoremap <buffer> <silent> k :<c-u>call ChangeColorHiTest("u", v:count1)<CR>
    nnoremap <buffer> <silent> j :<c-u>call ChangeColorHiTest("d", v:count1)<CR>

    "write"
    noautocmd normal! Gdgg
    let l:colorstr = "R:". s:u_hitest_r . " G:". s:u_hitest_g . " B:". s:u_hitest_b . "#" . printf("%02x", s:u_hitest_r) . printf("%02x", s:u_hitest_g) . printf("%02x", s:u_hitest_b)
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
        let s:u_hitest_r = s:u_hitest_r + l:offset
        let s:u_hitest_r = s:u_hitest_r < 1   ? 0 : s:u_hitest_r
        let s:u_hitest_r = s:u_hitest_r > 255 ? 255 : s:u_hitest_r
    elseif l:cursorChar == "G"
        let s:u_hitest_g = s:u_hitest_g + l:offset
        let s:u_hitest_g = s:u_hitest_g < 1   ? 0 : s:u_hitest_g
        let s:u_hitest_g = s:u_hitest_g > 255 ? 255 : s:u_hitest_g
    elseif l:cursorChar == "B"
        let s:u_hitest_b = s:u_hitest_b + l:offset
        let s:u_hitest_b = s:u_hitest_b < 1   ? 0 : s:u_hitest_b
        let s:u_hitest_b = s:u_hitest_b > 255 ? 255 : s:u_hitest_b
    elseif l:cursorChar == "@"
        let s:u_hitest_r = s:u_hitest_r + l:offset
        let s:u_hitest_r = s:u_hitest_r < 1   ? 0 : s:u_hitest_r
        let s:u_hitest_r = s:u_hitest_r > 255 ? 255 : s:u_hitest_r
        let s:u_hitest_g = s:u_hitest_g + l:offset
        let s:u_hitest_g = s:u_hitest_g < 1   ? 0 : s:u_hitest_g
        let s:u_hitest_g = s:u_hitest_g > 255 ? 255 : s:u_hitest_g
        let s:u_hitest_b = s:u_hitest_b + l:offset
        let s:u_hitest_b = s:u_hitest_b < 1   ? 0 : s:u_hitest_b
        let s:u_hitest_b = s:u_hitest_b > 255 ? 255 : s:u_hitest_b
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
    let l:colorstr = "#" . printf("%02x", s:u_hitest_r) . printf("%02x", s:u_hitest_g) . printf("%02x", s:u_hitest_b) . ", R:". s:u_hitest_r . ", G:". s:u_hitest_g . ", B:". s:u_hitest_b
    call append(2, l:colorstr)
    noautocmd normal! mmgg3jddgg`m

    "call matchadd('HiTestbg',"^HT_bg.\+HT$")
    "call matchadd('HiTestfg',"^HT_fg.\+HT$")
    syntax match HiTestbg /\v^HT_bg.+HT$/
    syntax match HiTestfg /\v^HT_fg.+HT$/
    exec "highlight! HiTestbg gui=none cterm=none guifg=#FFFFFF guibg=#" . printf("%02x", s:u_hitest_r) . printf("%02x", s:u_hitest_g) . printf("%02x", s:u_hitest_b)
    exec "highlight! HiTestfg gui=none cterm=none guibg=#181818 guifg=#" . printf("%02x", s:u_hitest_r) . printf("%02x", s:u_hitest_g) . printf("%02x", s:u_hitest_b)
    setlocal nomodifiable
    setlocal readonly
    setlocal buftype=nofile
    setlocal nobuflisted
endfunction
"}}}

command! -nargs=? HT :call HiTest(<f-args>)

"}}}
"=================================================================================================================================================================}}}
"{{{ helper functions
"{{{ echo highlighting
function! HighlightEcho(type, msg) abort
    if a:type == "error"
        echohl ErrorMsg
        let l:head = "[Error] "

    elseif a:type == "warning"
        echohl WarningMsg
        let l:head = "[Warning] "

    elseif a:type == "info"
        echohl DiffAdd
        let l:head = "[Info] "
    else
        echohl DiffAdd
        let l:head = ""
    endif

    let l:echomsg = l:head . a:msg
    execute 'echo "' . l:echomsg '"'
    echohl end
endfunction
"}}}
"=================================================================================================================================================================}}}

" environment dependent "
"{{{ nvim only
if has('nvim')
"{{{ basic
language en_US.utf8
set laststatus=3
"set fillchars=vert:\ ,vertleft:\ ,vertright:\ ,horiz:\ ,horizdown:\ ,horizup:\ ,verthoriz:\ ,
"}}}
"{{{ floating window scrollbar
function! CreateScrollBar() abort
    if exists("s:sb_win")
        return
    endif
    let l:u_scrollbar_gripper = nvim_create_buf(v:false, v:true)
    let l:opts = {'relative': 'win', 'width': 1,'height': 1, 'anchor': 'NE', 'style': 'minimal', 'col': 0, 'row': 0}
    let s:sb_win = nvim_open_win(l:u_scrollbar_gripper, v:false, l:opts)
endfunction

function! ChangeScrollBarGripper() abort
    let l:buf_height = line("$")
    let l:win_top    = line("w0")
    let l:win_bot    = line("w$")
    let l:win_lines  = l:win_bot - l:win_top + 1
    let l:win_height = winheight(0)
    let l:win_width  = winwidth(0)

    "caliculate grip height 
    let l:bar_grip_height = l:win_height * l:win_lines / l:buf_height
    "chantge negative value to 1
    if l:bar_grip_height <= 0
        let l:bar_grip_height = 1
    endif
    "caliculate grip starting position
    let l:bar_grip_top = l:win_height * l:win_top / l:buf_height

    "change row when grep height eq window height
    if l:bar_grip_height == l:win_height
        let l:bar_grip_top = 0
    endif

    "make top white space on scrollbar when first line was not shown
    if (l:bar_grip_top == 0) && (l:win_top != 1)
        let l:bar_grip_top = 1
    endif
    "delete bottom white spase ob scrollbar when last line was shown
    if l:win_bot == line("$")
        let l:bar_grip_top = winheight(0) - l:bar_grip_height
    endif

    let l:opts = {'relative': 'win', 'width': 1, 'height': l:bar_grip_height, 'col': l:win_width, 'row': l:bar_grip_top, 'anchor': 'NE', 'style': 'minimal'}
    call nvim_win_set_config(s:sb_win, l:opts)
endfunction

augroup changeScrollbar
    autocmd!
    "autocmd VimEnter * ++once call CreateScrollBar()
    "autocmd WinScrolled * noautocmd call ChangeScrollBarGripper()
augroup END

"}}}
"{{{ FloatingBuffCtl (buffer operation window)
"{{{ Main(Floating Window)
function! BuffCtlFloat() abort
    noautocmd normal! mz
    let s:winid = win_getid()

    let l:buflineinfo =  MakeBuffCtlLineInfo()
    let l:buflines =  l:buflineinfo.buflines
    let l:longest_line =  l:buflineinfo.longest_line
    let l:welcomemsg = "* * * Welcome to BuffCtl! Scroll down for help. * * *"

    if !exists("s:bufctl_bufnr")
        "at thae first time
        let s:bufctl_bufnr = nvim_create_buf(v:false, v:true)
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
    if len(win_findbuf(s:bufctl_bufnr)) > 0
        call win_gotoid(s:bufctl_winid)
    else
        "open new window
        let s:bufctl_winid = nvim_open_win(s:bufctl_bufnr, l:enter, l:winconf)
        "set option
        "call nvim_win_set_option(s:bufctl_winid, 'winhl', 'Normal:mModeNormal')
        call matchadd('BufCtlLineTail', '\v[^/]+\.[^\. ]+$')
        highlight def link BufCtlLineTail DiffAdd
        call matchadd('BufCtlCautionMark', '\v\[!\]')
        highlight def link BufCtlCautionMark ErrorMsg
        call matchadd('BufCtlWarningMark', '\v\[[t+]\]')
        highlight def link BufCtlWarningMark WarningMsg 
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
    call appendbufline(s:bufctl_bufnr, 0, l:buflines)

    call appendbufline(s:bufctl_bufnr, line("$"), l:welcomemsg)
    call appendbufline(s:bufctl_bufnr, line("$"), "<Enter> - open buffer*")
    call appendbufline(s:bufctl_bufnr, line("$"), "<S> - open buffer in horizontal split win*")
    call appendbufline(s:bufctl_bufnr, line("$"), "<V> - open buffer in vertical split win*")
    call appendbufline(s:bufctl_bufnr, line("$"), "<d> - delete buffer*")
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
        if(len(l:bufwin) > 0) && (s:winid == l:bufwin[0]) 
            let l:bufstat = "!"
        endif

        let l:buf_win = l:bufinfo.windows
        if(len(l:buf_win) > 0) && (s:winid == l:buf_win[0]) 
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
        let l:bufline = printf('[%s][%s][%3d] %s', l:bufmod, l:bufstat, l:bufnr, l:bufname)

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
    call nvim_win_close(s:bufctl_winid, v:true)
    "move to the window that was open at the beginning
    call win_gotoid(s:winid)
    noautocmd normal! `z
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
    if(len(l:buf_win) > 0) && (s:winid == l:buf_win[0]) 
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
nnoremap <silent> <Leader><Leader> :call BuffCtlFloat()<CR>
"}}}
endif
"=================================================================================================================================================================}}}
"{{{ nvim-qt only
if has('nvim')
"{{{ show warning when command executed other than nvim-qt environment
function! QtWarning() abort
    call HighlightEcho("warning", "this command is invalid other than nvim-qt")
endfunction
"}}}
"{{{ toggle fullscreen
let s:is_fullscreen = 0

function! ChangeOpacity(opacity) abort
    if exists("g:GuiLoaded")
        execute "GuiWindowOpacity " . printf("%f", a:opacity)
    endif
endfunction

function! ToggleFullScreen() abort
    if s:is_fullscreen == 1
        let s:is_fullscreen = 0
        call ChangeOpacity(1)
    else
        let s:is_fullscreen = 1
        call ChangeOpacity(0.95)
    endif
    try
        call GuiWindowMaximized(s:is_fullscreen)
        call GuiWindowFrameless(s:is_fullscreen)
        call GuiWindowFullScreen(s:is_fullscreen)
    catch
        call QtWarning()
    endtry
endfunction

command! FS : call ToggleFullScreen()
"}}}
"{{{ change font size on command
function! ResizeFont(num) abort
    let l:font_str = &guifont
    let l:font_str = matchstr(l:font_str, '\v^.+:h')
    let l:resized_fontstr = escape(l:font_str . a:num, ' \')
    try
        call execute("GuiFont! " . l:resized_fontstr)
    catch
        call QtWarning()
    endtry
endfunction
command! -nargs=1 RF :call ResizeFont(<f-args>)
"}}}
function! PresentationMode() abort
    if exists("g:GuiLoaded")
        FS
        RF 35
        "set cmdheight=0
        "set laststatus=0
        set showtabline=0
        set nonu
        set nolist
    endif
endfunction
command! PRS :call PresentationMode()

endif
"=================================================================================================================================================================}}}
"{{{ vim only
if !has('nvim')
"{{{ basic
let &t_SI .= "\e[5 q"
let &t_EI .= "\e[1 q"
let &t_SR .= "\e[3 q"
set is hls nocuc
"}}}
endif
"=================================================================================================================================================================}}}

" others "
"{{{ debug
"{{{ timer
"function! DebugTimerCallback(timer) abort
    "echo line(".")
"endfunction
"
"function! DebugTimer() abort
    "how many lines to go per 20 seconds
    "call timer_start(20000, function("DebugTimerCallback"))
"endfunction
"}}}
"=================================================================================================================================================================}}}
"{{{ temporary

"exec clonevimrc
command! CPV :call system("cmd.exe /c clonevimrc")

"yank command result
function! KeepCommandOutput(cmd) abort
    let l:winheight = $line / 3
    let l:cmd = substitute(a:cmd, '\v^["'']|["'']$', "", "g")

    let l:zreg = @z
    redir! @z
    execute l:cmd
    redir end

    botright 10 split
    enew
    noautocmd normal! "zpdd
    set nobuflisted
    set buftype=nofile
    let @z = l:zreg
endfunc

command! -nargs=1 KCO :call KeepCommandOutput(<f-args>)

"yank multi block
vnoremap <silent> <leader>y "zy :let @0 .= @z<CR>
nnoremap <silent> <leader>p "0p
nnoremap <silent> <leader>P "0P

function! s:open_mini_currentbuf() abort
    let l:buf = bufnr('%')
    let l:enter = v:true
    let l:winconf = {
        \ 'style': 'minimal',
        \ 'relative': 'editor',
        \ 'width': &columns/2,
        \ 'height': &lines/2,
        \ 'row': &lines /2,
        \ 'col': &columns /2,
        \ 'focusable': v:true
        \ }

    if exists("s:mc_winid") && (len(win_findbuf(l:buf)) == 2)
        call win_gotoid(s:mc_winid)
    else
        let s:mc_winid = nvim_open_win(l:buf, l:enter, l:winconf)
    endif
endfunction

command! MW call s:open_mini_currentbuf()

"}}}

" memo "
"{{{ MEMO
":h api-floatwin
"call setcellwidths([ [0x25a0, 0x25a0, 2] ])
"stopinsert
"wincmd
"}}}

