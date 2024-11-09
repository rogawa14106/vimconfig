local M = {}

M.stl_colors = require('core.design').colors
M.main_colors = M.stl_colors.blue

M.stl_icons = require('core.design').icons

---@param type "r"|"l"
---@param depth integer
---@param is_end boolean?
M.make_separator = function(type, depth, is_end)
    local sep_list = {
        ['r'] = M.stl_icons.separator.slant_fill_r,
        ['l'] = M.stl_icons.separator.slant_fill_l,
    }
    local hi = ""
    if is_end then
        vim.cmd("hi uStlSepEnd" .. type .. " gui=none guifg=#" .. M.main_colors[depth] .. "")
        hi = "%#uStlSepEnd" .. type .. "#"
    else
        hi = "%#uStlSep" .. depth .. "#"
    end
    local sep = hi .. sep_list[type] .. "%*"
    return sep
end

M.stat_mode = function()
    local current_mode_str = vim.fn.mode()
    local mode_list = {
        { mode_str = "n", disp_str = "NORMAL",   color = "mModeNormal", },
        { mode_str = "i", disp_str = "INSERT",   color = "mModeInsert", },
        { mode_str = "R", disp_str = "REPLACE",  color = "mModeInsert", },
        { mode_str = "c", disp_str = "COMMAND",  color = "mModeCommand", },
        { mode_str = "v", disp_str = "VISUAL",   color = "mModeVisual", },
        { mode_str = "V", disp_str = "V-LINE",   color = "mModeVisual", },
        { mode_str = "", disp_str = "V-BLOCK",  color = "mModeVisual", },
        { mode_str = "t", disp_str = "TERM-JOB", color = "mModeTerm", },
    }
    -- "%1*%#mmodeterm# TERMINAL-NORMAL %*"
    local status_line_mode = ""
    local is_match = false
    for i = 1, #mode_list do
        if mode_list[i].mode_str == current_mode_str then
            status_line_mode = status_line_mode .. "%#" .. mode_list[i].color .. "#"
            status_line_mode = status_line_mode .. " " .. mode_list[i].disp_str .. " "
            is_match = true
            break
        end
    end
    if is_match == false then
        status_line_mode = current_mode_str
    end
    status_line_mode = status_line_mode .. "%*"
    return status_line_mode
end

M.stat_modified = function()
    local status_modified = ""
    local is_modified = vim.o.modified
    local icon = ""
    if is_modified == true then
        icon = M.stl_icons.status.add
    else
        icon = M.stl_icons.status.ok
    end
    status_modified = icon
    return status_modified
end

StatusLine = function()
    local fg_color = M.stl_colors.mono[8]
    -- define colors
    for i = 1, #M.main_colors - 1 do
        -- separator colors
        vim.cmd("hi uStlSep" .. i .. " gui=none guifg=#" .. M.main_colors[i] .. " guibg=#" .. M.main_colors[i + 1] .. "")
        -- status module colors
        vim.cmd("hi uStlStat" .. i .. " gui=bold guifg=#" .. fg_color .. " guibg=#" .. M.main_colors[i] .. "")
    end

    -- colors of end separator
    vim.cmd("hi uStlSepEndr gui=none")
    vim.cmd("hi uStlSepEndl gui=none")
    -- not current statusline color
    vim.cmd("hi StatusLineNC guibg=#" .. fg_color .. "")

    -- create status line
    local stl = ""
    -- left of stl
    stl = stl .. M.stat_mode()
    stl = stl .. "%#uStlStat1#" .. " %n " .. M.make_separator('r', 1)
    stl = stl .. "%#uStlStat2#" .. M.stat_modified() .. M.make_separator('r', 2)
    stl = stl .. "%#uStlStat3#" .. " %F " .. M.make_separator('r', 3, true)

    --center of stl
    stl = stl .. "%<%#StatusLineNC#%="

    --right of stl
    stl = stl .. M.make_separator('l', 4, true) .. "%#uStlStat4#" .. " %cc%lr/%L "
    stl = stl .. M.make_separator('l', 3) .. "%#uStlStat3#" .. " %{&buftype!=''?&buftype:&filetype} "
    stl = stl .. M.make_separator('l', 2) .. "%#uStlStat2#" .. " %{&fileencoding!=''?&fileencoding:&encoding} "
    stl = stl .. M.make_separator('l', 1) .. "%#uStlStat1#" .. " %{&fileformat} "
    return stl
end

vim.opt.statusline = "%!v:lua.StatusLine()"
