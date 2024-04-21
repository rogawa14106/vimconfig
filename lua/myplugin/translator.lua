local helper = require('../helper')
-- get text selected on visual mode
local get_selected_txt
get_selected_txt = function()
    local zreg_bf = vim.fn.getreg("z")
    vim.cmd('noautocmd normal! "zy')
    local zreg_af = vim.fn.getreg("z")
    vim.fn.setreg("z", zreg_bf)
    return zreg_af
end

-- get text that under cursor
local get_cursor_txt
get_cursor_txt = function()
    local zreg_bf = vim.fn.getreg("z")
    vim.cmd('noautocmd normal! viw"zy')
    local zreg_af = vim.fn.getreg("z")
    vim.fn.setreg("z", zreg_bf)
    return zreg_af
end

-- create request paramaters to hit the translation API
local create_req_params
create_req_params = function(text, source, target)
    text = string.gsub(text, "\n", " ")
    text = string.gsub(text, " ", "\\s")
    local params = "?text=" .. text .. "&source=" .. source .. "&target=" .. target
    return params
end

-- hit the translation API
local hit_translation_api
hit_translation_api = function(url, params)
    -- assemble request cmd
    local req_cmd = 'curl -L "' .. url .. params .. '" 2> /dev/null'
    --
    local handle = io.popen(req_cmd)
    if handle == nil then return end
    local result = handle:read('*a')
    handle:close()

    return result
end

-- translate text
local translate
translate = function(params)
    helper.highlightEcho("info", "transrating...")
    local req_params = create_req_params(params.text, params.source, params.target)

    local res = hit_translation_api(params.url_api, req_params)
    if res == "" then
        -- if response was empty, print error
        helper.highlightEcho("error", "failed to translate")
    else
        -- print translate result 
        print(res)
    end
end

-- define paramaters to translate english to japanese
local params_en_to_jp = {
    url_api =
    "https://script.google.com/macros/s/AKfycbwazxusB41dZgqxLMuQ1mn6177dGGISodFDv4-yaeKuTr45BaDXqOAupIiceJyBCEs/exec",
    text = "",
    source = "en",
    target = "ja",
}

-- set keymaps
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
