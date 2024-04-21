vim.cmd[[
"{{{ floating window scrollbar
function! CreateScrollBar() abort
    if exists("s:sb_win")
        return
    endif
    let l:u_scrollbar_gripper = nvim_create_buf(v:false, v:true)
    let l:opts = {'relative': 'win', 'width': 1,'height': 1, 'anchor': 'NE', 'style': 'minimal', 'col': 0, 'row': 0}
    let s:sb_win = nvim_open_win(l:u_scrollbar_gripper, v:false, l:opts)
endfunction

function! ChangeScrollBarGripper() abort
    let l:buf_height = line("$")
    let l:win_top    = line("w0")
    let l:win_bot    = line("w$")
    let l:win_lines  = l:win_bot - l:win_top + 1
    let l:win_height = winheight(0)
    let l:win_width  = winwidth(0)

    "caliculate grip height 
    let l:bar_grip_height = l:win_height * l:win_lines / l:buf_height
    "chantge negative value to 1
    if l:bar_grip_height <= 0
        let l:bar_grip_height = 1
    endif
    "caliculate grip starting position
    let l:bar_grip_top = l:win_height * l:win_top / l:buf_height

    "change row when grep height eq window height
    if l:bar_grip_height == l:win_height
        let l:bar_grip_top = 0
    endif

    "make top white space on scrollbar when first line was not shown
    if (l:bar_grip_top == 0) && (l:win_top != 1)
        let l:bar_grip_top = 1
    endif
    "delete bottom white spase ob scrollbar when last line was shown
    if l:win_bot == line("$")
        let l:bar_grip_top = winheight(0) - l:bar_grip_height
    endif

    let l:opts = {'relative': 'win', 'width': 1, 'height': l:bar_grip_height, 'col': l:win_width, 'row': l:bar_grip_top, 'anchor': 'NE', 'style': 'minimal'}
    call nvim_win_set_config(s:sb_win, l:opts)
endfunction

augroup changeScrollbar
    autocmd!
    "autocmd VimEnter * ++once call CreateScrollBar()
    "autocmd WinScrolled * noautocmd call ChangeScrollBarGripper()
augroup END

"}}}
]]

