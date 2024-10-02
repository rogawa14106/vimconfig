let s:cpo_save=&cpo
set cpo&vim
inoremap <C-W> u
inoremap <C-U> u
nnoremap  <Cmd>nohlsearch|diffupdate|normal! 
nmap  d
tnoremap  
nnoremap <silent>  sd :call DeleteAllSign()
nnoremap <silent>  sk :call SignJump(-1)
nnoremap <silent>  sj :call SignJump(1)
nnoremap <silent>  st :call ToggleSign()
nnoremap  N <Cmd>cNext
nnoremap  n <Cmd>cnext
omap <silent> % <Plug>(MatchitOperationForward)
xmap <silent> % <Plug>(MatchitVisualForward)
nmap <silent> % <Plug>(MatchitNormalForward)
nnoremap & :&&
xnoremap <silent> <expr> @ mode() ==# 'V' ? ':normal! @'.getcharstr().'' : '@'
nnoremap K k
xnoremap <silent> <expr> Q mode() ==# 'V' ? ':normal! @=reg_recorded()' : 'Q'
nnoremap Y y$
omap <silent> [% <Plug>(MatchitOperationMultiBackward)
xmap <silent> [% <Plug>(MatchitVisualMultiBackward)
nmap <silent> [% <Plug>(MatchitNormalMultiBackward)
omap <silent> ]% <Plug>(MatchitOperationMultiForward)
xmap <silent> ]% <Plug>(MatchitVisualMultiForward)
nmap <silent> ]% <Plug>(MatchitNormalMultiForward)
xmap a% <Plug>(MatchitVisualTextObject)
omap <silent> g% <Plug>(MatchitOperationBackward)
xmap <silent> g% <Plug>(MatchitVisualBackward)
nmap <silent> g% <Plug>(MatchitNormalBackward)
xmap <silent> <Plug>(MatchitVisualTextObject) <Plug>(MatchitVisualMultiBackward)o<Plug>(MatchitVisualMultiForward)
onoremap <silent> <Plug>(MatchitOperationMultiForward) :call matchit#MultiMatch("W",  "o")
onoremap <silent> <Plug>(MatchitOperationMultiBackward) :call matchit#MultiMatch("bW", "o")
xnoremap <silent> <Plug>(MatchitVisualMultiForward) :call matchit#MultiMatch("W",  "n")m'gv``
xnoremap <silent> <Plug>(MatchitVisualMultiBackward) :call matchit#MultiMatch("bW", "n")m'gv``
nnoremap <silent> <Plug>(MatchitNormalMultiForward) :call matchit#MultiMatch("W",  "n")
nnoremap <silent> <Plug>(MatchitNormalMultiBackward) :call matchit#MultiMatch("bW", "n")
onoremap <silent> <Plug>(MatchitOperationBackward) :call matchit#Match_wrapper('',0,'o')
onoremap <silent> <Plug>(MatchitOperationForward) :call matchit#Match_wrapper('',1,'o')
xnoremap <silent> <Plug>(MatchitVisualBackward) :call matchit#Match_wrapper('',0,'v')m'gv``
xnoremap <silent> <Plug>(MatchitVisualForward) :call matchit#Match_wrapper('',1,'v'):if col("''") != col("$") | exe ":normal! m'" | endifgv``
nnoremap <silent> <Plug>(MatchitNormalBackward) :call matchit#Match_wrapper('',0,'n')
nnoremap <silent> <Plug>(MatchitNormalForward) :call matchit#Match_wrapper('',1,'n')
nnoremap <Plug>PlenaryTestFile :lua require('plenary.test_harness').test_file(vim.fn.expand("%:p"))
tnoremap <C-[> 
vnoremap <M-j> :m '>+1gv
vnoremap <M-k> :m '<-2gv
nmap <C-W><C-D> d
nnoremap <C-L> <Cmd>nohlsearch|diffupdate|normal! 
inoremap  u
inoremap  u
cnoremap "" ""<Left>
inoremap "" ""<Left>
cnoremap %% %%<Left>
inoremap %% %%<Left>
cnoremap '' ''<Left>
inoremap '' ''<Left>
cnoremap () ()<Left>
inoremap () ()<Left>
cnoremap <> <><Left>
inoremap <> <><Left>
cnoremap [] []<Left>
inoremap [] []<Left>
cnoremap {} {}<Left>
inoremap {} {}<Left>
let &cpo=s:cpo_save
unlet s:cpo_save
set clipboard=unnamedplus
set expandtab
set fileencodings=utf-8,sjis
set fileformats=unix,mac,dos
set fillchars=fold:\ 
set helplang=en
set ignorecase
set laststatus=3
set listchars=eol:$,nbsp:+,space:_,tab:^-,trail:-
set noloadplugins
set matchpairs=(:),{:},[:],<:>
set mouse=
set packpath=/usr/local/bin/squashfs-root/usr/share/nvim/runtime
set path=.,,**
set runtimepath=~/.config/nvim,~/.local/share/nvim/lazy/lazy.nvim,~/.local/share/nvim/lazy/lspkind.nvim,~/.local/share/nvim/lazy/friendly-snippets,~/.local/share/nvim/lazy/cmp_luasnip,~/.local/share/nvim/lazy/LuaSnip,~/.local/share/nvim/lazy/cmp-path,~/.local/share/nvim/lazy/cmp-buffer,~/.local/share/nvim/lazy/nvim-cmp,~/.local/share/nvim/lazy/nvim-treesitter,~/.local/share/nvim/lazy/neodev.nvim,~/.local/share/nvim/lazy/nvim-lsp-file-operations,~/.local/share/nvim/lazy/cmp-nvim-lsp,~/.local/share/nvim/lazy/plenary.nvim,~/.local/share/nvim/lazy/nvim-lspconfig,~/.local/share/nvim/lazy/mason-lspconfig.nvim,~/.local/share/nvim/lazy/mason.nvim,/usr/local/bin/squashfs-root/usr/share/nvim/runtime,/usr/local/bin/squashfs-root/usr/share/nvim/runtime/pack/dist/opt/matchit,/usr/local/bin/squashfs-root/usr/lib/nvim,~/.local/state/nvim/lazy/readme,~/.local/share/nvim/lazy/cmp_luasnip/after,~/.local/share/nvim/lazy/cmp-path/after,~/.local/share/nvim/lazy/cmp-buffer/after,~/.local/share/nvim/lazy/cmp-nvim-lsp/after
set shiftwidth=4
set noshowmode
set showtabline=2
set smartcase
set smartindent
set statusline=%!v:lua.MyStatusLine()
set noswapfile
set tabline=%!v:lua.MyTabLine()
set tabstop=4
set termguicolors
set window=46
" vim: set ft=vim :
