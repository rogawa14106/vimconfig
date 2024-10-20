--   ========================= --
--  //  HIGHLIGHT          //  --
-- =========================   --
--
-- {{{ configuration
local config = {
    bg_transparent = true, -- enable background transparent
}
-- }}}
--
-- {{{ color palet
local unspec = {}
local hl_mono1 = { cterm = "234", gui = "18181c" }
local hl_mono2 = { cterm = "235", gui = "1e1e26" }
local hl_mono3 = { cterm = "236", gui = "303038" }
local hl_mono5 = { cterm = "236", gui = "3d3d50" }
local hl_mono6 = { cterm = "243", gui = "5c5c68" }
local hl_mono7 = { cterm = "250", gui = "787888" }
local hl_mono8 = { cterm = "253", gui = "c0c0d8" }
local hl_mono9 = { cterm = "253", gui = "d8d8e8" }

local hl_blue0 = { cterm = "24", gui = "102038" }
local hl_blue1 = { cterm = "111", gui = "9ba2f3" }
local hl_blue2 = { cterm = "117", gui = "95d0f0" }
local hl_blue3 = { cterm = "75", gui = "439bbc" }

local hl_erro0 = { cterm = "124", gui = "481010" }
local hl_erro1 = { cterm = "9", gui = "c03838" }
local hl_warn0 = { cterm = "3", gui = "505018" }
local hl_safe0 = { cterm = "22", gui = "104810" }

--local hl_emph0 = { cterm="62", gui="74607c" } -- CursorSearch
local hl_emph0 = { cterm = "85", gui = "95f0d0" }  -- Sign, MatchParen, etc
local hl_search = { cterm = "60", gui = "5f5030" } -- Search

local hl_mnorm = { cterm = "24", gui = "304070" }
local hl_mcomm = { cterm = "58", gui = "583058" }
--local hl_mvisu = { cterm="23", gui="307040" }
local hl_minse = { cterm = "95", gui = "803030" }
local hl_mvisu = { cterm = "23", gui = "15504e" }
local hl_mterm = { cterm = "0", gui = "080810" }
local hl_mtjob = { cterm = "0", gui = "080810" }

local hl_sep01 = { cterm = "237", gui = "282830" }

local hl_str01 = { cterm = "223", gui = "f3c29b" }
local hl_num01 = { cterm = "114", gui = "abddb6" }
local hl_idf02 = { cterm = "229", gui = "f0f0ae" }
local hl_stm02 = { cterm = "218", gui = "f39bbc" }
local hl_prp01 = { cterm = "168", gui = "e69bf3" }
local hl_typ01 = { cterm = "43", gui = "77c89e" }
local hl_spe01 = { cterm = "229", gui = "fff9b3" }
local hl_more0 = { cterm = "140", gui = "c29bf3" }
---}}}
--
-- {{{ highlight configrator
local function setHi(group, fg, bg, attr)
    if (fg['cterm'] ~= nil) then
        vim.cmd("hi!" .. group .. " ctermfg=" .. fg.cterm)
    end

    if (bg['cterm'] ~= nil) then
        vim.cmd("hi!" .. group .. " ctermbg=" .. bg.cterm)
    end

    if (fg['gui'] ~= nil) then
        vim.cmd("hi!" .. group .. " guifg=#" .. fg.gui)
    end

    if (bg['gui'] ~= nil) then
        vim.cmd("hi!" .. group .. " guibg=#" .. bg.gui)
    end
    --attribute
    if (attr ~= "") then
        vim.cmd("hi!" .. group .. " gui=" .. attr .. " cterm=" .. attr)
    end
end
-- }}}
--
-- {{{ highlight configuration
-- init highlight --
vim.cmd("set termguicolors")
vim.cmd("hi clear")
-- enable syntax
vim.cmd("syntax enable")

----- highlight ---"
setHi("Comment", hl_mono6, unspec, "none")

setHi("Constant", hl_str01, unspec, "none")
setHi("String", hl_str01, unspec, "none")
setHi("Character", hl_str01, unspec, "none")
setHi("Number", hl_num01, unspec, "none")
setHi("Float", hl_num01, unspec, "none")
setHi("Boolean", hl_blue3, unspec, "none")

setHi("Identifier", hl_blue2, unspec, "none")
setHi("Function", hl_idf02, unspec, "none")

setHi("Statement", hl_blue1, unspec, "none")
setHi("Conditional", hl_stm02, unspec, "none")
setHi("Repeat", hl_stm02, unspec, "none")
setHi("Label", hl_stm02, unspec, "none")
setHi("Exception", hl_stm02, unspec, "none")
setHi("Operator", hl_mono8, unspec, "none")
setHi("Keyword", hl_blue1, unspec, "none")

setHi("PreProc", hl_prp01, unspec, "none")
setHi("Include", hl_prp01, unspec, "none")
setHi("Define", hl_prp01, unspec, "none")
setHi("Macro", hl_prp01, unspec, "none")
setHi("PreCondit", hl_prp01, unspec, "none")

setHi("Type", hl_typ01, unspec, "none")
--setHi("StorageClass", hl_typ01, unspec, "none")
--setHi("Structure", hl_typ01, unspec, "none")
--setHi("Typedef", hl_typ01, unspec, "none")

setHi("Special", hl_spe01, unspec, "none")
--setHi("SpecialChar", hl_spe01, unspec, "none")
--setHi("Tag", hl_spe01, unspec, "none")
--setHi("Delimiter", hl_spe01, unspec, "none")
--setHi("SpecialComment", hl_spe01, unspec, "none")
--setHi("Debug", hl_spe01, unspec, "none")

setHi("Underlined", hl_mono9, unspec, "none")

setHi("Ignore", hl_mono1, hl_mono9, "none")

setHi("Error", hl_mono9, hl_erro0, "none")

setHi("Todo", hl_mono9, hl_warn0, "none")

----- highlight-group ------"
setHi("Normal", hl_mono9, hl_mono1, "none")
setHi("NormalNC", hl_mono8, hl_mono1, "none")
-- setHi("NormalFloat", hl_mono9, hl_mono5, "none")
setHi("NormalFloat", hl_mono9, hl_mono3, "none")
setHi("FloatBorder", hl_mono7, hl_mono1, "none")

setHi("NonText", hl_mono3, unspec, "none")
setHi("Whitespace", hl_mono3, unspec, "none")
setHi("EndOfBuffer", hl_mono3, unspec, "none")

setHi("Conceal", hl_mono9, hl_mono1, "none")

setHi("Cursor", unspec, unspec, "reverse")
--setHi("lCursor",      unspec, unspec, "reverse")
--setHi("CursorIM",     unspec, unspec, "reverse")
--setHi("TermCursor",   unspec, unspec, "reverse")
--setHi("TermCursorNC", unspec, unspec, "reverse")

setHi("ColorColumn", unspec, hl_mono2, "none")

setHi("Directory", hl_blue1, unspec, "none")

setHi("DiffAdd", unspec, hl_safe0, "none")
setHi("DiffDelete", hl_erro0, hl_erro0, "none")
setHi("DiffChange", unspec, hl_warn0, "none")
setHi("DiffText", unspec, hl_mono6, "none")

setHi("ErrorMsg", hl_mono9, hl_erro0, "none")
setHi("WarningMsg", hl_mono9, hl_warn0, "none")

setHi("WinSeparator", hl_sep01, hl_sep01, "none")
setHi("VertSplit", hl_sep01, hl_sep01, "none")

setHi("Folded", hl_mono7, hl_blue0, "none")

setHi("Search", hl_mono9, hl_search, "none")
setHi("CurSearch", hl_mono9, hl_search, "underline")
setHi("IncSearch", hl_mono9, hl_search, "underline")

setHi("Substitute", unspec, hl_search, "none")

setHi("CursorLine", unspec, hl_mono2, "none")
setHi("CursorColumn", hl_mono8, hl_mono2, "none")
setHi("CursorLineNr", hl_mono9, hl_mono2, "none")
setHi("CursorLineFold", hl_mono8, hl_mono2, "none")
setHi("CursorLineSign", unspec, hl_mono2, "none")

setHi("LineNr", hl_mono7, hl_mono2, "none")
setHi("LineNrAbove", hl_mono7, hl_mono2, "none")
setHi("LineNrBelow", hl_mono7, hl_mono2, "none")

setHi("FoldColumn", hl_mono7, hl_mono2, "none")

setHi("SignColumn", unspec, hl_mono1, "none")
setHi("Sign", hl_emph0, unspec, "none")

setHi("MatchParen", hl_emph0, hl_mono3, "none")

setHi("ModeMsg", hl_mono9, hl_search, "none")
setHi("MsgArea", hl_mono9, hl_mono1, "none")
setHi("MsgSeparator", hl_mono9, hl_mono5, "none")

setHi("MoreMsg", hl_more0, unspec, "none")
setHi("Question", hl_more0, unspec, "none")

setHi("Pmenu", hl_mono9, hl_mono5, "none")
setHi("PmenuSel", hl_mono9, hl_mono6, "none")
setHi("PmenuSbar", hl_mono9, hl_mono3, "none")
setHi("PmenuThumb", hl_mono9, hl_search, "none")

setHi("QuickFixLine", hl_mono9, hl_mono5, "none")

setHi("SpecialKey", hl_mono6, unspec, "none")

setHi("SpellBad", hl_mono9, hl_erro1, "none")
setHi("SpellCap", hl_mono9, hl_erro1, "none")
setHi("SpellLocal", hl_mono9, hl_erro1, "none")
setHi("SpellRare", hl_mono9, hl_erro1, "none")

setHi("StatusLine", hl_mono9, hl_sep01, "none")
setHi("StatusLineNC", hl_sep01, hl_sep01, "none")

setHi("TabLine", hl_mono9, hl_mono5, "none")
setHi("TabLineFill", hl_mono2, hl_sep01, "none")
setHi("TabLineSel", hl_mono9, hl_mnorm, "none")

setHi("Title", hl_emph0, unspec, "bold")

setHi("Visual", unspec, hl_mono5, "none")

setHi("WildMenu", hl_mono7, hl_mono9, "none")

setHi("WinBar", hl_mono9, hl_mono1, "none")
setHi("WinBarNC", hl_mono9, hl_mono1, "none")

setHi("StatusLineTerm", hl_mono9, hl_sep01, "none")
setHi("StatusLineTermNC", hl_mono9, hl_sep01, "none")

--}}}
--
-- {{{ make background transparent
local function make_bg_transparent(bg_transparent)
    if bg_transparent == false then return end
    local transparent_hl_groups = {
        "Normal", "NormalNC",
        "StatusLineNC",
        "TabLineFill",
        "SignColumn",
        "StatusLineTermNC"
    }
    for i = 1, #transparent_hl_groups do
        vim.cmd("hi! " .. transparent_hl_groups[i] .. " guibg=none")
    end
end
make_bg_transparent(config.bg_transparent)
-- }}}
--
-- {{{ user defined highlight
--each mode
setHi("mModeNormal", hl_mono9, hl_mnorm, "none")
setHi("mModeInsert", hl_mono9, hl_minse, "none")
setHi("mModeCommand", hl_mono9, hl_mcomm, "none")
setHi("mModeVisual", hl_mono9, hl_mvisu, "none")
setHi("mModeTerm", hl_mono9, hl_mterm, "none")
setHi("mModeTJob", hl_mono9, hl_mtjob, "none")

-- #user defined syntax
-- network addresses
setHi("uAddress", { cterm = "49", gui = "95f0d0" }, unspec, "none")
-- chars
setHi("uMultiSpace", unspec, hl_mono6, "underline")
setHi("uParen", hl_mono5, unspec, "none")
-- init.lua banner
setHi("uInitLuaBanner", hl_idf02, hl_blue0, "none")

local augroup_hl_user_syntax = vim.api.nvim_create_augroup('highlightUserSyntax', { clear = true })

vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup_hl_user_syntax,
    callback = (function()
        vim.cmd("syntax match uParen '\\v[{}]{3}'")
        vim.cmd("syntax match uMultiSpace '　'")
        vim.cmd("syntax match uAddress '\\v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}'") -- IP
        vim.cmd("syntax match uAddress '\\v[0-9A-Fa-f]{2}([:-][0-9A-Fa-f]{2}){5}'")     -- MAC
    end)
})

vim.api.nvim_create_autocmd('BufEnter', {
    pattern = { "init.lua" },
    group = augroup_hl_user_syntax,
    callback = function()
        vim.cmd("syntax match uInitLuaBanner '╭─── rogawa init.lua   ╭─╮              ───╮'")
        vim.cmd("syntax match uInitLuaBanner '│ ╭─╮    ╭─╮    ╭─────╮│ │          ╭────╮ │'")
        vim.cmd("syntax match uInitLuaBanner '│ │ │ ╭──│ │ ╭─╮╰─╮ ╭─╯│ │   ╭─╮ ╭─╮│ ╭╮ │ │'")
        vim.cmd("syntax match uInitLuaBanner '│ │ │ │  │ │ │ │  │ │  │ │   │ │ │ ││ ╰╯ │ │'")
        vim.cmd("syntax match uInitLuaBanner '│ │ │ │ ╮  │ │ │  │ │  │ ╰──╮│ │ │ ││ ╭╮ │ │'")
        vim.cmd("syntax match uInitLuaBanner '│ ╰─╯ │ │──╯ │ │  ╰─╯☺ ╰────╯│ ╰─╯ ││ │╰─╯ │'")
        vim.cmd("syntax match uInitLuaBanner '╰───  ╰─╯    ╰─╯             ╰─────╯╰─╯ ───╯'")
    end,
})
--}}}
--10.10.10.10
