--
-- ╭─── rogawa init.lua   ╭─╮              ───╮
-- │ ╭─╮    ╭─╮    ╭─────╮│ │          ╭────╮ │
-- │ │ │ ╭──│ │ ╭─╮╰─╮ ╭─╯│ │   ╭─╮ ╭─╮│ ╭╮ │ │
-- │ │ │ │  │ │ │ │  │ │  │ │   │ │ │ ││ ╰╯ │ │
-- │ │ │ │ ╮  │ │ │  │ │  │ ╰──╮│ │ │ ││ ╭╮ │ │
-- │ ╰─╯ │ │──╯ │ │  ╰─╯☺ ╰────╯│ ╰─╯ │╰─╯╰─╯ │
-- ╰───  ╰─╯    ╰─╯             ╰─────╯    ───╯

-- SETUP ================================================================================================================={{{
-- * install nvim
--   $ wget https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
--   There are many ways to install nvim, so choose the one that suits a environment.
-- * install required applications
--   curl (util/translator)
--   npm  (plugins/lsp/mason)
--   nardfont (lazy etc.)
-- * complete the git config
--   $ git config ~~
--   $ ssh genkey (register public key with github)
-- * clone nvim settings
--   $ mkdir -p ~/.config/nvim/
--   $ git clone https://github.com/rogawa14106/vimconfig ~/.config/nvim/.
-- * launch nvim
--   $ nvim
--========================================================================================================================}}}
--
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
--========================================================================================================================}}}
--
-- CORE =================================================================================================================={{{
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
--========================================================================================================================}}}
--
-- COLORSCHEME ==========================================================================================================={{{
require("colorscheme.dark")
--========================================================================================================================}}}
--
-- UTILITYS =============================================================================================================={{{
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
--========================================================================================================================}}}
--
-- PLUGINS ==============================================================================================================={{{
-- built in
require("./core/netrw")
-- plugin package manager
require("./lazy")
--========================================================================================================================}}}
--

-- help memo
-- :digraphs
