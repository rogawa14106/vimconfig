local set = vim.opt

-- common
set.number = true
set.relativenumber = true
set.cursorline = true
set.cursorcolumn = false
set.incsearch = true
set.hlsearch = true
set.ignorecase = true
set.smartcase = true
set.showmode = false
set.wrap = false
--set.compatible = false
set.hidden = true
set.laststatus = 3

-- tab, indent
set.tabstop = 4
set.shiftwidth = 4
set.expandtab = true

set.autoindent = true
set.smartindent = true

-- fold
set.foldcolumn = '0'
--set.foldmethod = 'manual'
set.foldmethod = 'marker'

-- no backup files
set.swapfile = false
set.backup = false
set.undofile = false

-- file enc, format
set.encoding = 'utf-8'
set.fileencodings = {'utf-8', 'sjis'}
set.fileformats = {'unix', 'mac', 'dos'}
-- set.ambiwidth = 'double'
set.ambiwidth = 'single'

-- clipboard
set.clipboard:append({'unnamed', 'unnamedplus'})

-- chars
set.list = true
set.fillchars:append({fold=' '})
set.listchars:append({tab='^-', space='_', eol='$'})
set.matchpairs:append({'<:>'})

-- path
set.path:append('**')

-- gui
set.mouse = ''
-- if string.match(vim.env.USERNAME, 'rogawa') then
    -- set.guifont = 'MyricaM M:h12'
-- elseif string.match(vim.env.USERNAME, '152440') then
    -- set.guifont = 'Myrica M:h12'
-- else
    -- set.guifont = 'ＭＳ ゴシック:h12'
-- end

vim.cmd[[
    language en_US.utf8
]]

