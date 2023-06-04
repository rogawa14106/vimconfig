-- hide lines matcing regular expression (^|%s%s)
vim.cmd[[
let g:netrw_list_hide='\(^\|\s\s\)\zs\./'
]]
-- hide netrw header
vim.g.netrw_banner=0
-- Change window size when display netrw on Lexplore command
vim.g.netrw_winsize=math.ceil(vim.opt.columns:get() / 10)
-- keep pwd
vim.g.netrw_keepdir=1
-- change browse style to tree
--vim.g.netrw_liststyle=3
