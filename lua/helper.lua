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

    local echocmd = "echo '" .. head .. msg .. "'"
    vim.cmd(echocmd)
    vim.cmd("echohl end")
end

return {
    highlightEcho = highlightEcho,
}
