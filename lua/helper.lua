vim.cmd[[
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

