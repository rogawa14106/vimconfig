-- leader
vim.g.mapleader = " "

vim.cmd [[
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
"{{{ normal mode
"{{{ open netrw window
"function! WinExLeft() abort
"    "open directory as root that current file exist
"    "if failed to execute, then open Documents as root dir
"    try
"        if expand('%h') == ""
"            execute "cd ~/Documents"
"            execute "Lexplore ~/Documents/"
"        else
"            cd %:p:h
"            Lexplore %:p:h
"        endif
"    catch
"        execute "cd ~/Documents"
"        execute "Lexplore ~/Documents/"
"        call HighlightEcho("info",  "open ~/Documents as root")
"    endtry
"endfunction
"
"nnoremap <Leader>e :call WinExLeft()<CR>
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
    if exists("g:bufctl_bufnr") && (bufnr() == g:bufctl_bufnr)
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

let g:comment_char_dict = {
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
    elseif has_key(g:comment_char_dict, l:extension)
        execute "noautocmd normal! ^i" . g:comment_char_dict[l:extension]
    endif
endfunction

vnoremap <silent> <Leader>/ :call CommentSelectedLine()<CR>
"}}}
"}}}
"=================================================================================================================================================================}}}
]]

-- normal
--vim.keymap.set("n", "<C-c>", ":nohl<CR>")
vim.keymap.set("n", "<leader>k", "f<C-k>", { noremap = true })
vim.keymap.set("n", "<leader>k", "F<C-k>", { noremap = true })

--vim.keymap.set("n", "<C-d>", "<C-d>zz")
--vim.keymap.set("n", "<C-u>", "<C-u>zz")

--local comment_char_dict = {
--vim = '"',
--c   = '//',
--cs  = '//',
--py  = '#',
--ttl = ';',
--lua = '--',
--}
--vim.keymap.set("v", "<leader>/", (function()
--local extension = vim.fn.expand("%:e")
--if (vim.fn.expand("%:t") == '.vimrc') then
--vim.cmd(":noautocmd normal! I" .. comment_char_dict['vim'])
--elseif comment_char_dict[extension] ~= nil then
--vim.cmd("execute ':noautocmd normal! ^I" .. comment_char_dict[extension] .. "'")
--end
--end))

-- visual
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv", { noremap = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv", { noremap = true })

-- insert
vim.keymap.set("i", "<C-c>", "<Esc>", { noremap = true })
--vim.keymap.set("i", "<C-[>", "<Esc>")

-- insert & command
vim.keymap.set({ "i", "c" }, '""', '""<Left>', { noremap = true })
vim.keymap.set({ "i", "c" }, "''", "''<Left>", { noremap = true })
vim.keymap.set({ "i", "c" }, "()", "()<Left>", { noremap = true })
vim.keymap.set({ "i", "c" }, "[]", "[]<Left>", { noremap = true })
vim.keymap.set({ "i", "c" }, "{}", "{}<Left>", { noremap = true })
vim.keymap.set({ "i", "c" }, "<>", "<><Left>", { noremap = true })
vim.keymap.set({ "i", "c" }, "%%", "%%<Left>", { noremap = true })

-- terminal
vim.keymap.set("t", "<C-\\>", "<C-\\><C-N>", { noremap = true })

-- web browse
-- https://test.com
vim.keymap.set("n", "<C-b>", "", {
    noremap = true,
    callback = function()
        local line = vim.fn.getline(".")
        local url = string.match(line, "https://.+")
        print(url)

        vim.cmd('!chcp 65001 | "C:/Program Files/Google/Chrome/Application/chrome.exe" --incognito '.. '"' .. url .. '"')
        local key = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
        vim.api.nvim_feedkeys(key, 'n', false)
    end,
})
