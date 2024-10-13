-- =============================================================
-- description:
--   simple language translator powered by google app script
-- note:
--   curl required. if curl is not installed, execute below commamd
--   $ sudo apt install curl
-- =============================================================
local uilib = require('util.uilib')
local helper = require('util.helper')

-- display translation result{{{
local display_result
display_result = function(result)
    -- text molding
    local br_char = "。"
    local lines = vim.fn.split(result, br_char .. '\\zs')

    -- count number of char of longest line
    local line_longest = 0
    for i = 1, #lines do
        local line_len = #lines[i]
        if line_longest < line_len then
            line_longest = line_len
        end
    end

    -- create instance of floatwindow
    local translate_fw = uilib.floatwindow()

    -- define floating window options
    --     local pos = vim.fn.getpos(".")
    local HEIGHT_MAX = 50
    local WIDTH_MAX = 100
    local HEIGHT_RATE = 1.2

    local height = math.floor(#lines * HEIGHT_RATE)
    if #lines > HEIGHT_MAX then -- max 50 lines
        height = HEIGHT_MAX
    end
    local width = line_longest
    if width > WIDTH_MAX then
        width = WIDTH_MAX
        height = height + 1
    end
    --     local border_off = 2
    --     local offset = 1
    --     local border = {
    --         '"', ' ', '"', ' ',
    --         '"', ' ', '"', ' ',
    --     }
    local border = 'rounded'

    local opt_win = {
        focusable = true,
        --         focusable = false,
        width     = width,
        height    = height,
        --         col       = vim.opt.columns:get() - width - border_off - offset,
        --         row       = vim.opt.lines:get() - height - border_off - offset - 1,
        col       = 1,
        row       = 1,
        border    = border,
        --         title     = "vim translation ",
        style     = 'minimal',
        relative  = "cursor",
        anchor    = "NW",
        --         relative  = "editor",
    }

    local opt = {
        name = "test",
        window = opt_win,
        keymap = {
            {
                is_buf = true,
                mode = "n",
                lhs = "q",
                rhs = "",
                opts = {
                    noremap = true,
                    callback = function()
                        translate_fw.close_win()
                    end,
                },
            },
            {
                is_buf = true,
                mode = "n",
                lhs = "j",
                rhs = "gj",
                opts = {
                    noremap = true,
                    --                     callback = false,
                },
            },
            {
                is_buf = true,
                mode = "n",
                lhs = "k",
                rhs = "gk",
                opts = {
                    noremap = true,
                    --                     callback = false,
                },
            },
        },
        autocmd = {
            --             {
            --                 is_buf = false,
            --                 event = {
            --                     "CursorMoved"
            --                 },
            --                 opts = {
            --                     callback = function()
            --                         translate_fw.close_win()
            --                     end,
            --                 }
            --             },
        },
        winopt = {
            {
                name = "wrap",
                value = true,
            },
        },
        bufopt = {
        },
        hlopt = {
            {
                name = "NormalFloat",
                val = {
                    fg = "#fefefe",
                    bg = "#382c2c",
                }
            },
            {
                name = "FloatBorder",
                val = {
                    fg = "#fefefe",
                    bg = "#382c2c",
                }
            },
        },
        initial_lines = lines
    }
    translate_fw.init(opt)
    translate_fw.send_cmd("noautocmd normal! gg0")
end
-- }}}

-- get text that selected on visual mode{{{
local get_selected_txt
get_selected_txt = function()
    --     local pos = vim.fn.getpos(".")
    local zreg_bf = vim.fn.getreg("z")
    vim.cmd('noautocmd normal! "zy')
    local zreg_af = vim.fn.getreg("z")
    vim.fn.setreg("z", zreg_bf)
    --     vim.fn.setpos(".", pos)
    return zreg_af
end
-- }}}

-- get text that under cursor{{{
local get_cursor_txt
get_cursor_txt = function()
    --     local pos = vim.fn.getpos(".")
    local zreg_bf = vim.fn.getreg("z")
    vim.cmd('noautocmd normal! viw"zy')
    local zreg_af = vim.fn.getreg("z")
    vim.fn.setreg("z", zreg_bf)
    --     vim.fn.setpos(".", pos)
    return zreg_af
end
-- }}}

-- create request paramaters to hit the translation API{{{
local create_req_params
create_req_params = function(text, source, target)
    local strlen_max = 3000
    if string.len(text) > strlen_max then
        helper.highlightEcho("warning", "the text must be less than 1,000 characters")
        return ""
    end
    -- format text used in request parametera
    local req_text = text
    -- substitute forbidden char
    req_text = string.gsub(req_text, "%[", "［")
    req_text = string.gsub(req_text, "%]", "］")
    req_text = string.gsub(req_text, "%{", "｛")
    req_text = string.gsub(req_text, "%}", "｝")
    req_text = string.gsub(req_text, "%(", "（")
    req_text = string.gsub(req_text, "%)", "）")
    req_text = string.gsub(req_text, "#", "＃")
    req_text = string.gsub(req_text, "*", "＊")
    req_text = string.gsub(req_text, "`", "｀")
    -- replace whitespace char that include space, tab, line breaks with "\\s"
    req_text = string.gsub(req_text, "%s+", "\\s")
    -- create reqest paramater
    local req_params = "?text=" .. req_text .. "&source=" .. source .. "&target=" .. target
    return req_params
end
-- }}}

-- hit the translation API{{{
local hit_translation_api
hit_translation_api = function(params)
    -- assemble cmd to hit the api
    local req_url = params.url_api                                                  -- http://<translation api url>
    local req_params = create_req_params(params.text, params.source, params.target) -- ?text=.....&source=..&target=..
    if req_params == "" then
        return ""
    end
    local req = '"' .. req_url .. req_params .. '"'
    local cmd_curl = 'curl -L ' .. req
    local cmd_rm_stderr = ''
    if vim.fn.has('linux') == 1 then
        cmd_rm_stderr = '2> /dev/null'
    end
    local cmd = cmd_curl .. ' ' .. cmd_rm_stderr

    -- hit the translation api and read translate result(stdout)
    local handle = io.popen(cmd)
    if handle == nil then return end
    local result = handle:read('*a')
    handle:close()

    if result == nil then
        return ""
    else
        return result
    end
end
-- }}}

-- translate text{{{
local translate
translate = function(params)
    --     helper.highlightEcho("info", "translating...")
    local res = hit_translation_api(params)
    if res == "" then
        -- if response was empty, print error
        helper.highlightEcho("error", 'failed to translate text. curl is required for translation')
        return
    else
        -- print translate result
        display_result(res)
    end
end
-- }}}

-- define paramaters to translate english to japanese{{{
local params_en_to_jp = {
    url_api =
    "https://script.google.com/macros/s/AKfycbwazxusB41dZgqxLMuQ1mn6177dGGISodFDv4-yaeKuTr45BaDXqOAupIiceJyBCEs/exec",
    text = "",
    source = "en",
    target = "ja",
}
-- }}}

-- set keymaps{{{
vim.keymap.set("v", "<Space>?", "", {
    noremap = true,
    callback = function()
        params_en_to_jp.text = get_selected_txt()
        translate(params_en_to_jp)
    end,
})
vim.keymap.set("n", "<Space>?", "", {
    noremap = true,
    callback = function()
        params_en_to_jp.text = get_cursor_txt()
        translate(params_en_to_jp)
    end,
})
-- }}}

--[[ translate test{{{
Open a window and display the help file in read-only
mode.  If there is a help window open already, use
that one.  Otherwise, if the current window uses the
full width of the screen or is at least 80 characters
wide, the help window will appear just above the
current window.  Otherwise the new window is put at
the very top.
The 'helplang' option is used to select a language, if
the main help file is available in several languages.
Open a window and display the help file in read-only
mode.  If there is a help window open already, use
that one.  Otherwise, if the current window uses the
full width of the screen or is at least 80 characters
wide, the help window will appear just above the
current window.  Otherwise the new window is put at
the very top.
The 'helplang' option is used to select a language, if
the main help file is available in several languages.
Namespaces are used for buffer highlights and virtual text, see
|nvim_buf_add_highlight()| and |nvim_buf_set_extmark()|.

Namespaces can be named or anonymous. If `name` matches an existing
namespace, the associated id is returned. If `name` is an empty string a
new, anonymous namespace is created.
--]]
--}}}
