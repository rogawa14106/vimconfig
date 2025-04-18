-- ╭─── rogawa init.lua   ╭─╮              ───╮
-- │ ╭─╮    ╭─╮    ╭─────╮│ │          ╭────╮ │
-- │ │ │ ╭──│ │ ╭─╮╰─╮ ╭─╯│ │   ╭─╮ ╭─╮│ ╭╮ │ │
-- │ │ │ │  │ │ │ │  │ │  │ │   │ │ │ ││ ╰╯ │ │
-- │ │ │ │ ╮  │ │ │  │ │  │ ╰──╮│ │ │ ││ ╭╮ │ │
-- │ ╰─╯ │ │──╯ │ │  ╰─╯☺ ╰────╯│ ╰─╯ ││ │╰─╯ │
-- ╰───  ╰─╯    ╰─╯             ╰─────╯╰─╯ ───╯
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

-- status line
require("core.status_line")

-- tab line
require("core.tab_line")

-- fold, status, tab lines
require("core.ui_lines")
--========================================================================================================================}}}
--
-- UTILITYS =============================================================================================================={{{
-- BufCtl
require("util.bufctl")

-- fuzzy finder
require("util.fim")

-- preview markdown
require("util.preview_md")

-- floatScrool
-- require("util.floatscroll")

-- file explorer
-- require("util.eim")

-- clock
-- require("util.clock")

-- translator
-- require("util.translator")

-- mark utility
-- require("util.visualmark")

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
