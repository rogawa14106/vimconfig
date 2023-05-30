vim.cmd[[
"{{{ netrw
" hide lines matcing regular expression 
let g:netrw_list_hide='\v(^\./)|(^\s\s\./)'
" hide netrw header
let g:netrw_banner=0
" Change window size when display netrw on Lexplore command
let g:netrw_winsize=&columns/10
" keep pwd
let g:netrw_keepdir=1
" change browse style to tree
"let g:netrw_liststyle=3
"}}}
]]

