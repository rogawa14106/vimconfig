-- {{{ highlight configrate function
function setHi(group, fg, bg, attr)
    if (fg ~= "") then
        vim.cmd("hi!" .. group .. " guifg=#" .. fg.gui .. " ctermfg=" .. fg.cterm)
    end

    if (bg ~= "") then
        vim.cmd("hi!" .. group .. " guibg=#" .. bg.gui .. " ctermbg=" .. bg.cterm)
    end

    --attribute
    if (attr ~= "") then
        vim.cmd("hi!" .. group .. " gui=" .. attr .. " cterm=" .. attr)
    end
end
-- }}}
-- {{{ color palet
unspec = ""
hl_mono1 = { cterm="234", gui="18181c" }
hl_mono2 = { cterm="235", gui="1e1e26" }
hl_mono3 = { cterm="236", gui="282830" }
hl_mono4 = { cterm="236", gui="3d3d50" }
hl_mono5 = { cterm="236", gui="404040" }
hl_mono6 = { cterm="243", gui="606060" }
hl_mono7 = { cterm="250", gui="808080" }
hl_mono8 = { cterm="253", gui="d0d0d1" }
hl_mono9 = { cterm="253", gui="e0e0e0" }

hl_blue0 = { cterm="24", gui="102038" }
hl_blue1 = { cterm="111", gui="9ba2f3" }
hl_blue2 = { cterm="117", gui="95d0f0" }
hl_blue3 = { cterm="75", gui="439bbc" }

hl_erro0 = { cterm="1", gui="602828" }
hl_erro1 = { cterm="9", gui="d04848" }
hl_warn0 = { cterm="3", gui="606028" }
hl_safe0 = { cterm="2", gui="286028" }

hl_emph0 = { cterm="62", gui="45a080" }
hl_emph1 = { cterm="60", gui="397874" }
--hl_emph2 = { cterm="0", gui="296864" }
hl_emph3 = { cterm="23", gui="253c3c" }
hl_emph4 = { cterm="85", gui="95f0d0" }

hl_mnorm = { cterm="24", gui="304070" }
hl_mcomm = { cterm="58", gui="583058" }
hl_minse = { cterm="95", gui="803030" }
hl_mvisu = { cterm="23", gui="307040" }
hl_mterm = { cterm="0", gui="304070" }
hl_mtjob = { cterm="0", gui="080810" }

hl_sep01 = { cterm="237", gui="282830" }
---}}}
-- {{{ highlight configuration
-- init highlight --
vim.cmd("set termguicolors")
vim.cmd("hi clear")
-- enable syntax
vim.cmd("syntax enable")

----- highlight ---"
setHi("Comment", hl_mono6, unspec, "none")


hl_str01 = {cterm="223", gui="f3c29b"}
hl_num01 = {cterm="114", gui="abddb6"}
setHi("Constant",  hl_str01, unspec, "none")
setHi("String",    hl_str01, unspec, "none")
setHi("Character", hl_str01, unspec, "none")
setHi("Number"  ,  hl_num01, unspec, "none")
setHi("Float"  ,  hl_num01, unspec, "none")
setHi("Boolean" ,  hl_blue3, unspec, "none")

hl_idf02 = {cterm="229", gui="f3f3a8"}
setHi("Identifier", hl_blue2, unspec, "none")
setHi("Function",   hl_idf02, unspec, "none")

hl_stm02 = {cterm="218", gui="f39bbc"}
setHi("Statement"  , hl_blue1, unspec, "none")
setHi("Conditional", hl_stm02, unspec, "none")
setHi("Repeat",      hl_stm02, unspec, "none")
setHi("Label",       hl_stm02, unspec, "none")
setHi("Exception",   hl_stm02, unspec, "none")
setHi("Operator",    hl_mono9, unspec, "none")
setHi("Keyword",     hl_blue1, unspec, "none")
--{{{
--highlight! Keyword  term=bold cterm=bold ctermbg=none ctermfg=125 guibg=none guifg=#ff337c
--}}}

hl_prp01 = {cterm="168", gui="e69bf3"}
setHi("PreProc", hl_prp01, unspec, "none")
--{{{
--highlight! Include term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
--highlight! Define term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
--highlight! Macro term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
--highlight! PreCondit term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
--}}}

hl_typ01 = {cterm="43", gui="77c89e"}
setHi("Type", hl_typ01, unspec, "none")
--{{{highlight! StorageClass term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
--highlight! Structure term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
--highlight! Typedef term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff}}}

hl_spe01 = {cterm="229", gui="fff9b3"}
setHi("Special", hl_spe01, unspec, "none")
--{{{highlight! SpecialChar term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
--highlight! Tag term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
--highlight! Delimiter term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
--highlight! SpecialComment term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
--highlight! Debug term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff}}}

setHi("Underlined", hl_mono9, unspec, "none")

setHi("Ignore", hl_mono1, hl_mono9, "none")

setHi("Error", hl_mono9, hl_erro1, "none")

setHi("Todo", hl_mono9, hl_warn0, "none")

----- highlight-group ------"
setHi("Normal",      hl_mono9, hl_mono1, "none")
setHi("NormalFloat", hl_mono9, hl_mono4, "none")
setHi("NormalNC",    hl_mono9, hl_mono1, "none")

setHi("NonText",     hl_mono3, unspec, "none")
setHi("Whitespace",  hl_mono3, unspec, "none")
setHi("EndOfBuffer", hl_mono3, unspec, "none")

setHi("Conceal", hl_mono9, hl_mono1, "none")

setHi("Cursor", unspec, unspec, "reverse")
--{{{
--highlight! lCursor        term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#000000
--highlight! CursorIM       term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#000000
--highlight! TermCursor     term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#000000
--highlight! TermCursorNC   term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#000000
--}}}

setHi("ColorColumn", unspec, hl_mono2, "none")

setHi("Directory", hl_blue1, unspec, "none")

setHi("DiffAdd", unspec, hl_safe0, "none")
setHi("DiffDelete", hl_erro0, hl_erro0, "none")
setHi("DiffChange", unspec, hl_warn0, "none")
setHi("DiffText", unspec, hl_mono6, "none")

setHi("ErrorMsg", hl_mono9, hl_erro0, "none")
setHi("WarningMsg", hl_mono9, hl_warn0, "none")

setHi("WinSeparator", hl_sep01, hl_sep01, "none")
setHi("FloatBorder", hl_mono7, hl_mono1, "none")
setHi("VertSplit", hl_sep01, hl_sep01, "none")

setHi("Folded", hl_mono7, hl_blue0, "none")

setHi("Search", hl_mono9, hl_emph1, "none")
setHi("CurSearch", hl_mono9, hl_emph0, "none")
setHi("IncSearch", hl_mono9, hl_emph0, "none")

setHi("Substitute", unspec, hl_emph1, "none")

setHi("CursorLine", unspec, hl_mono2, "none")
setHi("CursorColumn", hl_mono8, hl_mono2, "none")
setHi("CursorLineNr", hl_mono8, hl_mono2, "none")
setHi("CursorLineFold", hl_mono8, hl_mono2, "none")
setHi("CursorLineSign", unspec, hl_mono2, "none")

setHi("LineNr", hl_mono6, hl_mono2, "none")
setHi("LineNrAbove", hl_mono6, hl_mono2, "none")
setHi("LineNrBelow", hl_mono6, hl_mono2, "none")

setHi("FoldColumn", hl_mono6, hl_mono2, "none")

setHi("SignColumn", unspec, hl_mono2, "none")
setHi("Sign", hl_emph4, hl_mono2, "none")

setHi("MatchParen", hl_emph4, hl_mono3, "none")

setHi("ModeMsg", hl_mono9, hl_emph1, "none")
setHi("MsgArea", hl_mono9, hl_mono1, "none")
setHi("MsgSeparator", hl_mono9, hl_mono4, "none")

hl_more0 = {cterm="140", gui="c29bf3"}
setHi("MoreMsg",  hl_more0, unspec, "none")
setHi("Question", hl_more0, unspec, "none")

setHi("Pmenu", hl_mono9, hl_mono4, "none")
setHi("PmenuSel", hl_mono9, hl_emph0, "none")
setHi("PmenuSbar", hl_mono9, hl_mono3, "none")
setHi("PmenuThumb", hl_mono9, hl_emph0, "none")

setHi("QuickFixLine", hl_mono9, hl_mono4, "none")

setHi("SpecialKey", hl_mono6, unspec, "none")

setHi("SpellBad", hl_mono9, hl_erro1, "none")
setHi("SpellCap", hl_mono9, hl_mono1, "none")
setHi("SpellLocal", hl_mono9, hl_mono1, "none")
setHi("SpellRare", hl_mono9, hl_mono1, "none")

setHi("StatusLine", hl_mono9, hl_sep01, "none")
setHi("StatusLineNC", hl_sep01, hl_sep01, "none")

setHi("TabLine", hl_mono9, hl_mono5, "none")
setHi("TabLineFill", hl_mono2, hl_sep01, "none")
setHi("TabLineSel", hl_mono9, hl_mnorm, "none")

setHi("Title", hl_emph0, unspec, "bold")

setHi("Visual", unspec, hl_emph3, "none")

setHi("WildMenu", hl_mono7, hl_mono9, "none")

setHi("WinBar", hl_mono9, hl_mono1, "none")
setHi("WinBarNC", hl_mono9, hl_mono1, "none")

setHi("StatusLineTerm", hl_mono9, hl_sep01, "none")
setHi("StatusLineTermNC", hl_mono9, hl_sep01, "none")

--}}}
-- {{{ user defined highlight
--each mode
setHi("mModeNormal",  hl_mono8, hl_mnorm, "none")
setHi("mModeInsert",  hl_mono8, hl_minse, "none")
setHi("mModeCommand", hl_mono8, hl_mcomm, "none")
setHi("mModeVisual",  hl_mono8, hl_mvisu, "none")
setHi("mModeTerm",    hl_mono8, hl_mterm, "none")
setHi("mModeTJob",    hl_mono8, hl_mtjob, "none")

-- #user defined syntax
-- headline
setHi("uHead0", {cterm="49", gui="95f0d0"}, unspec, "none")
setHi("uHead1", {cterm="42", gui="65c090"}, unspec, "none")
setHi("uHead2", {cterm="35", gui="359060"}, unspec, "none")
-- list
setHi("uList0", {cterm="45", gui="95d0f0"}, unspec, "none")
-- address
setHi("uAddress", {cterm="49", gui="95f0d0"}, unspec, "none")
-- others
setHi("uMultiSpace", unspec, hl_mono6, "underline")
setHi("uParen", hl_mono5, unspec, "none")

vim.api.nvim_create_augroup('highlightUserSyntax', {})
vim.api.nvim_create_autocmd('BufEnter', {
    group = 'highlightUserSyntax',
    callback = (function()
        vim.cmd("syntax match uHead0 '\\v^[\\s]*#'")
        vim.cmd("syntax match uHead1 '\\v^\\s*##'")
        vim.cmd("syntax match uHead2 '\\v^\\s*###'")
        vim.cmd("syntax match uList0 '\\v^\\s*-'")
        vim.cmd("syntax match uParen '\\v[{}]{3}'")
        vim.cmd("syntax match uAddress '\\v\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}'")
        vim.cmd("syntax match uAddress '\\v[\\dA-Fa-f]{2}([:-][0-9A-Fa-f]{2}){5}'")
        vim.cmd("syntax match uMultiSpace '　'")

    end)
})

