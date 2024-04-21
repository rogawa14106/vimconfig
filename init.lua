---                                                                          ---
--       /##/ /####|  /##/ /##/ /##########/  /##/       /##/   /##/ /#####|  --
--      /##/ /##/##| /##/ /##/     /##/      /##/       /##/   /##/ /##/|##|  --
--     /##/ /##/|##|/##/ /##/     /##/      /##/       /##/   /##/ /##/ |##|  --
--    /##/ /##/ |##|##/ /##/     /##/      /##/       /##/   /##/ /########|  --
--   /##/ /##/  |####/ /##/     /##/      /##/_____  /##/___/##/ /##/   |##|  --
--  /##/ /##/   |###/ /##/     /##/      /########/ /#########/ /##/    |##|  --
---                                                                          ---

-- NOTE =================================================================================================================={{{

-- {{{ About line break codes
-- run the following command.
-- :set ff=unix | w
-- :set ff=dos | w
-- }}}
-- {{{ about commands
-- To use the following command to change the IME, you need to be in your path.(windows only)
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

-- requires ==============================================================================================================

-- basic options
require("options")

-- user defined commands
require("commands")

-- keymapping
require("keymaps")

-- auto cmds
require("autocmds")

-- fold, status, tab lines
require("ui_lines")

-- {{{ colorscheme
require("colors.dark")
-- }}}
--
-- {{{ utilitys
-- BufCtl
require("util.bufctl")

-- floatScrool
require("util.floatscroll")

-- fuzzy finder
require("util.fim")

-- file explorer
require("util.eim")

-- clock
require("util.clock")

-- translator
require("util.translator")

-- mark utility
require("util.visualmark")

-- }}}
--
-- {{{ plugins
-- bulidin plugins
require("plugins.netrw")

-- plugins
-- ## run following command to use plugins
-- $ git clone https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
-- :PackerInstall
-- :PackerSync
require("plugins")
-- }}}
--========================================================================================================================
