---                                                                          ---
--       /##/ /####|  /##/ /##/ /##########/  /##/       /##/   /##/ /#####|  --
--      /##/ /##/##| /##/ /##/     /##/      /##/       /##/   /##/ /##/|##|  --
--     /##/ /##/|##|/##/ /##/     /##/      /##/       /##/   /##/ /##/ |##|  --
--    /##/ /##/ |##|##/ /##/     /##/      /##/       /##/   /##/ /########|  --
--   /##/ /##/  |####/ /##/     /##/      /##/_____  /##/___/##/ /##/   |##|  --
--  /##/ /##/   |###/ /##/     /##/      /########/ /#########/ /##/    |##|  --
---                                                                          ---

-- NOTE =================================================================================================================={{{

-- {{{ must be done in unix env
-- run the following command.
-- :set ff=unix | w
-- }}}
-- {{{ about commands
-- To use the commands below, you need to be in your path.
-- chime, hidesb
-- To get executable file of the above command, run the following command.
-- > git clone https://github.com/rogawa14106/vimconfig
-- }}}
-- {{{ defined Ex commands"
--  INIVIM
--  VIMRC
--  SP
--  GUIColerToggle
--  FS
--  RS
--  HSB
--  HTB
--  CPV
--  GPV <commit msg: str>
--  CMD <type: str>
-- }}}
-- {{{ Difference from buildin
-- install wbthomason/packer.nvim
-- > git clone https://github.com/wbthomason/packer.nvim AppData/Local/nvim-data/site/pack/packer/start/packer.nvim/
-- }}}

--========================================================================================================================}}}

-- requires =============================================================================================================={{{

-- helper functions
require("helper")

-- basic options
require("options")

-- user defined commands
require("commands")

-- keymapping
require("keymaps")

--autocmds
require("autocmds")

-- fold, status, tab lines
require("ui_lines")

-- mark utility
require("mark")

-- colorscheme
require("colors.dark")

-- BufCtl
require("myplugin.bufctl")

-- floatScrool
require("myplugin.floatscroll")

-- fuzzy finder
require("myplugin.fim")

-- file explorer
require("myplugin.eim")

-- clock
require("myplugin.clock")

-- bulidin plugins
require("plugins.netrw")

-- plugins (packer.nvim managed)
if vim.fn.isdirectory("~/AppData/Local/nvim-data/pack/packer/opt/packer.nvim") then
    --$ git clone https://github.com/wbthomason/packer.nvim ~/AppData/Local/nvim-data/pack/packer/opt/packer.nvim
    require("plugins")
end
--require("lsp")
--========================================================================================================================}}}

