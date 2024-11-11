local M = {}

local colors = require("core.design").colors
M.tl_colors = {
    tl_fg = colors.mono[1],
    tl_bg = colors.mono[8],
    tl_act = colors.mono[1],
    tl_stb = colors.mono[2],
    tl_info_act = colors.blue[7],
    tl_info_stb = colors.mono[6],
    tl_icons = colors.dev.ft,
    tl_flg = {
        modify = colors.orange[2],
    }
}
M.icons = require("core.design").icons

-- tab line {{{
---@class Tab
---@field is_current boolean
---@field is_end boolean
---@field name string

---@type Tab[]
M.tab_list = {}

M.init_tab_list = function(self)
    self.tab_list = {}
    -- get current tab number
    local tab_current = vim.fn.tabpagenr()
    -- get number of tabs
    local tabs_len = vim.fn.tabpagenr('$')

    for i = 1, tabs_len do
        local tab = {}
        -- is current tab or not
        tab.is_current = (i == tab_current)

        -- get the tab name
        tab.name = M.get_tabname(i)

        -- is end of tabline or not
        tab.is_end = i == tabs_len

        -- append a tab to the tab list
        M.tab_list[i] = tab
    end
end

M.get_tabname = function(tab_index)
    local tab_name = ""
    local tab_buf_list = vim.fn.tabpagebuflist(tab_index)
    if tab_buf_list == 0 then
        return tab_name
    end
    local winnr = vim.fn.tabpagewinnr(tab_index)
    local bufnr = tab_buf_list[winnr]
    tab_name = vim.fn.bufname(bufnr)
    tab_name = vim.fs.basename(tab_name)

    if tab_name == "" then
        tab_name = "No Name"
    end
    return tab_name
end

---@param tab_index integer
---@return string @vim tabline string
M.create_tab_element = function(self, tab_index)
    local tab = self.tab_list[tab_index]

    local tab_str = ""
    if tab == nil then
        return tab_str
    end

    -- Change color bright if tab is current tab
    if tab.is_current then
        tab_str = tab_str .. [[%#uTlElmAct#]]
    else
        tab_str = tab_str .. [[%#uTlElmStb#]]
    end
    tab_str = tab_str

    -- Add a tab name information.
    if tab.name == nil then
        return tab_str
    end
    tab_str = tab_str .. " " .. tab.name .. " "

    -- Add Separator
    if tab.is_current and tab.is_end then
        tab_str = tab_str .. [[%#uTlSepActEnd#]] .. self.icons.separator.flat_fill
    elseif tab.is_current and (not tab.is_end) then
        tab_str = tab_str .. [[%#uTlSepAct#]] .. self.icons.separator.flat_fill
    elseif (not tab.is_current) and tab.is_end then
        tab_str = tab_str .. [[%#uTlSepStb#]]
    else
        tab_str = tab_str .. [[%#uTlSepStb#]] .. self.icons.separator.flat_fill
    end
    return tab_str
end

M.create_tab_line = function(self)
    -- initialize tab information list
    self.init_tab_list(self)

    -- create tab line
    local tab_line = ""
    for i = 1, #self.tab_list do
        tab_line = tab_line .. self.create_tab_element(self, i)
    end
    return tab_line
end
-- }}}

-- buffer line{{{
---@class Buf
---@field is_current boolean
---@field is_end boolean
---@field name string
---@field nr integer
---@field is_modified boolean
---@field type string

---@type Buf[]
M.buf_list = {}

M.init_buf_list = function(self)
    self.buf_list = {}
    -- get current buf number
    local buf_current = vim.fn.bufnr()

    -- get buffer informations
    local buf_infos = vim.fn.getbufinfo({ buflisted = 1 })

    -- get number of buffers
    local bufs_len = #buf_infos

    -- append infomation of buffer element to bufferlist
    for i = 1, bufs_len do
        ---@type Buf
        local buf = {}
        -- get the bufnr
        buf.nr = buf_infos[i].bufnr

        -- is current buf or not
        buf.is_current = (buf.nr == buf_current)

        -- get the buf name
        buf.name = vim.fs.basename(buf_infos[i].name)
        if buf.name == "" then
            buf.name = "No Name"
        end

        -- is end of bufline or not
        buf.is_end = i == 1

        -- is modified
        buf.is_modified = (buf_infos[i].changed == 1)

        -- ft
        buf.type = vim.api.nvim_get_option_value('filetype', { buf = buf.nr })

        -- append a buf to the buf list
        M.buf_list[i] = buf
    end
end

M.filetype_icon = function(file_type, is_current)
    local icon = M.icons.dev.ft[file_type]
    if icon == nil then
        icon = M.icons.dev.ft.text
    end

    local icon_elm = ""
    if M.tl_colors.tl_icons[file_type] then
        icon_elm = "%#uFtIcon" .. file_type .. "#"
    else
        icon_elm = "%#uFtIcontext#"
    end

    icon_elm = icon_elm .. icon
    if is_current then
        icon_elm = icon_elm .. [[%#uTlElmAct#]]
    else
        icon_elm = icon_elm .. [[%#uTlElmStb#]]
    end
    return icon_elm
end

---@return string @vim tabline string
M.create_buf_element = function(self, i)
    local buf = self.buf_list[i]
    -- guard
    local buf_str = ""
    if buf == nil then
        return buf_str
    end

    -- Add Separator
    -- if buf.is_current and buf.is_end then
    -- buf_str = buf_str .. [[%#uTlSepActEnd#]] .. self.icons.separator.flat_fill
    -- elseif buf.is_current and (not buf.is_end) then
    -- buf_str = buf_str .. [[%#uTlSepAct#]] .. self.icons.separator.flat_fill
    -- elseif (not buf.is_current) and buf.is_end then
    -- buf_str = buf_str .. [[%#uTlSepStb#]]
    -- else
    -- buf_str = buf_str .. [[%#uTlSepStb#]] .. self.icons.separator.flat_fill
    -- end

    -- Add buffer header (buffer number)
    if buf.is_current then
        buf_str = buf_str .. [[%#uTlInfoAct#]]
    else
        buf_str = buf_str .. [[%#uTlInfoStb#]]
    end
    -- buffer number
    buf_str = buf_str .. " " .. buf.nr .. " "


    -- Change color bright if buf is current buf
    -- if buf.is_current then
    -- buf_str = buf_str .. [[%#uTlElmAct#]]
    -- else
    -- buf_str = buf_str .. [[%#uTlElmStb#]]
    -- end
    if buf.name == nil then
        return buf_str
    end
    -- Add a buf name.
    buf_str = buf_str .. "" .. self.filetype_icon(buf.type, buf.is_current) .. buf.name

    -- Add modify flag
    if buf.is_modified then
        buf_str = buf_str .. "%#uTlFlgMod#" .. M.icons.signs.dot -- .. ""
    end

    buf_str = buf_str .. " "
    return buf_str
end

---@return string @vim tabline string
M.create_buf_line = function(self)
    self.init_buf_list(self)
    --
    -- create tab line
    local buf_line = ""
    for i = 1, #self.buf_list do
        buf_line = buf_line .. self.create_buf_element(self, i)
    end
    return buf_line
end
-- }}}

-- highlght{{{
M.set_highlight = function()
    -- tabline elements highlight
    vim.cmd("hi uTlElmAct gui=bold guifg=#" .. M.tl_colors.tl_act .. " guibg=none")
    vim.cmd("hi uTlElmStb gui=bold guifg=#" .. M.tl_colors.tl_stb .. " guibg=none")
    -- tabline information header highlight
    vim.cmd("hi uTlInfoAct gui=bold guifg=#" .. M.tl_colors.tl_fg .. " guibg=#" .. M.tl_colors.tl_info_act)
    vim.cmd("hi uTlInfoStb gui=bold guifg=#" .. M.tl_colors.tl_fg .. " guibg=#" .. M.tl_colors.tl_info_stb)
    -- tabline separator highlight TODO abolition
    vim.cmd("hi uTlSepAct gui=bold guifg=#" .. M.tl_colors.tl_bg .. " guibg=#" .. M.tl_colors.tl_act)
    vim.cmd("hi uTlSepStb gui=bold guifg=#" .. M.tl_colors.tl_bg .. " guibg=#" .. M.tl_colors.tl_stb)
    vim.cmd("hi uTlSepActEnd gui=bold guifg=#" .. M.tl_colors.tl_bg .. " guibg=#" .. M.tl_colors.tl_act)
    vim.cmd("hi uTlSepStbEnd gui=bold guifg=#" .. M.tl_colors.tl_bg .. " guibg=#" .. M.tl_colors.tl_stb)
    -- tabline fill highlight
    vim.cmd("hi uTlFill gui=bold guifg=#" .. M.tl_colors.tl_bg .. " guibg=#" .. M.tl_colors.tl_bg)

    -- flags highlight
    vim.cmd("hi uTlFlgMod gui=bold guifg=#" .. M.tl_colors.tl_flg.modify .. " guibg=none")

    -- icon highlight
    local design = require('core.design')
    design.set_icon_hi_ft(design)
end
-- }}}

-- initialize{{{
M.create_line = function(self)
    local line = ""
    -- tabline left
    line = line .. self.create_tab_line(self)
    -- tabline center
    line = line .. [[%T%#uTlFill#%=%#uTlElmAct#]]
    -- tabline right
    line = line .. self.create_buf_line(self)
    return line
end

M.new = function(self)
    M.set_highlight()
    local tab_line = M.create_line(self)
    return tab_line
end

TabLine = function()
    local tab_line = M.new(M)
    return tab_line
end
-- }}}

-- attach tabline
vim.opt.showtabline = 2
vim.opt.tabline = "%!v:lua.TabLine()"
