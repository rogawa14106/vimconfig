vim.cmd[[
"{{{ highlighting
"{{{ highlight config function
function! SetHi(group, ctermfg, ctermbg, guifg, guibg, attr) abort
    "cterm"
    if a:ctermfg != ""
        exec "hi! " . a:group . " ctermfg=" . a:ctermfg
    endif
    if a:ctermbg != ""
        exec "hi! " . a:group . " ctermbg=" . a:ctermbg
    endif
 
    "gui"
    if a:guifg != ""
        exec "hi! " . a:group . " guifg=#" . a:guifg
    endif
    if a:guibg != ""
        exec "hi! " . a:group . " guibg=#" . a:guibg
    endif

    "attribute"
    if a:attr != ""
        exec "hi! " . a:group . " gui=" . a:attr . " cterm=" . a:attr
    endif
endfunction
"}}}
"{{{ color palet
let s:ugui_mono0 = "000000"
let s:ugui_mono1 = "18181c"
let s:ugui_mono2 = "1e1e26"
let s:ugui_mono3 = "282830"
let s:ugui_mono4 = "3d3d50"
let s:ugui_mono5 = "404040"
let s:ugui_mono6 = "606060"
let s:ugui_mono7 = "808080"
let s:ugui_mono8 = "d0d0d1"
let s:ugui_mono9 = "e0e0e0"
let s:ugui_monoA = "ffffff"

let s:ugui_erro0 = "602828"
let s:ugui_erro1 = "d04848"
let s:ugui_warn0 = "606028"
let s:ugui_safe0 = "286028"

let s:ugui_emph0 = "45a080" "search
let s:ugui_emph1 = "397874" "incsearch, cursorsearch, 
let s:ugui_emph2 = "296864" "match paren
let s:ugui_emph3 = "253c3c" "visual
let s:ugui_emph4 = "95f0d0" "sign

let s:ugui_mnorm = "304070"
let s:ugui_mcomm = "583058"
let s:ugui_minse = "803030"
let s:ugui_mvisu = "307040"
let s:ugui_mterm = "304070"
let s:ugui_mtjob = "080810"

let s:ugui_separator = "282830"

let s:ucterm_mono0 = "0"
let s:ucterm_mono1 = "231"
let s:ucterm_mono2 = "255"
let s:ucterm_mono3 = "242"
let s:ucterm_mono4 = "237"
let s:ucterm_mono5 = "242"
let s:ucterm_mono6 = "242"
let s:ucterm_mono7 = "248"
let s:ucterm_mono8 = "254"
let s:ucterm_mono9 = "252"
let s:ucterm_monoA = "237"

let s:ucterm_emph0 = "7474eb"
let s:ucterm_emph1 = "2a2058"
let s:ucterm_emph2 = "3a20c8"
let s:ucterm_emph3 = "384360"
"}}}
"{{{ highlight configuration
"--- init highlight ---"
set termguicolors
hi clear
"syntax reset
syntax enable

"--- highlight ---"
call SetHi("Comment",        "103", "",    s:ugui_mono6, "",           "none")
call SetHi("Constant",       "73",  "",    "f3c29b",     "",           "none")
"{{{highlight! String term=none cterm=none ctermbg=none ctermfg=166
"highlight! Character term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Number term=none cterm=none ctermbg=none ctermfg=73 guibg=none guifg=#9bf39f
"highlight! Boolean term=none cterm=none ctermbg=none ctermfg=37
"highlight! Float term=none cterm=none ctermbg=none ctermfg=73}}}

call SetHi("Identifier",     "26",  "",    "95d0f0",     "",           "none")
call SetHi("Function",       "26",  "",    "f3f09b",     "",           "none")

call SetHi("Statement",      "125", "",    "9ba2f3",     "",           "none")
call SetHi("Conditional",    "125", "",    "f39bbc",     "",           "none")
call SetHi("Repeat",         "125", "",    "f39bbc",     "",           "none")
call SetHi("Label",          "125", "",    "f39bbc",     "",           "none")
call SetHi("Exception",      "125", "",    "f39bbc",     "",           "none")
"{{{highlight! Operator term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Keyword  term=bold cterm=bold ctermbg=none ctermfg=125 guibg=none guifg=#ff337c}}}

call SetHi("PreProc",        "",    "",    "e69bf3",     "",           "none")
"{{{highlight! Include term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Define term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Macro term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! PreCondit term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff}}}

call SetHi("Type",           "63",  "",    "95f0d0",     "",           "none")
"{{{highlight! StorageClass term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Structure term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Typedef term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff}}}

call SetHi("Special",        "142", "",    "fff9b3",     "",           "none")
"{{{highlight! SpecialChar term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Tag term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Delimiter term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! SpecialComment term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff
"highlight! Debug term=none cterm=none ctermbg=none ctermfg=231 guifg=#ffffff}}}

call SetHi("Underlined",     "27",  "",    s:ugui_mono9, "",           "none")

call SetHi("Ignore",         "",    "",    s:ugui_mono9, s:ugui_mono0, "none")

call SetHi("Error",          "237",  "217", s:ugui_mono9, s:ugui_erro1, "none")

call SetHi("Todo",           "0",   "11",  s:ugui_mono9, s:ugui_warn0, "none")

"--- highlight-group ------"
call SetHi("Normal",         "237", "231", s:ugui_mono9, s:ugui_mono1, "none")
call SetHi("NormalFloat",    "237", "254", s:ugui_mono9, s:ugui_mono4, "none")
call SetHi("NormalNC",       "237", "231", s:ugui_mono9, s:ugui_mono1, "none")

call SetHi("NonText",        "189", "",    s:ugui_mono3, "",           "none")

call SetHi("Whitespace",     "189", "",    s:ugui_mono3, "",           "none")

call SetHi("EndOfBuffer",    "189", "",    s:ugui_mono3, "",           "none")

call SetHi("Conceal",        "230", "0",   s:ugui_mono9, s:ugui_mono0, "none")

call SetHi("Cursor",         "",    "",    "", "", "reverse")
"{{{highlight! lCursor        term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#000000
"highlight! CursorIM       term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#000000
"highlight! TermCursor     term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#000000
"highlight! TermCursorNC   term=none cterm=none ctermbg=0 ctermfg=231 guifg=#ffffff guibg=#00000}}}

call SetHi("ColorColumn",    "", "255", "", s:ugui_mono2, "none")

call SetHi("Directory",      "63",  "",    "9ba2f3",     "",           "none")

call SetHi("DiffAdd",        "237", "157", "", s:ugui_safe0, "none")
call SetHi("DiffDelete",     "217", "217", s:ugui_erro0, s:ugui_erro0, "none")
call SetHi("DiffChange",     "237", "186", "", s:ugui_warn0, "none")
call SetHi("DiffText",       "237", "229", "", s:ugui_mono6, "none")

call SetHi("ErrorMsg",       "237",  "217", s:ugui_mono9, s:ugui_erro0,     "none")
call SetHi("WarningMsg",     "237", "227", s:ugui_mono9, s:ugui_warn0,     "none")

call SetHi("WinSeparator",   "0",   "0",   s:ugui_separator, s:ugui_separator, "none")
call SetHi("FloatBorder",    "237", "231", s:ugui_mono7, s:ugui_mono1, "none")
call SetHi("VertSplit",      "252", "242", s:ugui_separator, s:ugui_separator, "none")

call SetHi("Folded",         "237", "188", s:ugui_mono7, "102038",     "none")

call SetHi("Search",         "",    "224", s:ugui_mono9, s:ugui_emph1, "none")
call SetHi("CurSearch",      "",    "217", s:ugui_mono9, s:ugui_emph0, "none")
call SetHi("IncSearch",      "",    "217", s:ugui_mono9, s:ugui_emph0, "none")

call SetHi("Substitute",     "",    "224", "",           s:ugui_emph1, "none")

call SetHi("CursorLine",     "",    "255", "",           s:ugui_mono2, "none")
call SetHi("CursorColumn",   "247", "255", s:ugui_mono8, s:ugui_mono2, "none")
call SetHi("CursorLineNr",   "231", "237", s:ugui_mono8, s:ugui_mono2, "none")
call SetHi("CursorLineFold", "247", "237", s:ugui_mono8, s:ugui_mono2, "none")
call SetHi("CursorLineSign", "",    "237", "",           s:ugui_mono2, "none")

call SetHi("LineNr",         "252", "242", s:ugui_mono6, s:ugui_mono2, "none")
call SetHi("LineNrAbove",    "252", "242", s:ugui_mono6, s:ugui_mono2, "none")
call SetHi("LineNrBelow",    "252", "242", s:ugui_mono6, s:ugui_mono2, "none")

call SetHi("FoldColumn",     "252", "242", s:ugui_mono6, s:ugui_mono2, "none")

call SetHi("SignColumn",     "",    "237", "",           s:ugui_mono2, "none")
call SetHi("Sign",           "104", "237", s:ugui_emph4, s:ugui_mono2, "none")

call SetHi("MatchParen",     "237", "229", s:ugui_mono9, s:ugui_emph1, "none")

call SetHi("ModeMsg",        "231", "139", s:ugui_mono9, s:ugui_emph1, "none")
call SetHi("MsgArea",        "237", "231", s:ugui_mono9, s:ugui_mono1, "none")
call SetHi("MsgSeparator",   "231", "237", s:ugui_mono9, s:ugui_mono4, "none")

call SetHi("MoreMsg",        "73",  "",    "c29bf3",     "",           "none")
call SetHi("Question",       "73",  "",    "c29bf3",     "",           "none")

call SetHi("Pmenu",      "248", "242", s:ugui_mono9, s:ugui_mono4, "none")
call SetHi("PmenuSel",   "231", "237", s:ugui_mono9, s:ugui_emph0, "none")
call SetHi("PmenuSbar",  "231", "0",   s:ugui_mono9, s:ugui_mono3, "none")
call SetHi("PmenuThumb", "231", "242", s:ugui_mono9, s:ugui_emph0, "none")

call SetHi("QuickFixLine", "231", "237", s:ugui_mono9, s:ugui_mono4, "none")

call SetHi("SpecialKey", "81",  "", s:ugui_mono6, "", "none")

call SetHi("SpellBad",   "15",  "217", s:ugui_mono9, s:ugui_erro1, "none")
call SetHi("SpellCap",   "231", "0",   s:ugui_mono9, s:ugui_mono0, "none")
call SetHi("SpellLocal", "231", "0",   s:ugui_mono9, s:ugui_mono0, "none")
call SetHi("SpellRare",  "231", "0",   s:ugui_mono9, s:ugui_mono0, "none")

call SetHi("StatusLine",   "231", "242", s:ugui_mono9,     s:ugui_separator, "none")
call SetHi("StatusLineNC", "242", "242", s:ugui_separator, s:ugui_separator, "none")

call SetHi("TabLine",     "252", "242", s:ugui_mono9, s:ugui_mono5, "none")
call SetHi("TabLineFill", "231", "242", s:ugui_mono2, s:ugui_separator, "none")
call SetHi("TabLineSel",  "231", "104", s:ugui_mono9, s:ugui_mnorm, "none")

call SetHi("Title",          "213", "",    s:ugui_emph0, "",           "bold")

call SetHi("Visual",         "",    "224", "",           s:ugui_emph3, "none")

call SetHi("WildMenu",       "248", "242", s:ugui_mono7, s:ugui_mono9, "none")

call SetHi("WinBar",         "231", "0",   s:ugui_mono9, s:ugui_mono0, "none")
call SetHi("WinBarNC",       "231", "0",   s:ugui_mono9, s:ugui_mono0, "none")

call SetHi("StatusLineTerm", "231", "0",   s:ugui_mono9, s:ugui_separator, "none")
call SetHi("StatusLineTermNC", "231", "0", s:ugui_mono9, s:ugui_separator, "none")

"}}}
"{{{ user defined highlight
"each mode"
call SetHi("mModeNormal",    "231", "104", s:ugui_mono8, s:ugui_mnorm, "none")
call SetHi("mModeInsert",    "231", "203", s:ugui_mono8, s:ugui_minse, "none")
call SetHi("mModeCommand",   "231", "178", s:ugui_mono8, s:ugui_mcomm, "none")
call SetHi("mModeVisual",    "231", "36",  s:ugui_mono8, s:ugui_mvisu, "none")
call SetHi("mModeTerm",      "231", "0",   s:ugui_mono8, s:ugui_mterm, "none")
call SetHi("mModeTJob",      "231", "0",   s:ugui_mono8, s:ugui_mtjob, "none")
"floating window scroll bar"
"call SetHi("mScrollBase",    "231", "255", s:ugui_mono3, s:ugui_mono3, "none")
"call SetHi("mScrollGrip",    "231", "250", s:ugui_mono5, "9494eb", "none")

function! ApplyUserSyntax() abort
    "network addrs"
    syntax match uIPAddr /\v\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
    highlight! default	 link uIPAddr Type

    syntax match uMacAddr /\v[0-9A-Fa-f]{2}([:-][0-9A-Fa-f]{2}){5}/
    highlight! default	 link uMacAddr Identifier

    "header highlight"
    syntax match uHeader1 '^\s*[=■]'
    highlight! def link uHeader1 Type

    syntax match uHeader2 '^\s*=='
    highlight! def link uHeader2 Statement

    syntax match uHeader3 '^\s*==='
    highlight! def link uHeader3 Title

    syntax match uMultiSpace '　'
    highlight! def link uMultiSpace WarningMsg

    "vimrc header"
    if expand("%:p") == $MYVIMRC
        "AA highlight
        syntax match uAA '/'
        "highlight! uAA cterm=none gui=none ctermfg=104 ctermbg=255 guifg=#95f0d0 guibg=#181818
        "highlight! uAA cterm=none gui=none ctermfg=104 ctermbg=255 guifg=#f5f0cd guibg=#181818
        highlight! uAA cterm=none gui=none ctermfg=104 ctermbg=255 guifg=#95d8e8 guibg=#181818
    endif
endfunction

augroup Attachsyntax
    autocmd!
    autocmd BufEnter * call ApplyUserSyntax()
augroup END

"}}}
"{{{ delete function and variables that used in highlighting
delfunction SetHi
unlet s:ugui_mono0 s:ugui_mono1 s:ugui_mono2 s:ugui_mono3 s:ugui_mono4 s:ugui_mono5 s:ugui_mono6 s:ugui_mono7 s:ugui_mono8 s:ugui_mono9 s:ugui_monoA
unlet s:ugui_emph0 s:ugui_emph1 s:ugui_emph2 s:ugui_emph3
"}}}
"=================================================================================================================================================================}}}
]]

