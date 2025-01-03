vim.cmd [[
"{{{ helper functions
"{{{ echo highlighting
function! HighlightEcho(type, msg) abort
    if a:type == "error"
        echohl ErrorMsg
        let l:head = "[Error] "

    elseif a:type == "warning"
        echohl WarningMsg
        let l:head = "[Warning] "

    elseif a:type == "info"
        echohl DiffAdd
        let l:head = "[Info] "
    else
        echohl DiffAdd
        let l:head = ""
    endif

    let l:echomsg = l:head . a:msg
    execute 'echo "' . l:echomsg '"'
    echohl end
endfunction
"}}}
"=================================================================================================================================================================}}}
]]

local highlightEcho = function(type, msg)
    local head = ""
    if type == 'error' then
        vim.cmd("echohl ErrorMsg")
        head = "[Error] "
    elseif type == 'warning' then
        vim.cmd("echohl WarningMsg")
        head = "[Warning] "
    elseif type == 'info' then
        vim.cmd("echohl DiffAdd")
        head = "[Info] "
    else
        vim.cmd("echohl DiffAdd")
    end

    local echocmd = 'echo "' .. head .. msg .. '"'
    vim.cmd(echocmd)
    vim.cmd("echohl end")
end

local highlightInput = function(type, prompt, text)
    if type == vim.log.levels.ERROR then
        vim.cmd("echohl ErrorMsg")
    elseif type == vim.log.levels.WARN then
        vim.cmd("echohl WarningMsg")
    elseif type == vim.log.levels.INFO then
        vim.cmd("echohl DiffAdd")
    end

    local inputstr = ""
    if text == nil then
        inputstr = vim.fn.input(prompt)
    else
        inputstr = vim.fn.input(prompt, text)
    end
    vim.cmd("echohl end")

    return inputstr
end

-- local vimrc_path = vim.fs.normalize(vim.env.MYVIMRC)
local vimrc_path = vim.env.MYVIMRC
local vimrcdir = vim.fs.dirname(vimrc_path)

return {
    highlightEcho = highlightEcho,
    highlightInput = highlightInput,
    vimrcdir = vimrcdir,
}
