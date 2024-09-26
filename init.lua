
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
-- {{{ set up
-- * clone wbthomason/packer.nvim
--   linux$ git clone https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
--   windows> git clone https://github.com/wbthomason/packer.nvim AppData/Local/nvim-data/site/pack/packer/start/packer.nvim/
-- * comment out plugin requires on below file(treesitter ...etc)
--   ~/.config/nvim/plugins/init.lua
-- * launch nvim
--   $ nvim
-- * execute PackerInstall
--   :PackerInstall
-- * uncomment plugin requires on below file(treesitter ...etc)
--   ~/.config/nvim/plugins/init.lua
-- * relaunch nvim
--   :q
--   $ nvim
-- }}}

--========================================================================================================================}}}

-- requires ==============================================================================================================

-- basic options
require("core.options")

-- user defined commands
require("core.commands")

-- keymapping
require("core.keymaps")

-- auto cmds
require("core.autocmds")

-- fold, status, tab lines
require("core.ui_lines")

-- {{{ colorscheme
require("colorscheme.dark")
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
-- lazy
require("core.lazy")
-- }}}
--========================================================================================================================
